import 'package:maintai/domain/entities/chat_response.dart';
import 'package:maintai/domain/entities/machines.dart';

abstract class AssistantRepository {
  Future<List<Machines>> getMachines();

  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  });
}