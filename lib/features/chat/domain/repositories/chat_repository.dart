import '../entities/chat_response.dart';

abstract class ChatRepository {
  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  });
}