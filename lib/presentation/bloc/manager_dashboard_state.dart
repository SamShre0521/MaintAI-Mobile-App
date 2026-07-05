import 'package:maintai/domain/entities/chat_session.dart';
import 'package:maintai/domain/entities/feedback_isssues.dart';

class ManagerDashboardState {
  final bool isLoading;
  final bool isActionLoading;
  final List<FeedbackIssue> pendingFeedbacks;
  final List<FeedbackIssue> approvedFeedbacks;
  final String? errorMessage;
  final String? successMessage;
  final List<ChatSession> sessions;

  const ManagerDashboardState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.pendingFeedbacks = const [],
    this.approvedFeedbacks = const [],
    this.errorMessage,
    this.successMessage,
    this.sessions = const [],
  });

  int get pendingCount => pendingFeedbacks.length;
  int get approvedCount => approvedFeedbacks.length;
  int get totalFeedbacks => pendingFeedbacks.length + approvedFeedbacks.length;

  //  ManagerDashboardState copyWith({
  //   bool? isLoading,
  //   bool? isActionLoading,
  //   List<FeedbackIssue>? pendingFeedbacks,
  //   List<FeedbackIssue>? approvedFeedbacks,
  //   String? errorMessage,
  //   String? successMessage,
  //   bool clearError = false,
  //   bool clearSuccess = false,
  // }) {
  //   return ManagerDashboardState(
  //     isLoading: isLoading ?? this.isLoading,
  //     isActionLoading: isActionLoading ?? this.isActionLoading,
  //     pendingFeedbacks: pendingFeedbacks ?? this.pendingFeedbacks,
  //     approvedFeedbacks: approvedFeedbacks ?? this.approvedFeedbacks,
  //     errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  //     successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
  //   );
  // }
  ManagerDashboardState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<FeedbackIssue>? pendingFeedbacks,
    List<FeedbackIssue>? approvedFeedbacks,
    List<ChatSession>? sessions,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ManagerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      pendingFeedbacks: pendingFeedbacks ?? this.pendingFeedbacks,
      approvedFeedbacks: approvedFeedbacks ?? this.approvedFeedbacks,
      sessions: sessions ?? this.sessions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
