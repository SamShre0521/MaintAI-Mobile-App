abstract class ManagerDashboardEvent {}

class LoadManagerDashboardEvent extends ManagerDashboardEvent {}

class ApproveFeedbackEvent extends ManagerDashboardEvent {
  final String feedbackId;
  final String? managerComment;

  ApproveFeedbackEvent({
    required this.feedbackId,
    this.managerComment,
  });
}

class RejectFeedbackEvent extends ManagerDashboardEvent {
  final String feedbackId;
  final String managerComment;

  RejectFeedbackEvent({
    required this.feedbackId,
    required this.managerComment,
  });
}