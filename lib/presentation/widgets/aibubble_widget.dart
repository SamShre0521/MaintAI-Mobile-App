import 'package:flutter/material.dart';

Widget AiBubble({
    required String text,
    required String time,
    bool animateTyping = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFE4DCC8)),
              ),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFF2E2E2E),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  animateTyping
                      ? TypewriterText(
                          text: text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: Color(0xFF2E2E2E),
                          ),
                        )
                      : Text(
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
          ),
        ],
      ),
    );
  }
