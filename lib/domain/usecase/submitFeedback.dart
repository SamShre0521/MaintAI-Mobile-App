
import 'package:flutter/widgets.dart';
import 'package:maintai/domain/entities/feedback.dart';
import 'package:maintai/domain/repositories/feedbackrepository.dart';
import 'package:maintai/domain/repositories/impl/feedbackrepoimpl.dart';

class SubmitFeedback {


  final Feedbackrepository feedbackrepository;
  

  SubmitFeedback({required this.feedbackrepository});
  Future<void> call(FeedbackRequest feedback) async {
    await feedbackrepository.sendFeedback(feedback);
  }
}
