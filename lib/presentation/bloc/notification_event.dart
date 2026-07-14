abstract class NotificationEvent {}

class LoadNotificationsEvent extends NotificationEvent {}

class RefreshUnreadCountEvent extends NotificationEvent {}

class MarkNotificationReadEvent extends NotificationEvent {
  final String notificationId;

  MarkNotificationReadEvent(this.notificationId);
}

class MarkAllNotificationsReadEvent extends NotificationEvent {}