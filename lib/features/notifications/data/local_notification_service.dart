import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  if (kDebugMode) {
    debugPrint(
      '[Notifications] Background tap payload=${response.payload}',
    );
  }
}

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'Used for important push notifications.',
        importance: Importance.max,
      );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    _initialized = true;
  }

  static void _onDidReceiveNotificationResponse(
    NotificationResponse response,
  ) {
    if (kDebugMode) {
      debugPrint(
        '[Notifications] Foreground tap payload=${response.payload}',
      );
    }
  }

  static Future<void> showFromRemoteMessage(RemoteMessage message) async {
    await initialize();

    final fallbackTitle = message.data['title']?.toString();
    final fallbackBody = message.data['body']?.toString();
    final title = message.notification?.title ?? fallbackTitle;
    final body = message.notification?.body ?? fallbackBody;

    if ((title ?? '').trim().isEmpty && (body ?? '').trim().isEmpty) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode(message.data),
    );

    if (kDebugMode) {
      debugPrint('[Notifications] Local notification shown.');
    }
  }
}
