import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maintai/domain/entities/feedback-details.dart';
import 'package:maintai/presentation/pages/edit_rejected_feedback_page.dart';

class FeedbackDetailsPage extends StatelessWidget {
  final FeedbackDetails feedback;

  const FeedbackDetailsPage({
    super.key,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    final status = feedback.managerStatus.toLowerCase();

    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';
    final isPending = !isApproved && !isRejected;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        surfaceTintColor: const Color(0xFFF8F6F1),
        elevation: 0,
        title: Text(
          isApproved
              ? 'Approved Solution'
              : isRejected
                  ? 'Revision Required'
                  : 'Pending Review',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          30,
        ),
        children: [
          _StatusBanner(
            status: status,
            managerComment: feedback.managerComment,
          ),

          const SizedBox(height: 16),

          _TextCard(
            title: 'Issue',
            text: feedback.question,
          ),

          const SizedBox(height: 12),

          _MarkdownCard(
            title: 'Submitted Solution',
            text: feedback.answer,
          ),

          if (feedback.managerComment.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _TextCard(
              title: 'Manager Comment',
              text: feedback.managerComment,
            ),
          ],

          if (feedback.conversation.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text(
              'Complete Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            ...feedback.conversation.map(
              (message) => _ConversationBubble(
                message: message,
              ),
            ),
          ],

          if (feedback.revisionNumber > 1) ...[
            const SizedBox(height: 12),
            Text(
              'Revision ${feedback.revisionNumber}',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          if (isRejected) ...[
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result =
                      await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditRejectedFeedbackPage(
                        feedbackId: feedback.id,
                        question: feedback.question,
                        answer: feedback.answer,
                        managerComment:
                            feedback.managerComment,
                      ),
                    ),
                  );

                  if (result == true &&
                      context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit & Resubmit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFF1C84B),
                  foregroundColor:
                      const Color(0xFF111827),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: 18),
            const Text(
              'The manager has not reviewed this submission yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;
  final String managerComment;

  const _StatusBanner({
    required this.status,
    required this.managerComment,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final background = isApproved
        ? const Color(0xFFF0FDF4)
        : isRejected
            ? const Color(0xFFFFF1F2)
            : const Color(0xFFFFFBEB);

    final border = isApproved
        ? const Color(0xFFBBF7D0)
        : isRejected
            ? const Color(0xFFFCA5A5)
            : const Color(0xFFFDE68A);

    final foreground = isApproved
        ? const Color(0xFF16A34A)
        : isRejected
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);

    final icon = isApproved
        ? Icons.verified_rounded
        : isRejected
            ? Icons.error_outline_rounded
            : Icons.schedule_rounded;

    final text = isApproved
        ? 'Your troubleshooting solution was approved and stored in the MaintAI knowledge base.'
        : isRejected
            ? managerComment.trim().isEmpty
                ? 'This solution requires revision.'
                : 'This solution requires revision.'
            : 'Your solution is waiting for manager review.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String title;
  final String text;

  const _TextCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            text.isEmpty ? '-' : text,
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

class _MarkdownCard extends StatelessWidget {
  final String title;
  final String text;

  const _MarkdownCard({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          MarkdownBody(
            data: text.isEmpty ? '-' : text,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationBubble extends StatelessWidget {
  final FeedbackConversationItem message;

  const _ConversationBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFFFFF4C7)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE4DCC8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? 'Engineer' : 'MaintAI',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            isUser
                ? Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                    ),
                  )
                : MarkdownBody(
                    data: message.content,
                    selectable: true,
                  ),
          ],
        ),
      ),
    );
  }
}