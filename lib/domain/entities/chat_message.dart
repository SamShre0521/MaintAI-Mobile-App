class _ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final String time;
  bool animateTyping;

  _ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.time,
    this.animateTyping = false,
  });
}