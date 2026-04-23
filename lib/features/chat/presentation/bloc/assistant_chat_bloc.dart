import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_chat_message.dart';
import 'assistant_chat_event.dart';
import 'assistant_chat_state.dart';

class AssistantChatBloc
    extends Bloc<AssistantChatEvent, AssistantChatState> {
  final SendChatMessage sendChatMessage;

  AssistantChatBloc(this.sendChatMessage)
      : super(AssistantChatState.initial()) {
    on<ToggleExpandedComposerEvent>((event, emit) {
      emit(state.copyWith(isExpanded: event.isExpanded, error: null));
    });

    on<SelectMachineEvent>((event, emit) {
      emit(state.copyWith(selectedMachine: event.machine, error: null));
    });

    on<PickImageEvent>((event, emit) {
      emit(state.copyWith(selectedImageName: event.imageName, error: null));
    });

    on<RemoveSelectedImageEvent>((event, emit) {
      emit(state.copyWith(selectedImageName: null, error: null));
    });

    on<StartNewChatEvent>((event, emit) {
      emit(AssistantChatState.initial());
    });

    on<FinishTypingAnimationEvent>((event, emit) {
      final updated = state.messages.map((m) {
        if (m.id == event.messageId) {
          return m.copyWith(animateTyping: false);
        }
        return m;
      }).toList();

      emit(state.copyWith(messages: updated, error: null));
    });

    on<SendChatMessageEvent>((event, emit) async {
      final text = event.message.trim();
      if (text.isEmpty) return;

      final userMessage = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        isUser: true,
        text: state.sessionId == null
            ? 'Machine: ${state.selectedMachine}\nIssue: $text'
            : text,
        time: 'Now',
      );

      emit(
        state.copyWith(
          messages: [...state.messages, userMessage],
          isExpanded: false,
          isAiTyping: true,
          error: null,
        ),
      );

      try {
        final result = await sendChatMessage(
          message: text,
          sessionId: state.sessionId,
        );

        final aiMessage = ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          isUser: false,
          text: result.reply,
          time: 'Now',
          animateTyping: true,
        );

        emit(
          state.copyWith(
            sessionId: state.sessionId ?? result.sessionId,
            messages: [...state.messages, userMessage, aiMessage],
            isAiTyping: false,
            error: null,
          ),
        );
      } catch (e) {
        final errorMessage = ChatMessage(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          isUser: false,
          text: 'Something went wrong. Please try again.',
          time: 'Now',
        );

        emit(
          state.copyWith(
            messages: [...state.messages, userMessage, errorMessage],
            isAiTyping: false,
            error: e.toString(),
          ),
        );
      }
    });
  }
}