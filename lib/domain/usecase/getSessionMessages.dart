import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';

class GetSessionMessages {
  final AssistantRepository repository;

  GetSessionMessages(this.repository);

  Future<List<ChatMessage>> call(String sessionId) {
    return repository.getSessionMessages(sessionId);
  }
}