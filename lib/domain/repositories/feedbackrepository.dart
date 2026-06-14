
import 'package:maintai/domain/entities/feedback.dart';

abstract class Feedbackrepository{

  Future<void> sendFeedback(FeedbackRequest feedback);
}