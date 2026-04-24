import 'package:maintai/domain/entities/chat_session.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';

class GetSessions {
  final AssistantRepository repository;

  GetSessions(this.repository);

  Future<List<ChatSession>> call() {
    return repository.getSessions();
  }
}