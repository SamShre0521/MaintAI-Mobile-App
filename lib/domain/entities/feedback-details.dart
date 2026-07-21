class FeedbackConversationItem {
  final String role;
  final String content;
  final String? createdAt;

  const FeedbackConversationItem({
    required this.role,
    required this.content,
    this.createdAt,
  });

  factory FeedbackConversationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return FeedbackConversationItem(
      role: json['role']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class FeedbackDetails {
  final String id;
  final String sessionId;
  final String question;
  final String answer;
  final String engineerFeedback;
  final String managerStatus;
  final String managerComment;
  final int revisionNumber;
  final String? approvedByName;
  final String? createdAt;
  final String? updatedAt;
  final List<FeedbackConversationItem> conversation;

  const FeedbackDetails({
    required this.id,
    required this.sessionId,
    required this.question,
    required this.answer,
    required this.engineerFeedback,
    required this.managerStatus,
    required this.managerComment,
    required this.revisionNumber,
    required this.conversation,
    this.approvedByName,
    this.createdAt,
    this.updatedAt,
  });

  factory FeedbackDetails.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawApprovedBy = json['approvedBy'];

    final approvedBy = rawApprovedBy is Map
        ? Map<String, dynamic>.from(rawApprovedBy)
        : <String, dynamic>{};

    final rawConversation = json['conversation'];

    return FeedbackDetails(
      id: json['_id']?.toString() ?? '',
      sessionId: json['sessionId']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
      engineerFeedback:
          json['engineerFeedback']?.toString() ?? '',
      managerStatus:
          json['managerStatus']?.toString() ?? 'pending',
      managerComment:
          json['managerComment']?.toString() ?? '',
      revisionNumber:
          (json['revisionNumber'] as num?)?.toInt() ?? 1,
      approvedByName: approvedBy['name']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      conversation: rawConversation is List
          ? rawConversation
                .whereType<Map>()
                .map(
                  (item) =>
                      FeedbackConversationItem.fromJson(
                        Map<String, dynamic>.from(item),
                      ),
                )
                .toList()
          : const [],
    );
  }
}