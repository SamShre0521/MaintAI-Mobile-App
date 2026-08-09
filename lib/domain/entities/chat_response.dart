import 'package:maintai/domain/entities/answer-source.dart';

class ChatAttachmentResponse {
  final String id;
  final String originalName;
  final String mimeType;
  final String attachmentType;
  final int size;
  final String processingStatus;
  final String knowledgeStatus;
  final bool hasExtractedText;

  const ChatAttachmentResponse({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.attachmentType,
    required this.size,
    required this.processingStatus,
    required this.knowledgeStatus,
    required this.hasExtractedText,
  });

  factory ChatAttachmentResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatAttachmentResponse(
      id: json['id']?.toString() ?? '',
      originalName:
          json['originalName']?.toString() ?? '',
      mimeType:
          json['mimeType']?.toString() ?? '',
      attachmentType:
          json['attachmentType']?.toString() ?? '',
      size: json['size'] is int
          ? json['size']
          : int.tryParse(
                json['size']?.toString() ?? '',
              ) ??
              0,
      processingStatus:
          json['processingStatus']?.toString() ?? '',
      knowledgeStatus:
          json['knowledgeStatus']?.toString() ?? '',
      hasExtractedText:
          json['hasExtractedText'] == true,
    );
  }
}

class ChatResponse {
  final String? sessionId;
  final String? title;
  final String reply;

  final String sourceType;
  final String sourceMessage;

  final List<AnswerSource> sources;

  final List<ChatAttachmentResponse>
      attachments;

  const ChatResponse({
    required this.sessionId,
    required this.title,
    required this.reply,
    this.sourceType = 'general_ai',
    this.sourceMessage = '',
    this.sources = const [],
    this.attachments = const [],
  });
}