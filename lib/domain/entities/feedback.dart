import 'package:maintai/domain/entities/feedback_conversation.dart';

class FeedbackRequest {
  final String sessionId;
  final String question;
  final String answer;
  final String engineerFeedback;
  final List<FeedbackConversationMessage> conversation;

  const FeedbackRequest({
    required this.sessionId,
    required this.question,
    required this.answer,
    required this.engineerFeedback,
    this.conversation = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'question': question,
      'answer': answer,
      'engineerFeedback': engineerFeedback,
      'conversation': conversation
          .map((message) => message.toJson())
          .toList(),
    };
  }
}