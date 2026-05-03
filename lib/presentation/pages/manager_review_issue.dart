import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/feedback_isssues.dart';
import 'package:maintai/presentation/bloc/manager_dashboard_bloc.dart';
import 'package:maintai/presentation/bloc/manager_dashboard_event.dart';
import 'package:maintai/presentation/bloc/manager_dashboard_state.dart';

class ManagerReviewIssuePage extends StatefulWidget {
  final FeedbackIssue feedback;

  const ManagerReviewIssuePage({
    super.key,
    required this.feedback,
  });

  @override
  State<ManagerReviewIssuePage> createState() => _ManagerReviewIssuePageState();
}

class _ManagerReviewIssuePageState extends State<ManagerReviewIssuePage> {
  final TextEditingController commentController = TextEditingController(
    text: 'Valid solution',
  );

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  List<ChatMessage> get conversationMessages {
    return [
      ChatMessage(
        id: '${widget.feedback.id}-question',
        isUser: true,
        text: widget.feedback.question,
        time: 'Question',
      ),
      ChatMessage(
        id: '${widget.feedback.id}-answer',
        isUser: false,
        text: widget.feedback.answer,
        time: 'AI Answer',
      ),
      ChatMessage(
        id: '${widget.feedback.id}-feedback',
        isUser: true,
        text: 'Engineer feedback: ${widget.feedback.engineerFeedback}',
        time: 'Feedback',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagerDashboardBloc, ManagerDashboardState>(
      listener: (context, state) {
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );

          Navigator.pop(context);
        }

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F6F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F6F1),
            elevation: 0,
            surfaceTintColor: const Color(0xFFF8F6F1),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF111827),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Review Issue',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _StatusChip(
                  text: widget.feedback.managerStatus.isEmpty
                      ? 'Pending'
                      : widget.feedback.managerStatus,
                  color: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
            children: [
              _IssueHeader(feedback: widget.feedback),
              const SizedBox(height: 18),
              const Text(
                'Conversation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...conversationMessages.map((message) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: message.isUser
                      ? _ReviewUserBubble(message: message)
                      : _ReviewAiBubble(message: message),
                );
              }),
              const SizedBox(height: 10),
              _FeedbackMarker(feedback: widget.feedback),
              const SizedBox(height: 18),
              _AiResolutionCard(text: widget.feedback.answer),
              const SizedBox(height: 14),
              _ManagerCommentBox(controller: commentController),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE4DCC8))),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () {
                              commentController.text =
                                  'Need more details from engineer';
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Request more info flow will be added later',
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.info_outline_rounded, size: 18),
                      label: const Text('More Info'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E2E2E),
                        side: const BorderSide(color: Color(0xFFE4DCC8)),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () {
                              final comment =
                                  commentController.text.trim().isEmpty
                                      ? 'Solution rejected'
                                      : commentController.text.trim();

                              context.read<ManagerDashboardBloc>().add(
                                    RejectFeedbackEvent(
                                      feedbackId: widget.feedback.id,
                                      managerComment: comment,
                                    ),
                                  );
                            },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: state.isActionLoading
                          ? null
                          : () {
                              final comment =
                                  commentController.text.trim().isEmpty
                                      ? 'Valid solution'
                                      : commentController.text.trim();

                              context.read<ManagerDashboardBloc>().add(
                                    ApproveFeedbackEvent(
                                      feedbackId: widget.feedback.id,
                                      managerComment: comment,
                                    ),
                                  );
                            },
                      icon: state.isActionLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_rounded, size: 19),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IssueHeader extends StatelessWidget {
  final FeedbackIssue feedback;

  const _IssueHeader({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4DCC8)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 27,
                backgroundColor: Color(0xFFFFF7ED),
                child: Icon(
                  Icons.pending_actions_rounded,
                  color: Color(0xFFF97316),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  feedback.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.person_outline_rounded,
                title: 'Engineer',
                value: feedback.engineerName,
              ),
              _InfoChip(
                icon: Icons.email_outlined,
                title: 'Email',
                value: feedback.engineerEmail,
              ),
              _InfoChip(
                icon: Icons.business_rounded,
                title: 'Department',
                value: feedback.department,
              ),
              _InfoChip(
                icon: Icons.flag_outlined,
                title: 'Status',
                value: feedback.managerStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewUserBubble extends StatelessWidget {
  final ChatMessage message;

  const _ReviewUserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8EFCB),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE4DCC8)),
        ),
        child: _BubbleContent(message: message),
      ),
    );
  }
}

class _ReviewAiBubble extends StatelessWidget {
  final ChatMessage message;

  const _ReviewAiBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFF3E8FF),
          child: Icon(
            Icons.smart_toy_outlined,
            color: Color(0xFF6D28D9),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE4DCC8)),
            ),
            child: _BubbleContent(message: message),
          ),
        ),
      ],
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;

  const _BubbleContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            message.time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedbackMarker extends StatelessWidget {
  final FeedbackIssue feedback;

  const _FeedbackMarker({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final isCorrect = feedback.engineerFeedback.toLowerCase() == 'correct';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCorrect ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            color: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFF97316),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Engineer marked this answer as: ${feedback.engineerFeedback}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiResolutionCard extends StatelessWidget {
  final String text;

  const _AiResolutionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF8B5CF6),
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MarkdownBody(
              data: '### AI Answer\n\n$text',
              styleSheet: MarkdownStyleSheet(
                h3: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
                p: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF111827),
                ),
                listBullet: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerCommentBox extends StatelessWidget {
  final TextEditingController controller;

  const _ManagerCommentBox({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4DCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manager Comment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add your comment...',
              filled: true,
              fillColor: const Color(0xFFF8F6F1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF1C84B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: color, size: 16),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}