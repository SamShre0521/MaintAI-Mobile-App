import 'package:maintai/domain/entities/chat_response.dart';
import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/chat_session.dart';

abstract class AssistantRepository {
  Future<List<Machines>> getMachines();

  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  });

  Future<List<ChatSession>> getSessions();

  Future<List<ChatMessage>> getSessionMessages(String sessionId);
}