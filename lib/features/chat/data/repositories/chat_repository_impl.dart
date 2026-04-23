import '../../domain/entities/chat_response.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<ChatResponse> sendMessage({
    required String message,
    String? sessionId,
  }) {
    return remoteDataSource.sendMessage(
      message: message,
      sessionId: sessionId,
    );
  }
}