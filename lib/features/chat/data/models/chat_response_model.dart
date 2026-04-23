import '../../domain/entities/chat_response.dart';

class ChatResponseModel extends ChatResponse {
  ChatResponseModel({
    required super.sessionId,
    required super.title,
    required super.reply,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatResponseModel(
      sessionId: json['sessionId'],
      title: json['title'],
      reply: json['reply'] ?? '',
    );
  }
}