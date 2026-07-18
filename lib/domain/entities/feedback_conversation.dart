class FeedbackConversationMessage {
  final String role;
  final String content;
  final String? createdAt;

  const FeedbackConversationMessage({
    required this.role,
    required this.content,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}