import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/feedback_isssues.dart';
import 'package:maintai/domain/repositories/managerrepo.dart';

class ManagerRepositoryImpl implements ManagerRepository {
  final ApiClient apiClient;

  ManagerRepositoryImpl(this.apiClient);

  @override
  Future<List<FeedbackIssue>> getPendingFeedbacks() async {
    final response = await apiClient.dio.get('/manager/feedback/pending');

    final List feedbacks = response.data['feedbacks'] ?? [];

    return feedbacks.map((json) => FeedbackIssue.fromJson(json)).toList();
  }

  // @override
  // Future<void> approveFeedback({
  //   required String feedbackId,
  //   String? managerComment,
  // }) async {
  //   await apiClient.dio.patch(
  //     '/feedbacks/$feedbackId/approve',
  //     data: {
  //       'managerComment': managerComment ?? '',
  //     },
  //   );
  // }

  // @override
  // Future<void> rejectFeedback({
  //   required String feedbackId,
  //   required String managerComment,
  // }) async {
  //   await apiClient.dio.patch(
  //     '/feedbacks/$feedbackId/reject',
  //     data: {
  //       'managerComment': managerComment,
  //     },
  //   );
  // }
  @override
  Future<void> approveFeedback({
    required String feedbackId,
    String? managerComment,
  }) async {
    await apiClient.dio.patch(
      '/manager/feedback/$feedbackId',
      data: {
        'managerStatus': 'approved',
        'managerComment': managerComment ?? 'Valid solution',
      },
    );
  }

  @override
  Future<void> rejectFeedback({
    required String feedbackId,
    required String managerComment,
  }) async {
    await apiClient.dio.patch(
      '/manager/feedback/$feedbackId',
      data: {'managerStatus': 'rejected', 'managerComment': managerComment},
    );
  }
}
