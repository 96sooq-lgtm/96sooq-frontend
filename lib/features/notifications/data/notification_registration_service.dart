import 'dart:async';
import 'dart:io';

import 'package:_96_sooq/features/auth/domain/auth_session_repository.dart';
import 'package:_96_sooq/features/notifications/data/notification_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRegistrationService {
  NotificationRegistrationService({
    AuthSessionRepository? authSessionRepository,
    NotificationApiService? apiService,
    FirebaseMessaging? messaging,
  }) : _authSessionRepository = authSessionRepository ?? AuthSessionRepository(),
       _apiService = apiService ?? const NotificationApiService(),
       _messaging = messaging ?? FirebaseMessaging.instance;

  static const String _lastRegisteredTokenKey =
      'last_registered_fcm_token_v1';
  static const String _notificationsEnabledKey = 'notifications_enabled_v1';

  final AuthSessionRepository _authSessionRepository;
  final NotificationApiService _apiService;
  final FirebaseMessaging _messaging;

  Future<void> registerTokenIfAllowedAtStartup() async {
    final prefs = await SharedPreferences.getInstance();
    if (!isNotificationsEnabledFromPrefs(prefs)) {
      debugPrint(
        '[Notifications] Skip token register: disabled from app settings.',
      );
      return;
    }

    final isLoggedIn = await _authSessionRepository.isLoggedIn();
    if (!isLoggedIn) {
      debugPrint('[Notifications] Skip token register: user not logged in.');
      return;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    final status = settings.authorizationStatus;
    final isAuthorized =
        status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;

    debugPrint('[Notifications] Permission status: $status');
    if (!isAuthorized) {
      debugPrint(
        '[Notifications] Skip token register: permission not granted.',
      );
      return;
    }

    final token = await _fetchFcmToken();
    if (token.isEmpty) {
      debugPrint('[Notifications] Skip token register: empty FCM token.');
      return;
    }

    final lastToken = (prefs.getString(_lastRegisteredTokenKey) ?? '').trim();
    if (lastToken == token) {
      debugPrint('[Notifications] Skip token register: token unchanged.');
      return;
    }

    final masked = token.length > 12
        ? '${token.substring(0, 6)}...${token.substring(token.length - 6)}'
        : '***';
    debugPrint('[Notifications] Registering FCM token: $masked');

    try {
      await _apiService.registerToken(fcmToken: token);
      await prefs.setString(_lastRegisteredTokenKey, token);
      debugPrint('[Notifications] FCM token registered successfully.');
    } catch (e) {
      debugPrint('[Notifications] Failed to register FCM token: $e');
    }
  }

  Future<void> unregisterCurrentToken() async {
    final isLoggedIn = await _authSessionRepository.isLoggedIn();
    if (!isLoggedIn) {
      debugPrint('[Notifications] Skip unregister: user not logged in.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = await _getStoredOrCurrentToken(prefs);
    if (token.isEmpty) {
      debugPrint('[Notifications] Skip unregister: no known FCM token.');
      return;
    }

    final masked = token.length > 12
        ? '${token.substring(0, 6)}...${token.substring(token.length - 6)}'
        : '***';
    debugPrint('[Notifications] Unregistering FCM token: $masked');

    try {
      await _apiService.unregisterToken(fcmToken: token);
      await prefs.remove(_lastRegisteredTokenKey);
      debugPrint('[Notifications] FCM token unregistered successfully.');
    } catch (e) {
      debugPrint('[Notifications] Failed to unregister FCM token: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return isNotificationsEnabledFromPrefs(prefs);
  }

  Future<String> _fetchFcmToken() async {
    if (!Platform.isIOS) {
      return await _safeGetFcmToken();
    }

    // iOS: APNs token may take a moment after permission grant.
    for (var attempt = 1; attempt <= 5; attempt++) {
      final apnsToken = await _safeGetApnsToken();
      final fcmToken = await _safeGetFcmToken();
      if (apnsToken != null && apnsToken.isNotEmpty && fcmToken.isNotEmpty) {
        return fcmToken;
      }
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    return await _safeGetFcmToken();
  }

  Future<String> _getStoredOrCurrentToken(SharedPreferences prefs) async {
    final stored = (prefs.getString(_lastRegisteredTokenKey) ?? '').trim();
    if (stored.isNotEmpty) return stored;
    return await _safeGetFcmToken();
  }

  bool isNotificationsEnabledFromPrefs(SharedPreferences prefs) {
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<String> _safeGetFcmToken() async {
    try {
      return (await _messaging.getToken())?.trim() ?? '';
    } catch (e) {
      debugPrint('[Notifications] Unable to fetch FCM token: $e');
      return '';
    }
  }

  Future<String?> _safeGetApnsToken() async {
    try {
      return await _messaging.getAPNSToken();
    } catch (e) {
      debugPrint('[Notifications] Unable to fetch APNs token: $e');
      return null;
    }
  }
}
