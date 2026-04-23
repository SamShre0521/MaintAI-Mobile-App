import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/chat_response.dart';
import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/repositories/assistantrepo.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final ApiClient apiClient;

  AssistantRepositoryImpl(this.apiClient);

  @override
  Future<List<Machines>> getMachines() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      Machines(id: 'CB-2021-A', name: 'Conveyor Belt A'),
      Machines(id: 'CB-2021-B', name: 'Conveyor Belt B'),
      Machines(id: 'CB-2021-C', name: 'Conveyor Belt C'),
      Machines(id: 'CB-2021-D', name: 'Conveyor Belt D'),
    ];
  }

  @override
  Future<ChatResponse> sendMessage({
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

    final data = response.data;

    return ChatResponse(
      sessionId: data['sessionId'],
      title: data['title'],
      reply: data['reply'] ?? '',
    );
  }
}