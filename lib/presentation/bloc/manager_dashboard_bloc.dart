import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/usecase/approve_Feedback.dart';
import 'package:maintai/domain/usecase/getPendingFeedbacks.dart';
import 'package:maintai/domain/usecase/getSessions.dart';
import 'package:maintai/domain/usecase/reject_Feedback.dart';
import 'manager_dashboard_event.dart';
import 'manager_dashboard_state.dart';
import 'package:maintai/domain/usecase/getFeedbackByStatus.dart';

class ManagerDashboardBloc
    extends Bloc<ManagerDashboardEvent, ManagerDashboardState> {
  final GetPendingFeedbacks getPendingFeedbacks;
  final ApproveFeedback approveFeedback;
  final RejectFeedback rejectFeedback;
  final GetFeedbacksByStatus getFeedbackByStatus;
  final GetSessions getSessions;
  ManagerDashboardBloc({
    required this.getPendingFeedbacks,
    required this.approveFeedback,
    required this.rejectFeedback,
    required this.getFeedbackByStatus,
    required this.getSessions,
  }) : super(const ManagerDashboardState()) {
    on<LoadManagerDashboardEvent>(_onLoadDashboard);
    on<ApproveFeedbackEvent>(_onApproveFeedback);
    on<RejectFeedbackEvent>(_onRejectFeedback);
  }

  Future<void> _onLoadDashboard(
  LoadManagerDashboardEvent event,
  Emitter<ManagerDashboardState> emit,
) async {
  emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));

  try {
    final pending = await getPendingFeedbacks.repository.getFeedbacksByStatus('pending');
    final approved = await getPendingFeedbacks.repository.getFeedbacksByStatus('approved');
    final sessions = await getSessions();

    emit(
      state.copyWith(
        isLoading: false,
        pendingFeedbacks: pending,
        approvedFeedbacks: approved,
        clearError: true,
        sessions: sessions,
      ),
    );
  } catch (e) {
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard',
      ),
    );
  }
}

  Future<void> _onApproveFeedback(
    ApproveFeedbackEvent event,
    Emitter<ManagerDashboardState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));

    try {
      await approveFeedback(
        feedbackId: event.feedbackId,
        managerComment: event.managerComment,
      );

      final updatedFeedbacks = await getPendingFeedbacks();

      emit(
        state.copyWith(
          isActionLoading: false,
          pendingFeedbacks: updatedFeedbacks,
          successMessage: 'Issue approved and stored in knowledge base',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to approve issue',
        ),
      );
    }
  }

  Future<void> _onRejectFeedback(
    RejectFeedbackEvent event,
    Emitter<ManagerDashboardState> emit,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));

    try {
      await rejectFeedback(
        feedbackId: event.feedbackId,
        managerComment: event.managerComment,
      );

      final updatedFeedbacks = await getPendingFeedbacks();

      emit(
        state.copyWith(
          isActionLoading: false,
          pendingFeedbacks: updatedFeedbacks,
          successMessage: 'Issue rejected',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: 'Failed to reject issue',
        ),
      );
    }
  }
}