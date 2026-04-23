import 'package:maintai/ApiClient.dart';
import '../models/chat_response_model.dart';

class ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSource(this.apiClient);

  Future<ChatResponseModel> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    final response = await apiClient.dio.post(
      '/chat',
      data: {
        'message': message,
        if (sessionId != null) 'sessionId': sessionId,
      },
    );

    return ChatResponseModel.fromJson(response.data);
  }
}