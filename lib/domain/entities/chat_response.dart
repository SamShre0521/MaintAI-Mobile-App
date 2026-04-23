class ChatResponse {
  final String? sessionId;
  final String? title;
  final String reply;

  const ChatResponse({
    required this.sessionId,
    required this.title,
    required this.reply,
  });
}