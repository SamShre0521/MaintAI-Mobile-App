class UserNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? feedbackId;
  final String? sessionId;
  final String? managerComment;
  final String? question;
  final String? answer;
  final String? managerStatus;
  final String createdAt;

  const UserNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.feedbackId,
    this.sessionId,
    this.managerComment,
    this.question,
    this.answer,
    this.managerStatus,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    final rawFeedback = json['feedback'];

    final feedback = rawFeedback is Map
        ? Map<String, dynamic>.from(rawFeedback)
        : <String, dynamic>{};

    return UserNotification(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,

      feedbackId:
          feedback['_id']?.toString() ??
          json['feedbackId']?.toString(),

      sessionId:
          feedback['sessionId']?.toString() ??
          json['sessionId']?.toString(),

      question: feedback['question']?.toString(),

      answer: feedback['answer']?.toString(),

      managerStatus:
          feedback['managerStatus']?.toString(),

      managerComment:
          feedback['managerComment']?.toString(),

      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}