import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/domain/entities/feedback.dart';
import 'package:maintai/domain/entities/feedback_conversation.dart';
import 'package:maintai/domain/entities/machines.dart';

import 'package:maintai/domain/repositories/impl/assistantrepoimpl.dart';

import 'package:maintai/domain/usecase/getMachines.dart';
import 'package:maintai/domain/usecase/getSessionMessages.dart';
import 'package:maintai/domain/usecase/getSessions.dart';
import 'package:maintai/domain/usecase/sendChatMessage.dart';
import 'package:maintai/domain/usecase/submitFeedback.dart';

import 'assistant_chat_event.dart';
import 'assistant_chat_state.dart';

class AssistantChatBloc
    extends Bloc<AssistantChatEvent, AssistantChatState> {
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

    // Real attachment handling.
    on<AddChatAttachmentsEvent>(
      _onAddChatAttachments,
    );

    on<RemoveChatAttachmentEvent>(
      _onRemoveChatAttachment,
    );

    on<SendChatMessageEvent>(_onSendChatMessage);
    on<FinishTypingAnimationEvent>(
      _onFinishTypingAnimation,
    );

    on<StartNewChatEvent>(_onStartNewChat);
    on<LoadSessionsEvent>(_onLoadSessions);
    on<LoadSessionMessagesEvent>(
      _onLoadSessionMessages,
    );

    on<MarkIssueResolvedEvent>(
      _onMarkIssueResolved,
    );

    on<ContinueIssueEvent>(_onContinueIssue);

    on<SubmitFeedbackEvent>(
      _onSubmitFeedback,
    );
  }

  // ============================================================
  // ISSUE RESOLUTION
  // ============================================================

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

  // ============================================================
  // ATTACHMENTS
  // ============================================================

  void _onAddChatAttachments(
    AddChatAttachmentsEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    /*
     * Prevent the same local file from being added twice.
     */
    final existingPaths = state.selectedAttachments
        .map(
          (attachment) => attachment.path,
        )
        .toSet();

    final newAttachments = event.attachments
        .where(
          (attachment) =>
              !existingPaths.contains(
                attachment.path,
              ),
        )
        .toList();

    if (newAttachments.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        selectedAttachments: [
          ...state.selectedAttachments,
          ...newAttachments,
        ],
        clearError: true,
      ),
    );
  }

  void _onRemoveChatAttachment(
    RemoveChatAttachmentEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    final updatedAttachments =
        state.selectedAttachments
            .where(
              (attachment) =>
                  attachment.path != event.path,
            )
            .toList();

    emit(
      state.copyWith(
        selectedAttachments:
            updatedAttachments,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // MACHINES
  // ============================================================

  Future<void> _onLoadMachines(
    LoadMachinesEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    if (state.isLoading) {
      return;
    }

    /*
     * Machines already available.
     */
    if (state.machines.isNotEmpty) {
      if (state.selectedMachine == null) {
        emit(
          state.copyWith(
            selectedMachine:
                state.machines.first,
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
      final machines =
          await getMachines();

      debugPrint(
        'Loaded machines: '
        '${machines.map((m) => m.name).toList()}',
      );

      emit(
        state.copyWith(
          isLoading: false,
          machines: machines,
          selectedMachine:
              machines.isNotEmpty
                  ? machines.first
                  : null,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Machine loading error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          isLoading: false,
          errorMessage:
              'Failed to load machines',
        ),
      );
    }
  }

  void _onToggleExpanded(
    ToggleExpandedComposerEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      state.copyWith(
        isExpanded: event.isExpanded,
        clearError: true,
      ),
    );
  }

  void _onSelectMachine(
    SelectMachineEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    Machines? selectedMachine;

    for (final machine
        in state.machines) {
      if (machine.id == event.machineId) {
        selectedMachine = machine;
        break;
      }
    }

    if (selectedMachine == null) {
      return;
    }

    emit(
      state.copyWith(
        selectedMachine:
            selectedMachine,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // SEND CHAT MESSAGE
  // ============================================================

  Future<void> _onSendChatMessage(
    SendChatMessageEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    final text =
        event.message.trim();

    if (text.isEmpty) {
      return;
    }

    /*
     * A machine is required only when starting
     * a brand-new session.
     *
     * For continued chats the backend resolves
     * the machine from sessionId.
     */
    if (state.sessionId == null &&
        state.selectedMachine == null) {
      emit(
        state.copyWith(
          errorMessage:
              'Please select a machine',
        ),
      );

      return;
    }

    /*
     * Create the local user bubble immediately.
     */
    final userMessage = ChatMessage(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),
      isUser: true,
      text: state.sessionId == null
          ? 'Machine: '
              '${state.selectedMachine!.name} '
              '(${state.selectedMachine!.id})\n'
              'Issue: $text'
          : text,
      time: 'Now',
    );

    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          userMessage,
        ],
        isExpanded: false,
        isAiTyping: true,
        clearError: true,
      ),
    );

    try {
      /*
       * Important:
       *
       * selectedAttachments now flows:
       *
       * BLoC
       * → SendChatMessage use case
       * → AssistantRepository
       * → AssistantRepositoryImpl
       * → multipart/form-data
       * → backend /chat
       */
      final response =
          await sendChatMessage(
        message: text,
        sessionId:
            state.sessionId,
        machineId:
            state.sessionId == null
                ? state
                    .selectedMachine
                    ?.id
                : null,
        attachments:
            state.selectedAttachments,
      );

      final aiMessage = ChatMessage(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        isUser: false,
        text: response.reply,
        time: 'Now',
        animateTyping: true,
        sourceType:
            response.sourceType,
        sources:
            response.sources,
      );

      final updatedSessions =
          await getSessions();

      /*
       * Clear attachments ONLY after
       * successful upload/chat response.
       *
       * If the request fails, selected files
       * remain available for retry.
       */
      emit(
        state.copyWith(
          sessionId:
              state.sessionId ??
              response.sessionId,

          /*
           * userMessage was already inserted
           * before the API call, so only add
           * the assistant response here.
           */
          messages: [
            ...state.messages,
            aiMessage,
          ],

          isAiTyping: false,
          sessions:
              updatedSessions,
          showResolutionPrompt:
              true,
          isIssueResolved:
              false,
          clearError: true,
          isHistoryMode:
              false,

          clearSelectedAttachments:
              true,
        ),
      );
    }

    // ==========================================================
    // MACHINE VALIDATION ERROR
    // ==========================================================

    on ChatValidationException catch (e) {
      final errorReply =
          ChatMessage(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        isUser: false,
        text: e.message,
        time: 'Now',
      );

      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            errorReply,
          ],
          isAiTyping: false,
          showResolutionPrompt:
              false,
          isIssueResolved:
              false,
          clearError: true,
        ),
      );
    }

    // ==========================================================
    // DIO / BACKEND ERROR
    // ==========================================================

    on DioException catch (e) {
      final responseData =
          e.response?.data;

      String message =
          'Something went wrong. Please try again.';

      if (responseData
          is Map<String, dynamic>) {
        message =
            responseData['error']
                    ?.toString() ??
                responseData['message']
                    ?.toString() ??
                message;
      } else if (responseData is Map) {
        final data =
            Map<String, dynamic>.from(
          responseData,
        );

        message =
            data['error']
                    ?.toString() ??
                data['message']
                    ?.toString() ??
                message;
      }

      final errorReply =
          ChatMessage(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        isUser: false,
        text: message,
        time: 'Now',
      );

      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            errorReply,
          ],
          isAiTyping: false,
          errorMessage: message,
          showResolutionPrompt:
              false,
        ),
      );

      /*
       * Do NOT clear selectedAttachments here.
       * Engineer can retry the same upload.
       */
    }

    // ==========================================================
    // UNKNOWN ERROR
    // ==========================================================

    catch (e, stackTrace) {
      debugPrint(
        'Send chat message failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      final errorReply =
          ChatMessage(
        id: DateTime.now()
            .microsecondsSinceEpoch
            .toString(),
        isUser: false,
        text:
            'Something went wrong. Please try again.',
        time: 'Now',
      );

      emit(
        state.copyWith(
          messages: [
            ...state.messages,
            errorReply,
          ],
          isAiTyping: false,
          errorMessage:
              'Failed to send message',
          showResolutionPrompt:
              false,
        ),
      );
    }
  }

  // ============================================================
  // TYPING ANIMATION
  // ============================================================

  void _onFinishTypingAnimation(
    FinishTypingAnimationEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    final updatedMessages =
        state.messages.map((message) {
      if (message.id ==
          event.messageId) {
        return message.copyWith(
          animateTyping: false,
        );
      }

      return message;
    }).toList();

    emit(
      state.copyWith(
        messages: updatedMessages,
        clearError: true,
      ),
    );
  }

  // ============================================================
  // NEW CHAT
  // ============================================================

  void _onStartNewChat(
    StartNewChatEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      AssistantChatState(
        machines:
            state.machines,

        selectedMachine:
            state.machines.isNotEmpty
                ? state.machines.first
                : null,

        sessions:
            state.sessions,

        isSessionLoading:
            state.isSessionLoading,

        showResolutionPrompt:
            false,

        isIssueResolved:
            false,

        isExpanded:
            false,

        isAiTyping:
            false,

        sessionId:
            null,

        isHistoryMode:
            false,

        /*
         * New chat must not inherit
         * files selected in previous chat.
         */
        selectedAttachments:
            const [],
      ),
    );
  }

  // ============================================================
  // SESSION HISTORY
  // ============================================================

  Future<void> _onLoadSessions(
    LoadSessionsEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    if (state.isSessionLoading) {
      return;
    }

    emit(
      state.copyWith(
        isSessionLoading: true,
        clearError: true,
      ),
    );

    try {
      final sessions =
          await getSessions();

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
          errorMessage:
              'Failed to load issue history',
        ),
      );
    }
  }

  Future<void> _onLoadSessionMessages(
    LoadSessionMessagesEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    emit(
      state.copyWith(
        isAiTyping: true,
        isIssueResolved: false,
        showResolutionPrompt:
            false,
        clearError: true,
      ),
    );

    try {
      final messages =
          await getSessionMessages(
        event.sessionId,
      );

      emit(
        state.copyWith(
          sessionId:
              event.sessionId,

          messages:
              messages,

          isExpanded:
              false,

          isAiTyping:
              false,

          /*
           * Never inherit resolved state
           * from another conversation.
           */
          isIssueResolved:
              false,

          showResolutionPrompt:
              false,

          clearError:
              true,

          isHistoryMode:
              true,

          /*
           * Do not carry pending local uploads
           * when opening history.
           */
          clearSelectedAttachments:
              true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Failed to load chat messages: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          isAiTyping:
              false,

          isIssueResolved:
              false,

          showResolutionPrompt:
              false,

          errorMessage:
              'Failed to load chat messages',
        ),
      );
    }
  }

  // ============================================================
  // FEEDBACK
  // ============================================================

  Future<void> _onSubmitFeedback(
    SubmitFeedbackEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    try {
      if (state.sessionId == null) {
        return;
      }

      if (state.messages.length < 2) {
        return;
      }

      final actualUserMessages =
          state.messages
              .where(
                (message) =>
                    message.isUser &&
                    message.id !=
                        'welcome-user',
              )
              .toList();

      if (actualUserMessages.isEmpty) {
        emit(
          state.copyWith(
            errorMessage:
                'No issue message found',
          ),
        );

        return;
      }

      final actualUserMessage =
          actualUserMessages.last;

      final aiMessages =
          state.messages
              .where(
                (message) =>
                    !message.isUser &&
                    message.id !=
                        'welcome-ai',
              )
              .toList();

      if (aiMessages.isEmpty) {
        emit(
          state.copyWith(
            errorMessage:
                'No AI response found',
          ),
        );

        return;
      }

      final lastAiMessage =
          aiMessages.last;

      final conversation =
          state.messages
              .where(
                (message) =>
                    message.id !=
                    'welcome-ai',
              )
              .where(
                (message) =>
                    message.id !=
                    'welcome-user',
              )
              .map(
                (message) =>
                    FeedbackConversationMessage(
                  role:
                      message.isUser
                          ? 'user'
                          : 'assistant',

                  content:
                      message.isUser
                          ? _extractIssueText(
                              message.text,
                            )
                          : message.text,
                ),
              )
              .toList();

      await submitFeedback(
        FeedbackRequest(
          sessionId:
              state.sessionId!,

          question:
              _extractIssueText(
            actualUserMessage.text,
          ),

          answer:
              lastAiMessage.text,

          engineerFeedback:
              event.resolved
                  ? 'correct'
                  : 'incorrect',

          conversation:
              conversation,
        ),
      );

      emit(
        state.copyWith(
          isIssueResolved:
              event.resolved,

          showResolutionPrompt:
              false,

          isExpanded:
              false,

          clearError:
              true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Submit feedback failed: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      emit(
        state.copyWith(
          errorMessage:
              'Failed to submit feedback',
        ),
      );
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _extractIssueText(
    String text,
  ) {
    const issueMarker =
        'Issue:';

    if (text.contains(
      issueMarker,
    )) {
      return text
          .substring(
            text.indexOf(
                  issueMarker,
                ) +
                issueMarker.length,
          )
          .trim();
    }

    return text.trim();
  }
}