import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/feedback.dart';
import 'package:maintai/domain/entities/machines.dart';
import 'package:maintai/domain/usecase/getMachines.dart';
import 'package:maintai/domain/usecase/sendChatMessage.dart';
import 'package:maintai/domain/usecase/submitFeedback.dart';
import 'assistant_chat_event.dart';
import 'assistant_chat_state.dart';
import 'package:maintai/domain/usecase/getSessions.dart';
import 'package:maintai/domain/usecase/getSessionMessages.dart';
import 'package:flutter/foundation.dart';

class AssistantChatBloc extends Bloc<AssistantChatEvent, AssistantChatState> {
  final GetMachines getMachines;
  final SendChatMessage sendChatMessage;
  final GetSessions getSessions;
  final GetSessionMessages getSessionMessages;
  final SubmitFeedback submitFeedback;
  AssistantChatBloc({
    required this.getMachines,
    required this.sendChatMessage,
    required this.getSessions,
    required this.getSessionMessages,
    required this.submitFeedback,
  }) : super(const AssistantChatState()) {
    on<LoadMachinesEvent>(_onLoadMachines);
    on<ToggleExpandedComposerEvent>(_onToggleExpanded);
    on<SelectMachineEvent>(_onSelectMachine);
    on<PickImageEvent>(_onPickImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SendChatMessageEvent>(_onSendChatMessage);
    on<FinishTypingAnimationEvent>(_onFinishTypingAnimation);
    on<StartNewChatEvent>(_onStartNewChat);
    on<LoadSessionsEvent>(_onLoadSessions);
    on<LoadSessionMessagesEvent>(_onLoadSessionMessages);
    on<MarkIssueResolvedEvent>(_onMarkIssueResolved);
    on<ContinueIssueEvent>(_onContinueIssue);
    on<SubmitFeedbackEvent>(_onSubmitFeedback);
  }

  void _onMarkIssueResolved(
    MarkIssueResolvedEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      state.copyWith(
        isIssueResolved: true,
        showResolutionPrompt: false,
        isExpanded: false,
        clearError: true,
      ),
    );
  }
  void _onContinueIssue(
    ContinueIssueEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      state.copyWith(
        showResolutionPrompt: false,
        isIssueResolved: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedbackEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    try {
      if (state.sessionId == null) return;
      if (state.messages.length < 2) return;

      final firstUserMessage = state.messages.firstWhere((m) => m.isUser);

      final lastAiMessage = state.messages.lastWhere((m) => !m.isUser);

      await submitFeedback(
        FeedbackRequest(
          sessionId: state.sessionId!,
          question: firstUserMessage.text,
          answer: lastAiMessage.text,
          engineerFeedback: event.resolved ? "correct" : "incorrect",
        ),
      );

      emit(
        state.copyWith(
          isIssueResolved: event.resolved,
          showResolutionPrompt: false,
          isExpanded: false,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to submit feedback'));
    }
  }

  Future<void> _onLoadMachines(
  LoadMachinesEvent event,
  Emitter<AssistantChatState> emit,
) async {
  if (state.isLoading) return;

  if (state.machines.isNotEmpty) {
    if (state.selectedMachine == null) {
      emit(
        state.copyWith(
          selectedMachine: state.machines.first,
          clearError: true,
        ),
      );
    }
    return;
  }

  emit(
    state.copyWith(
      isLoading: true,
      clearError: true,
    ),
  );

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
  } catch (e, stackTrace) {
    debugPrint('Failed to load machines: $e');
    debugPrintStack(stackTrace: stackTrace);

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

  void _onPickImage(PickImageEvent event, Emitter<AssistantChatState> emit) {
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
      // final response = await sendChatMessage(
      //   message: text,
      //   sessionId: state.sessionId,
      // );

      final response = await sendChatMessage(
        message: text,
        sessionId: state.sessionId,
        machineId: state.sessionId == null ? state.selectedMachine?.id : null,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: false,
        text: response.reply,
        time: 'Now',
        animateTyping: true,
        sourceType: response.sourceType,
        sources: response.sources,
      );
      final updatedSessions = await getSessions();

      emit(
        state.copyWith(
          sessionId: state.sessionId ?? response.sessionId,
          messages: [...state.messages, userMessage, aiMessage],
          isAiTyping: false,
          sessions: updatedSessions,
          showResolutionPrompt: true,
          isIssueResolved: false,
          clearError: true,
          isHistoryMode: false,
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

  //   void _onStartNewChat(
  //   StartNewChatEvent event,
  //   Emitter<AssistantChatState> emit,
  // ) {
  //   emit(
  //     AssistantChatState(
  //       machines: state.machines,
  //       selectedMachine: state.machines.isNotEmpty ? state.machines.first : null,
  //       sessions: state.sessions,
  //       isSessionLoading: state.isSessionLoading,
  //       showResolutionPrompt: false,
  //       isIssueResolved: false,
  //       isExpanded: false,
  //       isAiTyping: false,
  //       sessionId: null,
  //     ),
  //   );
  // }

  void _onStartNewChat(
    StartNewChatEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      AssistantChatState(
        machines: state.machines,
        selectedMachine: state.machines.isNotEmpty
            ? state.machines.first
            : null,
        sessions: state.sessions,
        isSessionLoading: state.isSessionLoading,
        showResolutionPrompt: false,
        isIssueResolved: false,
        isExpanded: false,
        isAiTyping: false,
        sessionId: null,
        isHistoryMode: false,
      ),
    );
  }

  Future<void> _onLoadSessions(
  LoadSessionsEvent event,
  Emitter<AssistantChatState> emit,
) async {
  if (state.isSessionLoading) return;

  emit(
    state.copyWith(
      isSessionLoading: true,
      clearError: true,
    ),
  );

  try {
    final sessions = await getSessions();

    emit(
      state.copyWith(
        isSessionLoading: false,
        sessions: sessions,
        clearError: true,
      ),
    );
  } catch (e) {
    emit(
      state.copyWith(
        isSessionLoading: false,
        errorMessage: 'Failed to load issue history',
      ),
    );
  }
}

  Future<void> _onLoadSessionMessages(
    LoadSessionMessagesEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    emit(state.copyWith(isAiTyping: true, clearError: true));

    try {
      final messages = await getSessionMessages(event.sessionId);

      emit(
        state.copyWith(
          sessionId: event.sessionId,
          messages: messages,
          isExpanded: false,
          isAiTyping: false,
          clearError: true,
          isHistoryMode: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isAiTyping: false,
          errorMessage: 'Failed to load chat messages',
        ),
      );
    }
  }
}
