import '../../domain/entities/chat_message.dart';

class AssistantChatState {
  final bool isExpanded;
  final bool isAiTyping;
  final String? sessionId;
  final String selectedMachine;
  final String? selectedImageName;
  final List<String> machines;
  final List<ChatMessage> messages;
  final String? error;

  const AssistantChatState({
    required this.isExpanded,
    required this.isAiTyping,
    required this.sessionId,
    required this.selectedMachine,
    required this.selectedImageName,
    required this.machines,
    required this.messages,
    required this.error,
  });

  factory AssistantChatState.initial() {
    return AssistantChatState(
      isExpanded: false,
      isAiTyping: false,
      sessionId: null,
      selectedMachine: 'Conveyor Belt A (CB-2021-A)',
      selectedImageName: 'machine_error_photo.jpg',
      machines: const [
        'Conveyor Belt A (CB-2021-A)',
        'Conveyor Belt B (CB-2021-B)',
        'Conveyor Belt C (CB-2021-C)',
        'Conveyor Belt D (CB-2021-D)',
      ],
      messages: const [
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
      error: null,
    );
  }

  AssistantChatState copyWith({
    bool? isExpanded,
    bool? isAiTyping,
    String? sessionId,
    String? selectedMachine,
    String? selectedImageName,
    List<String>? machines,
    List<ChatMessage>? messages,
    String? error,
  }) {
    return AssistantChatState(
      isExpanded: isExpanded ?? this.isExpanded,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      sessionId: sessionId ?? this.sessionId,
      selectedMachine: selectedMachine ?? this.selectedMachine,
      selectedImageName: selectedImageName ?? this.selectedImageName,
      machines: machines ?? this.machines,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}