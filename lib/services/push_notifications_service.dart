import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/notification-payload.dart';

class PushNotificationService {
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin localNotifications;
  final ApiClient apiClient;
  final void Function(NotificationPayload payload) onNotificationTap;

  PushNotificationService({
    required this.messaging,
    required this.localNotifications,
    required this.apiClient,
    required this.onNotificationTap,
  });

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'maintai_alerts',
    'MaintAI Alerts',
    description:
        'Approval, rejection and troubleshooting notifications',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _requestPermission();
    await _registerDeviceToken();
    _listenForTokenRefresh();
    _listenForForegroundMessages();
    _listenForNotificationTaps();
  }

  Future<void> registerCurrentDevice() async {
  await _registerDeviceToken();
}
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final rawPayload = response.payload;

        if (rawPayload == null || rawPayload.isEmpty) {
          return;
        }

        try {
          final decoded = jsonDecode(rawPayload);

          if (decoded is Map<String, dynamic>) {
            onNotificationTap(
              NotificationPayload.fromMap(decoded),
            );
          } else if (decoded is Map) {
            onNotificationTap(
              NotificationPayload.fromMap(
                Map<String, dynamic>.from(decoded),
              ),
            );
          }
        } catch (e) {
          debugPrint('Invalid local notification payload: $e');
        }
      },
    );

    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );

    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _registerDeviceToken() async {
    try {
      final token = await messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is unavailable');
        return;
      }

      debugPrint('FCM token: $token');

      await _sendTokenToBackend(token);
    } catch (e) {
      debugPrint('FCM token registration failed: $e');
    }
  }

  void _listenForTokenRefresh() {
    messaging.onTokenRefresh.listen(
      (token) async {
        try {
          await _sendTokenToBackend(token);
        } catch (e) {
          debugPrint('FCM token refresh sync failed: $e');
        }
      },
    );
  }

  Future<void> _sendTokenToBackend(String token) async {
    await apiClient.dio.post(
      '/users/device-token',
      data: {
        'token': token,
        'platform': 'android',
      },
    );
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;

      if (notification == null) {
        return;
      }

      await localNotifications.show(
        id: message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: notification.title ?? 'MaintAI',
        body: notification.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'maintai_alerts',
            'MaintAI Alerts',
            channelDescription:
                'Approval, rejection and troubleshooting notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    });
  }

  void _listenForNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap(
        NotificationPayload.fromMap(message.data),
      );
    });
  }

  Future<NotificationPayload?> getInitialPayload() async {
    final initialMessage = await messaging.getInitialMessage();

    if (initialMessage == null) {
      return null;
    }

    return NotificationPayload.fromMap(initialMessage.data);
  }

  Future<void> unregisterCurrentDevice() async {
    try {
      final token = await messaging.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      await apiClient.dio.delete(
        '/users/device-token',
        data: {
          'token': token,
        },
      );
    } catch (e) {
      debugPrint('Could not unregister FCM token: $e');
    }
  }
}