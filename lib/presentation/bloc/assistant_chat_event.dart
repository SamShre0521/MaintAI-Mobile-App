abstract class AssistantChatEvent {}

class LoadMachinesEvent extends AssistantChatEvent {}

class SelectMachineEvent extends AssistantChatEvent {
  final String machineId;

  SelectMachineEvent(this.machineId);
}

class UpdateIssueTextEvent extends AssistantChatEvent {
  final String issue;

  UpdateIssueTextEvent(this.issue);
}

class PickImageEvent extends AssistantChatEvent {
  final String imageName;

  PickImageEvent(this.imageName);
}

class RemoveImageEvent extends AssistantChatEvent {}

class SubmitIssueEvent extends AssistantChatEvent {}