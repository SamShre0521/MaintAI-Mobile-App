import 'package:flutter/material.dart';

class UserMessageBubble extends StatelessWidget {
  final String text;
  final String time;

  const UserMessageBubble({
    super.key,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8EFCB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE4DCC8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}