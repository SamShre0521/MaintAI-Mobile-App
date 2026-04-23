import 'package:maintai/domain/entities/chat_response.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';

class SendChatMessage {
  final AssistantRepository repository;

  SendChatMessage(this.repository);

  Future<ChatResponse> call({
    required String message,
    String? sessionId,
  }) {
    return repository.sendMessage(
      message: message,
      sessionId: sessionId,
    );
  }
}