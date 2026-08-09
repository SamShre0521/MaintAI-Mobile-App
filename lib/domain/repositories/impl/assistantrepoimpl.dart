import 'package:dio/dio.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/answer-source.dart';
import 'package:maintai/domain/entities/chat_response.dart';
import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/entities/pending_chat_attachment.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/chat_session.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final ApiClient apiClient;

  AssistantRepositoryImpl(this.apiClient);

  @override
  Future<List<Machines>> getMachines() async {
    final response = await apiClient.dio.get('/machines');

    final List<dynamic> machines = response.data['machines'] ?? [];

    return machines
        .map((json) => Machines.fromJson(json))
        .where((machine) => machine.id.isNotEmpty && machine.name.isNotEmpty)
        .toList();
  }

//   @override
//   Future<ChatResponse> sendMessage({
//     required String message,
//     String? sessionId,
//     String? machineId,
//   }) async {
//     // final response = await apiClient.dio.post(
//     //   '/chat',
//     //   data: {
//     //     'message': message,
//     //     if (sessionId != null) 'sessionId': sessionId,
//     //     if (machineId != null) 'machineId': machineId,
//     //   },
//     // );

//     // final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);

//     // final dynamic rawSources = data['sources'];

//     // final List<AnswerSource> parsedSources = rawSources is List
//     //     ? rawSources
//     //           .whereType<Map>()
//     //           .map(
//     //             (item) =>
//     //                 AnswerSource.fromJson(Map<String, dynamic>.from(item)),
//     //           )
//     //           .toList()
//     //     : <AnswerSource>[];

//     // return ChatResponse(
//     //   sessionId: data['sessionId']?.toString(),
//     //   title: data['title']?.toString(),
//     //   reply: data['reply']?.toString() ?? '',
//     //   sourceType: data['sourceType']?.toString() ?? 'general_ai',
//     //   sources: parsedSources,
//     // );

//     final response = await apiClient.dio.post(
//   '/chat',
//   data: {
//     'message': message,
//     if (sessionId != null) 'sessionId': sessionId,
//     if (machineId != null) 'machineId': machineId,
//   },
// );

// final Map<String, dynamic> data =
//     Map<String, dynamic>.from(response.data);

// // Important:
// // Backend sometimes returns HTTP 200 with an "error" field
// // instead of a normal chat response.
// final backendError = data['error']?.toString();

// if (backendError != null && backendError.trim().isNotEmpty) {
//   throw ChatValidationException(backendError);
// }

// final dynamic rawSources =
//     data['sources'] ?? data['knowledgeSources'];

// final List<AnswerSource> parsedSources = rawSources is List
//     ? rawSources
//         .whereType<Map>()
//         .map(
//           (item) => AnswerSource.fromJson(
//             Map<String, dynamic>.from(item),
//           ),
//         )
//         .toList()
//     : <AnswerSource>[];

// return ChatResponse(
//   sessionId: data['sessionId']?.toString(),
//   title: data['title']?.toString(),
//   reply: data['reply']?.toString() ?? '',
//   sourceType:
//       data['sourceType']?.toString() ?? 'general_ai',
//   sources: parsedSources,
// );
//   }


  @override
Future<ChatResponse> sendMessage({
  required String message,
  String? sessionId,
  String? machineId,
  List<PendingChatAttachment> attachments = const [],
}) async {
  /*
   * If there are no attachments, keep using the existing JSON request.
   * This avoids changing the working chat flow unnecessarily.
   */
  if (attachments.isEmpty) {
    final response = await apiClient.dio.post(
      '/chat',
      data: {
        'message': message,
        if (sessionId != null) 'sessionId': sessionId,
        if (machineId != null) 'machineId': machineId,
      },
    );

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(response.data);

    final dynamic rawSources = data['knowledgeSources'];

    final List<AnswerSource> parsedSources =
        rawSources is List
            ? rawSources
                .whereType<Map>()
                .map(
                  (item) => AnswerSource.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
            : <AnswerSource>[];

    final dynamic rawAttachments = data['attachments'];

    final List<ChatAttachmentResponse> parsedAttachments =
        rawAttachments is List
            ? rawAttachments
                .whereType<Map>()
                .map(
                  (item) => ChatAttachmentResponse.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
            : <ChatAttachmentResponse>[];

    return ChatResponse(
      sessionId: data['sessionId']?.toString(),
      title: data['title']?.toString(),
      reply: data['reply']?.toString() ?? '',
      sourceType:
          data['sourceType']?.toString() ?? 'general_ai',
      sourceMessage:
          data['sourceMessage']?.toString() ?? '',
      sources: parsedSources,
      attachments: parsedAttachments,
    );
  }

  /*
   * If attachments are present, send multipart/form-data.
   */
  final multipartFiles = <MultipartFile>[];

  for (final attachment in attachments) {
    multipartFiles.add(
      await MultipartFile.fromFile(
        attachment.path,
        filename: attachment.name,
      ),
    );
  }

  final formData = FormData.fromMap({
    'message': message,
    if (sessionId != null) 'sessionId': sessionId,
    if (machineId != null) 'machineId': machineId,
    'files': multipartFiles,
  });

  final response = await apiClient.dio.post(
    '/chat',
    data: formData,
  );

  final Map<String, dynamic> data =
      Map<String, dynamic>.from(response.data);

  final dynamic rawSources = data['knowledgeSources'];

  final List<AnswerSource> parsedSources =
      rawSources is List
          ? rawSources
              .whereType<Map>()
              .map(
                (item) => AnswerSource.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <AnswerSource>[];

  final dynamic rawAttachments = data['attachments'];

  final List<ChatAttachmentResponse> parsedAttachments =
      rawAttachments is List
          ? rawAttachments
              .whereType<Map>()
              .map(
                (item) => ChatAttachmentResponse.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <ChatAttachmentResponse>[];

  return ChatResponse(
    sessionId: data['sessionId']?.toString(),
    title: data['title']?.toString(),
    reply: data['reply']?.toString() ?? '',
    sourceType:
        data['sourceType']?.toString() ?? 'general_ai',
    sourceMessage:
        data['sourceMessage']?.toString() ?? '',
    sources: parsedSources,
    attachments: parsedAttachments,
  );
}
  @override
  Future<List<ChatSession>> getSessions() async {
    final response = await apiClient.dio.get('/sessions');

    final List sessions = response.data['sessions'] ?? [];

    return sessions.map((json) => ChatSession.fromJson(json)).toList();
  }

  @override
  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    final response = await apiClient.dio.get('/sessions/$sessionId/messages');

    final List messages = response.data['messages'] ?? [];

    return messages.map((json) {
      return ChatMessage(
        id: json['_id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: json['role'] == 'user',
        text: json['content'] ?? '',
        time: 'History',
        animateTyping: false,
      );
    }).toList();
  }

  
}

class ChatValidationException implements Exception {
  final String message;

  ChatValidationException(this.message);

  @override
  String toString() => message;
}