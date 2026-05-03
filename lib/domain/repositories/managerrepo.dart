
import 'package:maintai/domain/entities/feedback_isssues.dart';

abstract class ManagerRepository {
  Future<List<FeedbackIssue>> getPendingFeedbacks();

  Future<void> approveFeedback({
    required String feedbackId,
    String? managerComment,
  });

  Future<void> rejectFeedback({
    required String feedbackId,
    required String managerComment,
  });
}