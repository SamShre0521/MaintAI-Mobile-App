import 'package:maintai/domain/entities/answer-source.dart';

class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final String time;
  final bool animateTyping;
  final String? sourceType;
final List<AnswerSource> sources;
final bool usedKnowledge;
final String? sourceMessage;
final List<AnswerSource> knowledgeSources;

  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.time,
    this.animateTyping = false,
    this.sourceType,
    this.sources = const [],
    this.usedKnowledge = false,
    this.sourceMessage,
    this.knowledgeSources = const [],
  });

  ChatMessage copyWith({
    String? id,
    bool? isUser,
    String? text,
    String? time,
    bool? animateTyping,
    String? sourceType,
    List<AnswerSource>? sources,
    bool? usedKnowledge,
    String? sourceMessage,
    List<AnswerSource>? knowledgeSources,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      isUser: isUser ?? this.isUser,
      text: text ?? this.text,
      time: time ?? this.time,
      animateTyping: animateTyping ?? this.animateTyping,
      sourceType: sourceType ?? this.sourceType,
      sources: sources ?? this.sources,
      usedKnowledge: usedKnowledge ?? this.usedKnowledge,
      sourceMessage: sourceMessage ?? this.sourceMessage,
      knowledgeSources: knowledgeSources ?? this.knowledgeSources,
    );
  }
}