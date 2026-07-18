import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/notification-payload.dart';
import 'package:maintai/navigation/app-navigation.dart';
import 'package:maintai/presentation/pages/notification_details_page.dart';
import 'package:maintai/services/push_notifications_service.dart';
import 'package:maintai/storage/tokenStorage.dart';
import 'package:flutter/foundation.dart';

class NotificationBootstrap {
  NotificationBootstrap._();

  static PushNotificationService? _service;
  static NotificationPayload? _pendingPayload;

  static Future<void> initializeAfterLogin() async {
    if (_service != null) {
      debugPrint(
        'Notification service already exists. Registering device again.',
      );

      await _service!.registerCurrentDevice();
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

    // final initialPayload = await _service!.getInitialPayload();

    // if (initialPayload != null) {
    //   _pendingPayload = initialPayload;
    //   _tryOpenPendingPayload();
    // }
    final initialPayload = await _service!.getInitialPayload();

    if (initialPayload != null) {
      debugPrint('Stored initial notification payload: ${initialPayload.type}');

      // Do not navigate yet. AuthPage is still changing routes.
      _pendingPayload = initialPayload;
    }
  }

  static void openPendingNotificationAfterNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        debugPrint('Trying to open pending notification after app navigation');

        _tryOpenPendingPayload();
      });
    });
  }

  static void _handlePayload(NotificationPayload payload) {
    debugPrint('Notification tapped: ${payload.type}');

    _pendingPayload = payload;
    _tryOpenPendingPayload();
  }

  // static void _tryOpenPendingPayload() {
  //   final payload = _pendingPayload;
  //   final navigator = AppNavigator.key.currentState;

  //   if (payload == null || navigator == null) {
  //     return;
  //   }

  //   if (payload.type != 'feedback_approved' &&
  //       payload.type != 'feedback_rejected') {
  //     return;
  //   }
  //   debugPrint('========== OPENING NOTIFICATION ==========');
  //   debugPrint('Type: ${payload.type}');
  //   debugPrint('Notification ID: ${payload.notificationId}');
  //   debugPrint('Feedback ID: ${payload.feedbackId}');
  //   debugPrint('Session ID: ${payload.sessionId}');
  //   debugPrint('Opening NotificationDetailsPage');

  //   _pendingPayload = null;

  //   navigator.push(
  //     MaterialPageRoute(
  //       builder: (_) => NotificationDetailsPage(
  //         notificationId: payload.notificationId,
  //         feedbackId: payload.feedbackId,
  //         sessionId: payload.sessionId,
  //       ),
  //     ),
  //   );
  // }

  static Future<void> unregisterOnLogout() async {
    await _service?.unregisterCurrentDevice();
    _service = null;
    _pendingPayload = null;
  }
  static void _tryOpenPendingPayload() {
  final payload = _pendingPayload;
  final navigator = AppNavigator.key.currentState;

  debugPrint('========== NOTIFICATION NAVIGATION ==========');
  debugPrint('Payload available: ${payload != null}');
  debugPrint('Navigator available: ${navigator != null}');
  debugPrint('Type: ${payload?.type}');
  debugPrint('Notification ID: ${payload?.notificationId}');
  debugPrint('Feedback ID: ${payload?.feedbackId}');
  debugPrint('Session ID: ${payload?.sessionId}');

  if (payload == null || navigator == null) {
    return;
  }

  if (payload.type != 'feedback_approved' &&
      payload.type != 'feedback_rejected') {
    debugPrint('Unsupported notification type: ${payload.type}');
    _pendingPayload = null;
    return;
  }

  if (payload.notificationId == null ||
      payload.notificationId!.isEmpty) {
    debugPrint('Notification ID is unavailable');
    return;
  }

  _pendingPayload = null;

  debugPrint('Opening NotificationDetailsPage');

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
}
