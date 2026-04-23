class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final String time;
  final bool animateTyping;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.time,
    this.animateTyping = false,
  });

  ChatMessage copyWith({
    String? id,
    bool? isUser,
    String? text,
    String? time,
    bool? animateTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      time: time ?? this.time,
      animateTyping: animateTyping ?? this.animateTyping,
    );
  }
}