import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:_96_sooq/features/auth/data/storage/auth_secure_storage.dart';
import 'package:_96_sooq/features/auth/data/storage/auth_shared_prefs_storage.dart';
import 'package:_96_sooq/shared/app_navigation.dart';
import 'package:_96_sooq/shared/global_screens/no_internet_screen.dart';
import 'package:_96_sooq/features/root/bloc/root_bloc.dart';
import 'package:_96_sooq/features/root/bloc/root_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/auth/bloc/auth_bloc.dart';

class DioServices {
  DioServices._();
  static final AuthSecureStorage _authSecureStorage = AuthSecureStorage();
  static bool _isNoInternetScreenShown = false;

  // ─── Auth-ready gate ──────────────────────────────────────────────────────
  // Protected API calls wait on this completer until auth is confirmed.
  // Call [markAuthReady] once the token is persisted.
  static Completer<void> _authReadyCompleter = Completer<void>();

  /// Signal that auth is ready (token stored, isLoggedIn = true).
  /// Safe to call multiple times — subsequent calls are no-ops.
  static void markAuthReady() {
    if (!_authReadyCompleter.isCompleted) {
      _authReadyCompleter.complete();
    }
  }

  /// Returns a future that resolves when auth is ready.
  /// Times out after [timeout] to avoid hanging indefinitely.
  static Future<bool> waitForAuth({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      await _authReadyCompleter.future.timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  /// Reset the gate (e.g. on logout). Next protected call will wait again.
  static void resetAuthGate() {
    if (_authReadyCompleter.isCompleted) {
      _authReadyCompleter = Completer<void>();
    }
  }

  static final Dio _dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.addAll([
          _BasicHeadersInterceptor(),
          _AuthInterceptor(authSecureStorage: _authSecureStorage),
          _UnauthorizedInterceptor(),
          _NetworkErrorInterceptor(),
          _ColoredLogInterceptor(),
        ]);

  static Dio get client => _dio;
}

class _BasicHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('Accept', () => 'application/json');
    options.headers.putIfAbsent('Content-Type', () => 'application/json');
    super.onRequest(options, handler);
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required AuthSecureStorage authSecureStorage})
    : _authSecureStorage = authSecureStorage;

  final AuthSecureStorage _authSecureStorage;
  final AuthSharedPrefsStorage _prefsStorage = AuthSharedPrefsStorage();
  static bool _printedAuthDiagnostics = false;

  /// URL path segments that require a valid auth token.
  /// NOTE: /api/stores/ is intentionally excluded — store listing, details,
  /// and reviews are public APIs that work without auth.
  static const List<String> _protectedPathPrefixes = [
    '/api/stores/check', // only the "do I have a store?" endpoint needs auth
    '/api/payments/',
    '/api/listings/',
    '/api/subscriptions/ad-prices',
    '/api/subscriptions/',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check SharedPreferences first — this flag does NOT survive reinstalls,
    // unlike iOS Keychain. If the user is not marked as logged in, we treat
    // any keychain token as stale and skip it entirely.
    final isLoggedIn = await _prefsStorage.isLoggedIn();
    final token = await _authSecureStorage.readAccessToken();
    final tokenType = await _authSecureStorage.readTokenType();

    final isPublicOfferApi = options.uri.path == '/api/banners/offers';

    if (isLoggedIn && token != null && token.isNotEmpty && !isPublicOfferApi) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      // Not logged in — remove any header and proactively clear stale
      // keychain tokens left over from a previous install.
      options.headers.remove('Authorization');
      if (token != null && token.isNotEmpty) {
        _authSecureStorage.clearToken(); // async fire-and-forget cleanup
      }

      // If not logged in yet, wait briefly for auth to become ready
      // (covers the startup race condition).
      final path = options.uri.path;
      final isProtected = _protectedPathPrefixes.any(
        (prefix) => path.startsWith(prefix),
      );
      if (isProtected) {
        final authReady = await DioServices.waitForAuth();
        if (authReady) {
          // Auth became ready — re-read token and attach it
          final freshToken = await _authSecureStorage.readAccessToken();
          if (freshToken != null && freshToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $freshToken';
            debugPrint(
              '[AUTH-GATE] Auth became ready, attaching token for $path',
            );
          } else {
            // Auth completed but no token — reject
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'Unauthenticated: no valid session for $path',
                type: DioExceptionType.cancel,
              ),
              true,
            );
            return;
          }
        } else {
          // Timed out — reject
          debugPrint('[AUTH-GATE] Auth timeout — rejecting $path');
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unauthenticated: auth timed out for $path',
              type: DioExceptionType.cancel,
            ),
            true,
          );
          return;
        }
      }
    }

    _printAuthDiagnosticsOnce(
      options: options,
      token: token,
      tokenType: tokenType,
    );
    super.onRequest(options, handler);
  }

  void _printAuthDiagnosticsOnce({
    required RequestOptions options,
    required String? token,
    required String? tokenType,
  }) {
    if (!kDebugMode || _printedAuthDiagnostics) return;
    _printedAuthDiagnostics = true;

    final authHeader = options.headers['Authorization']?.toString();
    final authHeaderParts = authHeader?.split(' ') ?? const <String>[];
    final authScheme = authHeaderParts.isNotEmpty
        ? authHeaderParts.first
        : 'none';
    final claims = _decodeJwtPayload(token);
    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final expSeconds = _readEpochInt(claims?['exp']);
    final expUtc = expSeconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000, isUtc: true);

    debugPrint(
      '[AUTH-DEBUG] url=${options.uri} token_present=${token?.isNotEmpty == true} '
      'stored_token_type=${tokenType ?? 'null'} header_scheme=$authScheme',
    );
    if (claims == null) {
      debugPrint('[AUTH-DEBUG] jwt_payload=not_decodable now_utc=$nowUtc');
      return;
    }
    debugPrint(
      '[AUTH-DEBUG] jwt_sub=${claims['sub']} jwt_role=${claims['role']} '
      'jwt_exp_epoch=$expSeconds jwt_exp_utc=${expUtc?.toIso8601String()} now_utc=$nowUtc',
    );
  }

  Map<String, dynamic>? _decodeJwtPayload(String? token) {
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  int? _readEpochInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class _ColoredLogInterceptor extends Interceptor {
  static const String _reset = '\x1B[0m';
  static const String _yellow = '\x1B[33m';
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
      '$_yellow[REQ] ${options.method} ${options.uri} '
      'headers=${options.headers} body=${options.data}$_reset',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '$_green[RES] ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} body=${response.data}$_reset',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '$_red[ERR] ${err.response?.statusCode} '
      '${err.requestOptions.method} ${err.requestOptions.uri} '
      'message=${err.message} body=${err.response?.data}$_reset',
    );
    super.onError(err, handler);
  }
}

class _NetworkErrorInterceptor extends Interceptor {
  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.error is SocketException;
  }

  void _showNoInternetScreen() {
    if (DioServices._isNoInternetScreenShown) return;

    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    DioServices._isNoInternetScreenShown = true;
    navigator
        .push(
          MaterialPageRoute(
            builder: (_) => const NoInternetScreen(),
            settings: const RouteSettings(name: '/no-internet'),
          ),
        )
        .whenComplete(() {
          DioServices._isNoInternetScreenShown = false;
        });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isNetworkError(err)) {
      _showNoInternetScreen();
    }
    super.onError(err, handler);
  }
}

class _UnauthorizedInterceptor extends Interceptor {
  _UnauthorizedInterceptor();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await AuthSessionRepository().clearSession();

      final navigator = appNavigatorKey.currentState;
      if (navigator != null) {
        if (navigator.mounted) {
          navigator.context.read<AuthBloc>().add(LogoutRequested());
        }
        navigator.popUntil((route) => route.isFirst);
        if (navigator.mounted) {
          navigator.context.read<RootBloc>().add(ChangeTabEvent(0));
        }
      }
    }
    super.onError(err, handler);
  }
}
