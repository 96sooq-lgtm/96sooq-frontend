import 'dart:async';
import 'dart:developer' as developer;

import 'package:_96_sooq/features/auth/data/models/check_user_request_model.dart';
import 'package:_96_sooq/features/auth/data/models/complete_profile_request_model.dart';
import 'package:_96_sooq/features/auth/data/models/auth_user_model.dart'
    as app_auth;
import 'package:_96_sooq/features/auth/data/services/auth_api_service.dart';
import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/notifications/data/notification_registration_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    SupabaseClient? supabaseClient,
    AuthApiService? authApiService,
    AuthSessionRepository? authSessionRepository,
    NotificationRegistrationService? notificationRegistrationService,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client,
       _authApiService = authApiService ?? const AuthApiService(),
       _authSessionRepository =
           authSessionRepository ?? AuthSessionRepository(),
       _notificationRegistrationService =
           notificationRegistrationService ?? NotificationRegistrationService(),
       super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSessionChanged>(_onAuthSessionChanged);
    on<OAuthCheckUserRequested>(_onOAuthCheckUserRequested);
    on<CompleteProfileRequested>(_onCompleteProfileRequested);
    on<LogoutRequested>(_onLogoutRequested);

    _authSubscription = _supabaseClient.auth.onAuthStateChange.listen((data) {
      add(AuthSessionChanged(event: data.event, session: data.session));
    });
  }

  final SupabaseClient _supabaseClient;
  final AuthApiService _authApiService;
  final AuthSessionRepository _authSessionRepository;
  final NotificationRegistrationService _notificationRegistrationService;
  late final StreamSubscription _authSubscription;

  bool _isProcessingOAuthCheck = false;

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      emit(AuthOAuthInProgress());
    } on AuthException catch (e, st) {
      developer.log(
        'Google OAuth failed: message="${e.message}", statusCode="${e.statusCode}", code="${e.code}"',
        name: 'AuthBloc',
        error: e,
        stackTrace: st,
      );
      if (e.message.toLowerCase().contains('missing oauth secret')) {
        emit(
          AuthFailure(
            message:
                'Google provider is not fully configured in Supabase (missing OAuth secret).',
          ),
        );
        return;
      }
      emit(
        AuthFailure(
          message:
              'Google sign in failed: ${e.message} (status: ${e.statusCode}, code: ${e.code})',
        ),
      );
    } catch (e, st) {
      developer.log(
        'Google OAuth unexpected error',
        name: 'AuthBloc',
        error: e,
        stackTrace: st,
      );
      emit(AuthFailure(message: 'Google sign in failed: $e'));
    }
  }

  void _onAuthSessionChanged(
    AuthSessionChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.session != null &&
        (event.event == AuthChangeEvent.signedIn ||
            event.event == AuthChangeEvent.initialSession ||
            event.event == AuthChangeEvent.tokenRefreshed ||
            event.event == AuthChangeEvent.userUpdated)) {
      add(OAuthCheckUserRequested(session: event.session!));
      return;
    }

    if (event.event == AuthChangeEvent.signedOut) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onOAuthCheckUserRequested(
    OAuthCheckUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_isProcessingOAuthCheck) {
      return;
    }

    _isProcessingOAuthCheck = true;
    emit(AuthLoading());

    try {
      final providerId = event.session.user.id;
      final email = event.session.user.email ?? '';
      final profilePicture =
          (event.session.user.userMetadata?['avatar_url'] ?? '').toString();
      final initialName = (event.session.user.userMetadata?['full_name'] ?? '')
          .toString();

      if (providerId.isEmpty || email.isEmpty) {
        emit(
          AuthFailure(
            message:
                'Unable to continue Google sign in. Missing provider id or email.',
          ),
        );
        return;
      }

      final response = await _authApiService.checkUser(
        CheckUserRequest(
          provider: 'google',
          providerId: providerId,
          email: email,
        ),
      );

      if (response.exists) {
        final token = response.accessToken;
        final tokenType = response.tokenType;
        final user = response.user;

        if (token == null ||
            token.isEmpty ||
            tokenType == null ||
            tokenType.isEmpty ||
            user == null) {
          emit(
            AuthFailure(
              message:
                  'Invalid auth response: missing token or user for existing account.',
            ),
          );
          return;
        }

        await _authSessionRepository.persistAuthenticatedSession(
          accessToken: token,
          tokenType: tokenType,
          user: user,
        );

        emit(AuthAuthenticated(user: user));
        return;
      }

      emit(
        AuthNeedsProfileCompletion(
          email: email,
          providerId: providerId,
          profilePicture: profilePicture,
          initialName: initialName,
        ),
      );
    } catch (e, st) {
      developer.log(
        'OAuth check user failed',
        name: 'AuthBloc',
        error: e,
        stackTrace: st,
      );
      emit(AuthFailure(message: e.toString()));
    } finally {
      _isProcessingOAuthCheck = false;
    }
  }

  Future<void> _onCompleteProfileRequested(
    CompleteProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await _authApiService.completeProfile(
        CompleteProfileRequest(
          provider: event.provider,
          providerId: event.providerId,
          email: event.email,
          name: event.name,
          phoneNumber: event.phoneNumber,
          profilePicture: event.profilePicture,
        ),
      );

      final token = response.accessToken;
      final tokenType = response.tokenType;
      final responseUser = response.user;
      final responseUserName = responseUser?.name ?? '';
      final responseUserEmail = responseUser?.email ?? '';
      final responseUserPhone = responseUser?.phoneNumber ?? '';
      final responseUserProfilePicture = responseUser?.profilePicture ?? '';
      final user = app_auth.AuthUser(
        id: responseUser?.id ?? '',
        name: responseUserName.isEmpty ? event.name : responseUserName,
        email: responseUserEmail.isEmpty ? event.email : responseUserEmail,
        phoneNumber: responseUserPhone.isEmpty
            ? event.phoneNumber
            : responseUserPhone,
        profilePicture: responseUserProfilePicture.isEmpty
            ? event.profilePicture
            : responseUserProfilePicture,
      );

      if (token == null ||
          token.isEmpty ||
          tokenType == null ||
          tokenType.isEmpty ||
          user.id.isEmpty) {
        emit(
          AuthFailure(
            message:
                'Invalid create account response: missing token or user payload.',
          ),
        );
        return;
      }

      await _authSessionRepository.persistAuthenticatedSession(
        accessToken: token,
        tokenType: tokenType,
        user: user,
      );

      emit(AuthAuthenticated(user: user));
    } catch (e, st) {
      developer.log(
        'Complete profile failed',
        name: 'AuthBloc',
        error: e,
        stackTrace: st,
      );
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _notificationRegistrationService.unregisterCurrentToken();
    await _authSessionRepository.clearSession();
    try {
      await _supabaseClient.auth.signOut();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }
}
