import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class TypewriterMarkdown extends StatefulWidget {
  final String text;
  final MarkdownStyleSheet styleSheet;
  final VoidCallback? onCompleted;

  const TypewriterMarkdown({
    super.key,
    required this.text,
    required this.styleSheet,
    this.onCompleted,
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
  int currentIndex = 0;
  late final List<int> breakpoints;

  @override
  void initState() {
    super.initState();
    breakpoints = _buildBreakpoints(widget.text);
    _startTyping();
  }

  void _startTyping() async {
    while (mounted && currentIndex < breakpoints.length - 1) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() {
        currentIndex++;
      });
    }
    widget.onCompleted?.call();
  }

  List<int> _buildBreakpoints(String text) {
    final points = <int>[0];

    for (int i = 1; i <= text.length; i++) {
      final char = text[i - 1];
      if (char == ' ' ||
          char == '\n' ||
          char == '.' ||
          char == ',' ||
          char == ':' ||
          char == ';') {
        points.add(i);
      }
    }

    if (points.last != text.length) {
      points.add(text.length);
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = widget.text.substring(0, breakpoints[currentIndex]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: visibleText,
          selectable: true,
          shrinkWrap: true,
          styleSheet: widget.styleSheet,
        ),
        const SizedBox(height: 2),
        const Text(
          '▋',
          style: TextStyle(
            color: Color(0xFFF1C84B),
            fontSize: 16,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}