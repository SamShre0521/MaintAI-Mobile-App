import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/user_notification.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository(this.apiClient);

  Future<UserNotification> getNotification(String notificationId) async {
    final response = await apiClient.dio.get('/notifications/$notificationId');

    final data = Map<String, dynamic>.from(
      response.data['notification'] ?? response.data,
    );

    return UserNotification.fromJson(data);
  }

  Future<void> markAsRead(String notificationId) async {
    await apiClient.dio.patch('/notifications/$notificationId/read');
  }

  Future<int> getUnreadCount() async {
    final response = await apiClient.dio.get('/notifications/unread-count');

    return (response.data['count'] as num?)?.toInt() ?? 0;
  }

  Future<List<UserNotification>> getNotifications() async {
    final response = await apiClient.dio.get('/notifications');

    final rawList = response.data['notifications'];

    if (rawList is! List) {
      return [];
    }

    return rawList
        .whereType<Map>()
        .map(
          (item) => UserNotification.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> markAllAsRead() async {
    await apiClient.dio.patch('/notifications/read-all');
  }
}
