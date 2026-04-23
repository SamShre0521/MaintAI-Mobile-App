import 'package:flutter/material.dart';

class AnimatedMessageWrapper extends StatefulWidget {
  final Widget child;

  const AnimatedMessageWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedMessageWrapper> createState() => _AnimatedMessageWrapperState();
}

class _AnimatedMessageWrapperState extends State<AnimatedMessageWrapper> {
  double opacity = 0;
  double translateY = 12;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 20), () {
      if (!mounted) return;
      setState(() {
        opacity = 1;
        translateY = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, translateY, 0),
        child: widget.child,
      ),
    );
  }
}