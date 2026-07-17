import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/repositories/resubmission_resportitory.dart';
import 'package:maintai/storage/tokenStorage.dart';

class EditRejectedFeedbackPage extends StatefulWidget {
  final String feedbackId;
  final String question;
  final String answer;
  final String? managerComment;

  const EditRejectedFeedbackPage({
    super.key,
    required this.feedbackId,
    required this.question,
    required this.answer,
    this.managerComment,
  });

  @override
  State<EditRejectedFeedbackPage> createState() =>
      _EditRejectedFeedbackPageState();
}

class _EditRejectedFeedbackPageState
    extends State<EditRejectedFeedbackPage> {
  late final TextEditingController questionController;
  late final TextEditingController answerController;
  late final ResubmissionRepository repository;

  bool isSubmitting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    questionController = TextEditingController(
      text: widget.question,
    );

    answerController = TextEditingController(
      text: widget.answer,
    );

    repository = ResubmissionRepository(
      ApiClient(TokenStorage()),
    );
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  Future<void> _resubmit() async {
    final question = questionController.text.trim();
    final answer = answerController.text.trim();

    if (question.isEmpty || answer.isEmpty) {
      setState(() {
        errorMessage = 'Issue and solution cannot be empty.';
      });
      return;
    }

    setState(() {
      isSubmitting = true;
      errorMessage = null;
    });

    try {
      await repository.resubmitFeedback(
        feedbackId: widget.feedbackId,
        question: question,
        answer: answer,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solution resubmitted for manager review',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
        errorMessage = 'Failed to resubmit solution: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        surfaceTintColor: const Color(0xFFF8F6F1),
        title: const Text(
          'Edit & Resubmit',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((widget.managerComment ?? '').trim().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFCA5A5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Manager Comment',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.managerComment!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Text(
              'Issue',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: questionController,
              enabled: !isSubmitting,
              readOnly: false,
              minLines: 3,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: _inputDecoration(
                hint: 'Describe the issue',
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Corrected Solution',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: answerController,
              enabled: !isSubmitting,
              readOnly: false,
              minLines: 10,
              maxLines: 18,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: _inputDecoration(
                hint: 'Edit the solution before resubmitting',
              ),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _resubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(
                  isSubmitting
                      ? 'Resubmitting...'
                      : 'Resubmit for Review',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1C84B),
                  foregroundColor: const Color(0xFF111827),
                  disabledBackgroundColor:
                      const Color(0xFFE8D996),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE4DCC8),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFE4DCC8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFF1C84B),
          width: 2,
        ),
      ),
    );
  }
}