class ChatMessage {
  final bool isUser;
  final String text;
  final String time;
  final bool animateTyping;

  const ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.animateTyping = false,
  });
}