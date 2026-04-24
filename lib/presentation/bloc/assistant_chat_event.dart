abstract class AssistantChatEvent {}

class LoadMachinesEvent extends AssistantChatEvent {}

class ToggleExpandedComposerEvent extends AssistantChatEvent {
  final bool isExpanded;

  ToggleExpandedComposerEvent(this.isExpanded);
}

class SelectMachineEvent extends AssistantChatEvent {
  final String machineId;

  SelectMachineEvent(this.machineId);
}

class PickImageEvent extends AssistantChatEvent {
  final String imageName;

  PickImageEvent(this.imageName);
}

class RemoveImageEvent extends AssistantChatEvent {}

class SendChatMessageEvent extends AssistantChatEvent {
  final String message;

  SendChatMessageEvent(this.message);
}

class FinishTypingAnimationEvent extends AssistantChatEvent {
  final String messageId;

  FinishTypingAnimationEvent(this.messageId);
}

class StartNewChatEvent extends AssistantChatEvent {}

class LoadSessionsEvent extends AssistantChatEvent {}

class LoadSessionMessagesEvent extends AssistantChatEvent {
  final String sessionId;

  LoadSessionMessagesEvent(this.sessionId);
}