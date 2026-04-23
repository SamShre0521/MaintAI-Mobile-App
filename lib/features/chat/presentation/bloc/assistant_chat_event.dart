abstract class AssistantChatEvent {}

class InitializeChatEvent extends AssistantChatEvent {}

class ToggleExpandedComposerEvent extends AssistantChatEvent {
  final bool isExpanded;

  ToggleExpandedComposerEvent(this.isExpanded);
}

class SelectMachineEvent extends AssistantChatEvent {
  final String machine;

  SelectMachineEvent(this.machine);
}

class RemoveSelectedImageEvent extends AssistantChatEvent {}

class PickImageEvent extends AssistantChatEvent {
  final String imageName;

  PickImageEvent(this.imageName);
}

class SendChatMessageEvent extends AssistantChatEvent {
  final String message;

  SendChatMessageEvent(this.message);
}

class FinishTypingAnimationEvent extends AssistantChatEvent {
  final String messageId;

  FinishTypingAnimationEvent(this.messageId);
}

class StartNewChatEvent extends AssistantChatEvent {}