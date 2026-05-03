import 'package:maintai/domain/repositories/managerrepo.dart';

class ApproveFeedback {
  final ManagerRepository repository;

  ApproveFeedback(this.repository);

  Future<void> call({
    required String feedbackId,
    String? managerComment,
  }) {
    return repository.approveFeedback(
      feedbackId: feedbackId,
      managerComment: managerComment,
    );
  }
}