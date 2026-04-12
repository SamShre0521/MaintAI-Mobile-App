
import 'package:maintai/domain/entities/machines.dart';

class AssistantChatState {
  final bool isLoading;
  final List<Machines> machines;
  final Machines? selectedMachine;
  final String issueText;
  final String? imageName;
  final String? errorMessage;
  final bool submitted;

  const AssistantChatState({
    this.isLoading = false,
    this.machines = const [],
    this.selectedMachine,
    this.issueText = '',
    this.imageName,
    this.errorMessage,
    this.submitted = false,
  });

  AssistantChatState copyWith({
    bool? isLoading,
    List<Machines>? machines,
    Machines? selectedMachine,
    String? issueText,
    String? imageName,
    String? errorMessage,
    bool? submitted,
    bool clearSelectedMachine = false,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return AssistantChatState(
      isLoading: isLoading ?? this.isLoading,
      machines: machines ?? this.machines,
      selectedMachine:
          clearSelectedMachine ? null : (selectedMachine ?? this.selectedMachine),
      issueText: issueText ?? this.issueText,
      imageName: clearImage ? null : (imageName ?? this.imageName),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      submitted: submitted ?? this.submitted,
    );
  }
}