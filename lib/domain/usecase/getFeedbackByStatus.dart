import 'package:maintai/domain/entities/feedback_isssues.dart';
import 'package:maintai/domain/repositories/managerrepo.dart';

class GetFeedbacksByStatus {
  final ManagerRepository repository;

  GetFeedbacksByStatus(this.repository);

  Future<List<FeedbackIssue>> call(String status) {
    return repository.getFeedbacksByStatus(status);
  }
}