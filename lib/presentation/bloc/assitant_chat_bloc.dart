import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/domain/entities/machines.dart';
import '../../domain/usecase/getMachines.dart';
import 'assistant_chat_event.dart';
import 'assistant_chat_state.dart';

class AssistantChatBloc
    extends Bloc<AssistantChatEvent, AssistantChatState> {
  final GetMachines getMachines;

  AssistantChatBloc(this.getMachines) : super(const AssistantChatState()) {
    on<LoadMachinesEvent>(_onLoadMachines);
    on<SelectMachineEvent>(_onSelectMachine);
    on<UpdateIssueTextEvent>(_onUpdateIssueText);
    on<PickImageEvent>(_onPickImage);
    on<RemoveImageEvent>(_onRemoveImage);
    on<SubmitIssueEvent>(_onSubmitIssue);
  }

  Future<void> _onLoadMachines(
    LoadMachinesEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, submitted: false));

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

  void _onUpdateIssueText(
    UpdateIssueTextEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      state.copyWith(
        issueText: event.issue,
        clearError: true,
        submitted: false,
      ),
    );
  }

  void _onPickImage(
    PickImageEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      state.copyWith(
        imageName: event.imageName,
        clearError: true,
        submitted: false,
      ),
    );
  }

  void _onRemoveImage(
    RemoveImageEvent event,
    Emitter<AssistantChatState> emit,
  ) {
    emit(
      state.copyWith(
        clearImage: true,
        clearError: true,
        submitted: false,
      ),
    );
  }

  Future<void> _onSubmitIssue(
    SubmitIssueEvent event,
    Emitter<AssistantChatState> emit,
  ) async {
    if (state.selectedMachine == null) {
      emit(state.copyWith(errorMessage: 'Please select a machine'));
      return;
    }

    if (state.issueText.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please describe the issue'));
      return;
    }

    emit(state.copyWith(isLoading: true, clearError: true, submitted: false));

    await Future.delayed(const Duration(milliseconds: 700));

    emit(
      state.copyWith(
        isLoading: false,
        submitted: true,
        errorMessage: null,
      ),
    );
  }
}