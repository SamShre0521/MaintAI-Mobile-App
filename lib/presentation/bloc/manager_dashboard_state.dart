import 'package:maintai/domain/entities/feedback_isssues.dart';

class ManagerDashboardState {
  final bool isLoading;
  final bool isActionLoading;
  final List<FeedbackIssue> pendingFeedbacks;
  final String? errorMessage;
  final String? successMessage;

  const ManagerDashboardState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.pendingFeedbacks = const [],
    this.errorMessage,
    this.successMessage,
  });

  int get totalChats => pendingFeedbacks.length;
  int get pendingCount =>
      pendingFeedbacks.where((f) => f.managerStatus == 'pending').length;
  int get approvedCount =>
      pendingFeedbacks.where((f) => f.managerStatus == 'approved').length;

  ManagerDashboardState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<FeedbackIssue>? pendingFeedbacks,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ManagerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      pendingFeedbacks: pendingFeedbacks ?? this.pendingFeedbacks,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}