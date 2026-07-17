import 'package:maintai/ApiClient.dart';

class ResubmissionRepository {
  final ApiClient apiClient;

  ResubmissionRepository(this.apiClient);

  Future<void> resubmitFeedback({
    required String feedbackId,
    required String question,
    required String answer,
  }) async {
    await apiClient.dio.patch(
      '/feedbacks/$feedbackId/resubmit',
      data: {
        'question': question.trim(),
        'answer': answer.trim(),
      },
    );
  }
}