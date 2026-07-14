import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/user_notification.dart';
import 'package:maintai/domain/repositories/notificationrepo.dart';
import 'package:maintai/storage/tokenStorage.dart';

class NotificationDetailsPage extends StatefulWidget {
  final String? notificationId;
  final String? feedbackId;
  final String? sessionId;

  const NotificationDetailsPage({
    super.key,
    this.notificationId,
    this.feedbackId,
    this.sessionId,
  });

  @override
  State<NotificationDetailsPage> createState() =>
      _NotificationDetailsPageState();
}

class _NotificationDetailsPageState
    extends State<NotificationDetailsPage> {
  late final NotificationRepository repository;

  UserNotification? notification;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    repository = NotificationRepository(
      ApiClient(TokenStorage()),
    );

    _load();
  }

  Future<void> _load() async {
    final id = widget.notificationId;

    if (id == null || id.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = 'Notification details are unavailable.';
      });
      return;
    }

    try {
      final result = await repository.getNotification(id);
      await repository.markAsRead(id);

      if (!mounted) return;

      setState(() {
        notification = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load notification details.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = notification;
    final isRejected = item?.type == 'feedback_rejected';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        surfaceTintColor: const Color(0xFFF8F6F1),
        title: Text(
          isRejected ? 'Revision Required' : 'Approved Solution',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF1C84B),
              ),
            )
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isRejected
                            ? const Color(0xFFFFF1F2)
                            : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isRejected
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRejected
                                ? Icons.error_outline_rounded
                                : Icons.verified_rounded,
                            color: isRejected
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item!.message,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailCard(
                      title: 'Issue',
                      text: item.question ?? '-',
                    ),
                    const SizedBox(height: 12),
                    _DetailCard(
                      title: 'Submitted Solution',
                      text: item.answer ?? '-',
                    ),
                    if ((item.managerComment ?? '').isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _DetailCard(
                        title: 'Manager Comment',
                        text: item.managerComment!,
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String text;

  const _DetailCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4DCC8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}