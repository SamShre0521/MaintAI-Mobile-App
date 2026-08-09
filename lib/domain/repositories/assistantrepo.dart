import 'package:maintai/domain/entities/chat_response.dart';
import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/chat_session.dart';
import 'package:maintai/domain/entities/pending_chat_attachment.dart';

abstract class AssistantRepository {
  Future<List<Machines>> getMachines();

  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
    String? machineId,
     List<PendingChatAttachment> attachments = const [],
  });

  Future<List<ChatSession>> getSessions();

  Future<List<ChatMessage>> getSessionMessages(
    String sessionId,
  );
}