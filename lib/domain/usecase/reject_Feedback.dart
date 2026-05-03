import 'package:maintai/domain/repositories/managerrepo.dart';

class RejectFeedback {
  final ManagerRepository repository;

  RejectFeedback(this.repository);

  Future<void> call({
    required String feedbackId,
    required String managerComment,
  }) {
    return repository.rejectFeedback(
      feedbackId: feedbackId,
      managerComment: managerComment,
    );
  }
}