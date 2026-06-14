class FeedbackRequest {
  final String sessionId;
  final String question;
  final String answer;
  final String engineerFeedback;

  FeedbackRequest({
    required this.sessionId,
    required this.question,
    required this.answer,
    required this.engineerFeedback,
  });
}