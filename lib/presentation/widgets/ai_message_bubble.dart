import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
      p: const TextStyle(fontSize: 16, height: 1.45),
      strong: const TextStyle(fontWeight: FontWeight.bold),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.smart_toy_outlined),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE4DCC8)),
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
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message.time,
                      style: const TextStyle(fontSize: 12),
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