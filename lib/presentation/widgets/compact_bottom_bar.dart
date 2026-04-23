import 'package:flutter/material.dart';

class CompactBottomBar extends StatelessWidget {
  final VoidCallback onExpand;

  const CompactBottomBar({
    super.key,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onExpand,
          child: const Icon(Icons.add),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onExpand,
            child: const Text("Tap + to report issue"),
          ),
        ),
      ],
    );
  }
}