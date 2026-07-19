import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/repositories/notificationrepo.dart';
import 'package:maintai/presentation/widgets/notification_icon_button.dart';
import 'package:maintai/storage/tokenStorage.dart';
import 'package:maintai/presentation/pages/notifications_page.dart';

class NotificationBellLoader extends StatefulWidget {
  const NotificationBellLoader({super.key});

  @override
  State<NotificationBellLoader> createState() =>
      NotificationBellLoaderState();
}

class NotificationBellLoaderState
    extends State<NotificationBellLoader> {
  late final NotificationRepository repository;

  int unreadCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    repository = NotificationRepository(
      ApiClient(TokenStorage()),
    );

    loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await repository.getUnreadCount();

      if (!mounted) return;

      setState(() {
        unreadCount = count;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        unreadCount = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationBell(
      unreadCount: isLoading ? 0 : unreadCount,
         onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        ),
      );

      if (!mounted) return;

      await loadUnreadCount();
    },
    );
  }
}