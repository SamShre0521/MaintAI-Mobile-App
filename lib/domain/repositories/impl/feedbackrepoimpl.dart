


import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/feedback.dart';
import 'package:maintai/domain/repositories/feedbackrepository.dart';

class feedbackrepoimpl implements Feedbackrepository {

  final ApiClient apiClient;

  feedbackrepoimpl({required this.apiClient});

  @override
  Future<void> sendFeedback(FeedbackRequest feedback) async {
    
    try {
         await apiClient.dio.post(
      '/feedback',
      // 
      data: feedback.toJson(),
    );
    } catch (e) {
      throw Exception('Failed to send feedback: $e');
    }
  
  
  
  }

  
}