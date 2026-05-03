import 'package:maintai/domain/entities/feedback_isssues.dart';
import 'package:maintai/domain/repositories/managerrepo.dart';

class GetPendingFeedbacks {
  final ManagerRepository repository;

  GetPendingFeedbacks(this.repository);

  Future<List<FeedbackIssue>> call() {
    return repository.getPendingFeedbacks();
  }
}