import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/presentation/bloc/assistant_chat_event.dart';
import 'package:maintai/presentation/bloc/assistant_chat_state.dart';
import 'package:maintai/presentation/bloc/assitant_chat_bloc.dart';

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
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF1C84B),
              size: 26,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Report an issue',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<AssistantChatBloc>().add(
                      ToggleExpandedComposerEvent(false),
                    );
              },
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _label('Select Machine'),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F1DD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4DCC8)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedMachine?.id,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: state.machines.map((machine) {
                return DropdownMenuItem<String>(
                  value: machine.id,
                  child: Text(
                    '${machine.name} (${machine.id})',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<AssistantChatBloc>().add(
                        SelectMachineEvent(value),
                      );
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 14),

        _label('Describe the issue'),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type issue here...',
            hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
            filled: true,
            fillColor: const Color(0xFFF8F6F1),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFF1C84B)),
            ),
          ),
        ),

        const SizedBox(height: 14),

        _label('Upload image'),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: () {
            context.read<AssistantChatBloc>().add(
                  PickImageEvent('machine_error_photo.jpg'),
                );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F1DD),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4DCC8)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF8D8D8D),
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.imageName ?? 'Tap to upload image',
                    style: TextStyle(
                      fontSize: 16,
                      color: state.imageName == null
                          ? const Color(0xFF9A9A9A)
                          : const Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                if (state.imageName != null)
                  IconButton(
                    onPressed: () {
                      context.read<AssistantChatBloc>().add(RemoveImageEvent());
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF555555),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1C84B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.send_rounded),
            label: const Text(
              'Send',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
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
}