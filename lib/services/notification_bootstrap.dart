import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/notification-payload.dart';
import 'package:maintai/navigation/app-navigation.dart';
import 'package:maintai/presentation/pages/notification_details_page.dart';
import 'package:maintai/services/push_notifications_service.dart';
import 'package:maintai/storage/tokenStorage.dart';

class NotificationBootstrap {
  NotificationBootstrap._();

  static PushNotificationService? _service;
  static NotificationPayload? _pendingPayload;

  static Future<void> initializeAfterLogin() async {
    if (_service != null) {
      return;
    }

    final tokenStorage = TokenStorage();
    final apiClient = ApiClient(tokenStorage);

    _service = PushNotificationService(
      messaging: FirebaseMessaging.instance,
      localNotifications: FlutterLocalNotificationsPlugin(),
      apiClient: apiClient,
      onNotificationTap: _handlePayload,
    );

    await _service!.initialize();

    final initialPayload = await _service!.getInitialPayload();

    if (initialPayload != null) {
      _pendingPayload = initialPayload;
      _tryOpenPendingPayload();
    }
  }

  static void _handlePayload(NotificationPayload payload) {
    _pendingPayload = payload;
    _tryOpenPendingPayload();
  }

  static void _tryOpenPendingPayload() {
    final payload = _pendingPayload;
    final navigator = AppNavigator.key.currentState;

    if (payload == null || navigator == null) {
      return;
    }

    if (payload.type != 'feedback_approved' &&
        payload.type != 'feedback_rejected') {
      return;
    }

    _pendingPayload = null;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => NotificationDetailsPage(
          notificationId: payload.notificationId,
          feedbackId: payload.feedbackId,
          sessionId: payload.sessionId,
        ),
      ),
    );
  }

  static Future<void> unregisterOnLogout() async {
    await _service?.unregisterCurrentDevice();
    _service = null;
    _pendingPayload = null;
  }
}