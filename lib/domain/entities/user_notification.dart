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
    final feedback = json['feedback'];

    final feedbackMap = feedback is Map
        ? Map<String, dynamic>.from(feedback)
        : <String, dynamic>{};

    return UserNotification(
      id: json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isRead: json['isRead'] == true,
      feedbackId:
          json['feedbackId']?.toString() ??
          feedbackMap['_id']?.toString(),
      sessionId:
          json['sessionId']?.toString() ??
          feedbackMap['sessionId']?.toString(),
      managerComment:
          feedbackMap['managerComment']?.toString(),
      question: feedbackMap['question']?.toString(),
      answer: feedbackMap['answer']?.toString(),
      managerStatus:
          feedbackMap['managerStatus']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}