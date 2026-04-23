import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/presentation/bloc/assistant_chat_event.dart';
import 'package:maintai/presentation/bloc/assistant_chat_state.dart';
import 'package:maintai/presentation/bloc/assitant_chat_bloc.dart';
import 'package:maintai/presentation/pages/app_sidebar.dart';
import 'package:maintai/presentation/widgets/animated_message_wrapper.dart';
import 'package:maintai/presentation/widgets/typewriter_markdown_widget.dart';
import 'package:maintai/presentation/widgets/typing_bubble_widget.dart';
import 'package:maintai/presentation/widgets/welcome_widget.dart';
import 'package:maintai/presentation/widgets/user_message_bubble.dart';
import 'package:maintai/presentation/widgets/ai_message_bubble.dart';
import 'package:maintai/presentation/widgets/compact_bottom_bar.dart';
import 'package:maintai/presentation/widgets/expanded_issue_card.dart';

class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({super.key});

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  final TextEditingController issueController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    issueController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _sendMessage() {
    final text = issueController.text.trim();
    if (text.isEmpty) return;

    context.read<AssistantChatBloc>().add(SendChatMessageEvent(text));
    issueController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssistantChatBloc, AssistantChatState>(
      listener: (context, state) {
        _scrollToBottom();

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F6F1),
          drawer: const AppSidebar(),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F6F1),
            elevation: 0,
            surfaceTintColor: const Color(0xFFF8F6F1),
            centerTitle: true,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Color(0xFF2E2E2E),
                  size: 28,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(
              'SmartAssist',
              style: TextStyle(
                color: Color(0xFF2E2E2E),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF2E2E2E),
                  size: 28,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: state.messages.length + 2 + (state.isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          const WelcomeCard(),
                          const SizedBox(height: 18),
                        ],
                      );
                    }

                    final adjustedIndex = index - 1;

                    if (adjustedIndex < state.messages.length) {
                      final ChatMessage msg = state.messages[adjustedIndex];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AnimatedMessageWrapper(
                          key: ValueKey(msg.id),
                          child: msg.isUser
                              ? UserMessageBubble(
                                  text: msg.text,
                                  time: msg.time,
                                )
                              : AiMessageBubble(
                                  message: msg,
                                  onTypingCompleted: () {
                                    context.read<AssistantChatBloc>().add(
                                          FinishTypingAnimationEvent(msg.id),
                                        );
                                  },
                                ),
                        ),
                      );
                    }

                    if (state.isAiTyping && adjustedIndex == state.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: const TypingBubble(),
                      );
                    }

                    return const SizedBox(height: 90);
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: MediaQuery.of(context).padding.bottom + 10,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE4DCC8)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                // child: state.sessionId == null
                //     ? (state.isExpanded
                //         ? _expandedBottomCard(
                //             key: const ValueKey('expanded'),
                //             state: state,
                //           )
                //         : _compactBottomBar(
                //             key: const ValueKey('compact'),
                //           ))
                //     : _chatInputBar(
                //         key: const ValueKey('chat'),
                //       ),
                child: state.sessionId == null
    ? (state.isExpanded
        ? ExpandedIssueCard(
            key: const ValueKey('expanded'),
            state: state,
            controller: issueController,
            onSend: _sendMessage,
          )
        : CompactBottomBar(
            key: const ValueKey('compact'),
            onExpand: () {
              context.read<AssistantChatBloc>().add(
                    ToggleExpandedComposerEvent(true),
                  );
            },
          ))
    : _chatInputBar(
        key: const ValueKey('chat'),
      ),
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF7D7D7D),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _chatInputBar({Key? key}) {
    return Row(
      key: key,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE4DCC8)),
            ),
            child: TextField(
              controller: issueController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _sendMessage,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1C84B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

