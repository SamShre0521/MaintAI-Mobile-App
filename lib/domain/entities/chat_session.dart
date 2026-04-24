class ChatSession {
  final String id;
  final String sessionId;
  final String title;
  final String createdAt;
  final String updatedAt;

  const ChatSession({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      title: json['title'] ?? 'Untitled chat',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}