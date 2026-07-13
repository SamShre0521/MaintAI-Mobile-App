class NotificationPayload {
  final String type;
  final String? notificationId;
  final String? feedbackId;
  final String? sessionId;

  const NotificationPayload({
    required this.type,
    this.notificationId,
    this.feedbackId,
    this.sessionId,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      type: map['type']?.toString() ?? '',
      notificationId: map['notificationId']?.toString(),
      feedbackId: map['feedbackId']?.toString(),
      sessionId: map['sessionId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (notificationId != null) 'notificationId': notificationId,
      if (feedbackId != null) 'feedbackId': feedbackId,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }
}