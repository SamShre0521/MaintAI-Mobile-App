import 'package:maintai/domain/entities/feedback_conversation.dart';

class FeedbackIssue {
  final String id;
  final String sessionId;
  final String engineerId;
  final String engineerName;
  final String engineerEmail;
  final String engineerRole;
  final String question;
  final String answer;
  final String engineerFeedback;
  final String managerStatus;
  final String managerComment;
  final String department;
  final String? approvedBy;
  final String createdAt;
  final String updatedAt;
  final List<FeedbackConversationMessage> conversation;

  const FeedbackIssue({
    required this.id,
    required this.sessionId,
    required this.engineerId,
    required this.engineerName,
    required this.engineerEmail,
    required this.engineerRole,
    required this.question,
    required this.answer,
    required this.engineerFeedback,
    required this.managerStatus,
    required this.managerComment,
    required this.department,
    required this.approvedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.conversation,
  });
  
  factory FeedbackIssue.fromJson(Map<String, dynamic> json) {
  final user = json['userId'] ?? {};

  String? approvedBy;

  final approved = json['approvedBy'];

  if (approved == null) {
    approvedBy = null;
  } else if (approved is String) {
    approvedBy = approved;
  } else if (approved is Map<String, dynamic>) {
    approvedBy = approved['name'] ?? approved['_id'];
  }
  

  return FeedbackIssue(
    id: json['_id'] ?? '',
    sessionId: json['sessionId'] ?? '',
    engineerId: user['_id'] ?? '',
    engineerName: user['name'] ?? 'Unknown Engineer',
    engineerEmail: user['email'] ?? '',
    engineerRole: user['role'] ?? '',
    question: json['question'] ?? '',
    answer: json['answer'] ?? '',
    engineerFeedback: json['engineerFeedback'] ?? '',
    managerStatus: json['managerStatus'] ?? '',
    managerComment: json['managerComment'] ?? '',
    department: json['department'] ?? '',
    approvedBy: approvedBy,
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    conversation: (json['conversation'] as List<dynamic>?)
        ?.map((messageJson) => FeedbackConversationMessage(
              role: messageJson['role'] ?? '',
              content: messageJson['content'] ?? '',
              createdAt: messageJson['createdAt'],
            ))
        .toList() ??
        [],
  );
}
}

