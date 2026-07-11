import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maintai/domain/entities/answer-source.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'typewriter_markdown_widget.dart';

class AiMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onTypingCompleted;

  const AiMessageBubble({
    super.key,
    required this.message,
    required this.onTypingCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final markdownStyle = MarkdownStyleSheet(
      p: const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF2E2E2E),
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
      h1: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
      h2: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
      listBullet: const TextStyle(
        fontSize: 16,
        color: Color(0xFF2E2E2E),
      ),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE4DCC8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  message.animateTyping
                      ? TypewriterMarkdown(
                          key: ValueKey(message.id),
                          text: message.text,
                          styleSheet: markdownStyle,
                          onCompleted: onTypingCompleted,
                        )
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: markdownStyle,
                        ),

                  if (!message.animateTyping) ...[
                    const SizedBox(height: 12),
                    _AnswerSourceCard(message: message),
                  ],

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerSourceCard extends StatelessWidget {
  final ChatMessage message;

  const _AnswerSourceCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final sourceType = message.sourceType?.toLowerCase() ?? 'general_ai';

    final sourceUi = _resolveSourceUi(sourceType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sourceUi.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sourceUi.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                sourceUi.icon,
                size: 18,
                color: sourceUi.iconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sourceUi.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: sourceUi.iconColor,
                  ),
                ),
              ),
            ],
          ),

          if (message.sourceMessage != null &&
              message.sourceMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              message.sourceMessage!,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: Color(0xFF4B5563),
              ),
            ),
          ],

          if (message.knowledgeSources.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...message.knowledgeSources.map(
              (source) => _SourceItem(source: source),
            ),
          ],
        ],
      ),
    );
  }

  _SourceUi _resolveSourceUi(String sourceType) {
    switch (sourceType) {
  case 'internal_knowledge':
  case 'machine_document':
  case 'machine_manual':
  case 'manual':
    return const _SourceUi(
      title: 'Source: MaintAI Internal Knowledge',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF7C6A24),
      backgroundColor: Color(0xFFFFFBEB),
      borderColor: Color(0xFFFDE68A),
    );

  case 'approved_knowledge_base':
  case 'approved_feedback':
  case 'knowledge_base':
    return const _SourceUi(
      title: 'Source: Approved Knowledge Base',
      icon: Icons.verified_rounded,
      iconColor: Color(0xFF15803D),
      backgroundColor: Color(0xFFF0FDF4),
      borderColor: Color(0xFFBBF7D0),
    );

  case 'mixed':
    return const _SourceUi(
      title: 'Source: Internal Knowledge + Knowledge Base',
      icon: Icons.library_books_rounded,
      iconColor: Color(0xFF6D28D9),
      backgroundColor: Color(0xFFFAF5FF),
      borderColor: Color(0xFFE9D5FF),
    );

  default:
    return const _SourceUi(
      title: 'Source: General AI Knowledge',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFB45309),
      backgroundColor: Color(0xFFFFF7ED),
      borderColor: Color(0xFFFED7AA),
    );

    }
  }
}

class _SourceItem extends StatelessWidget {
  final AnswerSource source;

  const _SourceItem({
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    final hasFileName = source.fileName.trim().isNotEmpty;
    final hasMachineName = source.machineName.trim().isNotEmpty;
    final hasType = source.type.trim().isNotEmpty;

    if (!hasFileName && !hasMachineName && !hasType) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasMachineName)
            _SourceRow(
              label: 'Machine',
              value: source.machineName,
            ),

          if (hasFileName) ...[
            if (hasMachineName) const SizedBox(height: 5),
            _SourceRow(
              label: 'File',
              value: source.fileName,
            ),
          ],

          if (hasType) ...[
            if (hasMachineName || hasFileName) const SizedBox(height: 5),
            _SourceRow(
              label: 'Type',
              value: source.type,
            ),
          ],

          if (source.score != null) ...[
            const SizedBox(height: 5),
            _SourceRow(
              label: 'Match',
              value: '${(source.score! * 100).toStringAsFixed(0)}%',
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final String label;
  final String value;

  const _SourceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SourceUi {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  const _SourceUi({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}