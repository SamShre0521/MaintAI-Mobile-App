import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/usecase/getMachines.dart';
import 'package:maintai/domain/usecase/sendChatMessage.dart';
import 'assistant_chat_event.dart';
import 'assistant_chat_state.dart';

class AssistantChatBloc extends Bloc<AssistantChatEvent, AssistantChatState> {
  final GetMachines getMachines;
  final SendChatMessage sendChatMessage;

  AssistantChatBloc({
    required this.getMachines,
    required this.sendChatMessage,
  }) : super(const AssistantChatState()) {
    on<LoadMachinesEvent>(_onLoadMachines);
    on<ToggleExpandedComposerEvent>(_onToggleExpanded);
    on<SelectMachineEvent>(_onSelectMachine);
    on<PickImageEvent>(_onPickImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SendChatMessageEvent>(_onSendChatMessage);
    on<FinishTypingAnimationEvent>(_onFinishTypingAnimation);
    on<StartNewChatEvent>(_onStartNewChat);
  }

  Future<void> _onLoadMachines(
    LoadMachinesEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final machines = await getMachines();

      emit(
        state.copyWith(
          isLoading: false,
          machines: machines,
          selectedMachine: machines.isNotEmpty ? machines.first : null,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load machines',
        ),
      );
    }
  }

  void _onToggleExpanded(
    ToggleExpandedComposerEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(state.copyWith(isExpanded: event.isExpanded, clearError: true));
  }

  void _onSelectMachine(
    SelectMachineEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    final Machines? machine = state.machines
        .where((m) => m.id == event.machineId)
        .cast<Machines?>()
        .firstOrNull;

    if (machine != null) {
      emit(state.copyWith(selectedMachine: machine, clearError: true));
    }
  }

  void _onPickImage(
    PickImageEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(state.copyWith(imageName: event.imageName, clearError: true));
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(state.copyWith(clearImage: true, clearError: true));
  }

  Future<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    final text = event.message.trim();
    if (text.isEmpty) return;

    if (state.sessionId == null && state.selectedMachine == null) {
      emit(state.copyWith(errorMessage: 'Please select a machine'));
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      isUser: true,
      text: state.sessionId == null
          ? 'Machine: ${state.selectedMachine!.name} (${state.selectedMachine!.id})\nIssue: $text'
          : text,
      time: 'Now',
    );

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        isExpanded: false,
        isAiTyping: true,
        clearError: true,
      ),
    );

    try {
      final response = await sendChatMessage(
        message: text,
        sessionId: state.sessionId,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        text: response.reply,
        time: 'Now',
        animateTyping: true,
      );

      emit(
        state.copyWith(
          sessionId: state.sessionId ?? response.sessionId,
          messages: [...state.messages, userMessage, aiMessage],
          isAiTyping: false,
          clearError: true,
        ),
      );
    } catch (e) {
      final errorReply = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        text: 'Something went wrong. Please try again.',
        time: 'Now',
      );

      emit(
        state.copyWith(
          messages: [...state.messages, userMessage, errorReply],
          isAiTyping: false,
          errorMessage: 'Failed to send message',
        ),
      );
    }
  }

  void _onFinishTypingAnimation(
    FinishTypingAnimationEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    final updatedMessages = state.messages.map((message) {
      if (message.id == event.messageId) {
        return message.copyWith(animateTyping: false);
      }
      return message;
    }).toList();

    emit(state.copyWith(messages: updatedMessages, clearError: true));
  }

  void _onStartNewChat(
    StartNewChatEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      AssistantChatState(
        machines: state.machines,
        selectedMachine: state.machines.isNotEmpty ? state.machines.first : null,
      ),
    );
  }
}