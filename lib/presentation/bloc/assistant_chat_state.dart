import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/machines.dart';

class AssistantChatState {
  final bool isLoading;
  final bool isExpanded;
  final bool isAiTyping;
  final String? sessionId;
  final List<Machines> machines;
  final Machines? selectedMachine;
  final String? imageName;
  final String? errorMessage;
  final List<ChatMessage> messages;

  const AssistantChatState({
    this.isLoading = false,
    this.isExpanded = false,
    this.isAiTyping = false,
    this.sessionId,
    this.machines = const [],
    this.selectedMachine,
    this.imageName,
    this.errorMessage,
    this.messages = const [
      ChatMessage(
        id: 'welcome-user',
        isUser: true,
        text: "Hello! I'm having an issue with one of the machines.",
        time: '6:33 PM',
      ),
      ChatMessage(
        id: 'welcome-ai',
        isUser: false,
        text:
            "I can help with that. Please select the machine and describe the issue. If possible, upload a photo too.",
        time: '6:33 PM',
      ),
    ],
  });

  AssistantChatState copyWith({
    bool? isLoading,
    bool? isExpanded,
    bool? isAiTyping,
    String? sessionId,
    List<Machines>? machines,
    Machines? selectedMachine,
    String? imageName,
    String? errorMessage,
    List<ChatMessage>? messages,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return AssistantChatState(
      isLoading: isLoading ?? this.isLoading,
      isExpanded: isExpanded ?? this.isExpanded,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      sessionId: sessionId ?? this.sessionId,
      machines: machines ?? this.machines,
      selectedMachine: selectedMachine ?? this.selectedMachine,
      imageName: clearImage ? null : (imageName ?? this.imageName),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      messages: messages ?? this.messages,
    );
  }
}