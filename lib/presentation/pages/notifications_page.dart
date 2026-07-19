import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/user_notification.dart';
import 'package:maintai/domain/repositories/notificationrepo.dart';
import 'package:maintai/presentation/pages/notification_details_page.dart';
import 'package:maintai/storage/tokenStorage.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationRepository repository;

  bool isLoading = true;
  String? errorMessage;
  List<UserNotification> notifications = [];

  @override
  void initState() {
    super.initState();

    repository = NotificationRepository(
      ApiClient(TokenStorage()),
    );

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result = await repository.getNotifications();

      if (!mounted) return;

      setState(() {
        notifications = result;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load notifications.';
      });
    }
  }

  Future<void> _openNotification(
    UserNotification notification,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailsPage(
          notificationId: notification.id,
          feedbackId: notification.feedbackId,
          sessionId: notification.sessionId,
        ),
      ),
    );

    if (!mounted) return;

    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        surfaceTintColor: const Color(0xFFF8F6F1),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF1C84B),
        ),
      );
    }

    if (errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 220),
          Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      );
    }

    if (notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 210),
          Icon(
            Icons.notifications_none_rounded,
            size: 58,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return _NotificationCard(
          notification: notification,
          onTap: () => _openNotification(notification),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final UserNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected =
        notification.type == 'feedback_rejected';

    final isApproved =
        notification.type == 'feedback_approved';

    final isManagerNotification =
        notification.type == 'feedback_submitted' ||
        notification.type == 'feedback_resubmitted';

    final color = isRejected
        ? const Color(0xFFDC2626)
        : isApproved
            ? const Color(0xFF16A34A)
            : isManagerNotification
                ? const Color(0xFFF59E0B)
                : const Color(0xFF6B7280);

    final icon = isRejected
        ? Icons.error_outline_rounded
        : isApproved
            ? Icons.verified_rounded
            : isManagerNotification
                ? Icons.assignment_outlined
                : Icons.notifications_none_rounded;

    return Material(
      color: notification.isRead
          ? Colors.white
          : const Color(0xFFFFFBEB),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFFE4DCC8)
                  : const Color(0xFFF1C84B),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDC2626),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (notification.createdAt.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Text(
                        notification.createdAt,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}