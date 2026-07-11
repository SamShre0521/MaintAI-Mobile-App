
import 'package:maintai/domain/entities/answer-source.dart';

class ChatResponse {
  final String? sessionId;
  final String? title;
  final String reply;
  final String sourceType;
  final List<AnswerSource> sources;

  const ChatResponse({
    required this.sessionId,
    required this.title,
    required this.reply,
    this.sourceType = 'general_ai',
    this.sources = const [],
  });
}