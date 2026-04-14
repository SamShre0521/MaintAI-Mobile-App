import 'package:flutter/material.dart';

Widget CompactBottomBar({Key? key}) {
    return Row(
      key: key,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = true;
            });
          },
          child: AnimatedScale(
            scale: isExpanded ? 0.95 : 1,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF737373),
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = true;
              });
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Tap + to report issue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF1C84B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
