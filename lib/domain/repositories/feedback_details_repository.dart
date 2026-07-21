import 'package:dio/dio.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/feedback-details.dart';

class FeedbackDetailsRepository {
  final ApiClient apiClient;

  FeedbackDetailsRepository(this.apiClient);

  Future<FeedbackDetails?> getBySessionId(
    String sessionId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/feedback/session/$sessionId',
      );

      final rawFeedback = response.data['feedback'];

      if (rawFeedback is! Map) {
        return null;
      }

      return FeedbackDetails.fromJson(
        Map<String, dynamic>.from(rawFeedback),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }
}