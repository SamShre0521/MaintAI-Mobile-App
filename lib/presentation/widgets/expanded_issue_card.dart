import 'package:flutter/material.dart';
import 'package:maintai/presentation/bloc/assistant_chat_state.dart';

class ExpandedIssueCard extends StatelessWidget {
  final AssistantChatState state;
  final TextEditingController controller;
  final VoidCallback onSend;

  const ExpandedIssueCard({
    super.key,
    required this.state,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: state.selectedMachine?.id,
          items: state.machines.map((m) {
            return DropdownMenuItem(
              value: m.id,
              child: Text(m.name),
            );
          }).toList(),
          onChanged: (_) {},
        ),
        TextField(controller: controller),
        ElevatedButton(onPressed: onSend, child: const Text("Send")),
      ],
    );
  }
}