import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maintai/domain/entities/pending_chat_attachment.dart';
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
    debugPrint(
      'ExpandedIssueCard: '
      'loading=${state.isLoading}, '
      'machines=${state.machines.length}, '
      'selected=${state.selectedMachine?.name}, '
      'attachments=${state.selectedAttachments.length}',
    );

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        /*
         * ==========================================================
         * HEADER
         * ==========================================================
         */
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
                context
                    .read<AssistantChatBloc>()
                    .add(
                      ToggleExpandedComposerEvent(
                        false,
                      ),
                    );
              },
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        /*
         * ==========================================================
         * MACHINE SELECTION
         * ==========================================================
         */
        _label('Select Machine'),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F1DD),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4DCC8),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.machines.any(
                (machine) =>
                    machine.id ==
                    state.selectedMachine?.id,
              )
                  ? state.selectedMachine?.id
                  : null,
              isExpanded: true,
              hint: Text(
                state.isLoading
                    ? 'Loading machines...'
                    : state.machines.isEmpty
                        ? 'No machines available'
                        : 'Select machine',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9A9A9A),
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
              ),
              items: state.machines.map(
                (machine) {
                  return DropdownMenuItem<String>(
                    value: machine.id,
                    child: Text(
                      machine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  );
                },
              ).toList(),
              onChanged: state.machines.isEmpty
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }

                      context
                          .read<AssistantChatBloc>()
                          .add(
                            SelectMachineEvent(
                              value,
                            ),
                          );
                    },
            ),
          ),
        ),

        const SizedBox(height: 14),

        /*
         * ==========================================================
         * ISSUE DESCRIPTION
         * ==========================================================
         */
        _label('Describe the issue'),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type issue here...',
            hintStyle: const TextStyle(
              color: Color(0xFF9A9A9A),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F6F1),
            contentPadding:
                const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4DCC8),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFE4DCC8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFFF1C84B),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        /*
         * ==========================================================
         * ATTACHMENTS
         * ==========================================================
         */
        _label('Add supporting files'),

        const SizedBox(height: 4),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Add an error photo, scanned manual page, or PDF if available.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF9A9A9A),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /*
         * Attachment picker button.
         */
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _pickAttachments(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F1DD),
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE4DCC8),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.attach_file_rounded,
                  color: Color(0xFF8D8D8D),
                  size: 26,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add image or PDF',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Color(0xFFF1C84B),
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        /*
         * Selected file previews.
         */
        if (state.selectedAttachments.isNotEmpty) ...[
          const SizedBox(height: 10),

          Column(
            children: state.selectedAttachments
                .map(
                  (attachment) =>
                      _attachmentCard(
                    context,
                    attachment,
                  ),
                )
                .toList(),
          ),
        ],

        const SizedBox(height: 16),

        /*
         * ==========================================================
         * SEND BUTTON
         * ==========================================================
         */
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed:
                state.isAiTyping ? null : onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFF1C84B),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFFE0D3A8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),
            ),
            icon: state.isAiTyping
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.send_rounded,
                  ),
            label: Text(
              state.isAiTyping
                  ? 'Sending...'
                  : 'Send',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /*
   * ============================================================
   * FILE PICKER
   * ============================================================
   *
   * Current chat backend supports images/PDF attachments.
   *
   * We allow multiple files so an engineer can attach:
   *
   * - machine error photo
   * - scanned manual page
   * - PDF document
   */
  Future<void> _pickAttachments(
    BuildContext context,
  ) async {
    try {
      final result =
          await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const [
          'jpg',
          'jpeg',
          'png',
          'pdf',
        ],
      );

      if (result == null) {
        return;
      }

      final attachments = result.files
          .where(
            (file) =>
                file.path != null &&
                file.path!.trim().isNotEmpty,
          )
          .map(
            (file) =>
                PendingChatAttachment(
              path: file.path!,
              name: file.name,
            ),
          )
          .toList();

      if (attachments.isEmpty) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      context
          .read<AssistantChatBloc>()
          .add(
            AddChatAttachmentsEvent(
              attachments,
            ),
          );
    } catch (e) {
      debugPrint(
        'Attachment picker error: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to select the file. Please try again.',
          ),
        ),
      );
    }
  }

  /*
   * ============================================================
   * SELECTED ATTACHMENT CARD
   * ============================================================
   */
  Widget _attachmentCard(
    BuildContext context,
    PendingChatAttachment attachment,
  ) {
    final isPdf =
        attachment.name
            .toLowerCase()
            .endsWith('.pdf');

    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4DCC8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F1DD),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined,
              color: isPdf
                  ? const Color(0xFFB75B52)
                  : const Color(0xFF7F8058),
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E2E2E),
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPdf
                      ? 'PDF document'
                      : 'Image attachment',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D8D8D),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            tooltip: 'Remove attachment',
            visualDensity:
                VisualDensity.compact,
            onPressed: () {
              context
                  .read<AssistantChatBloc>()
                  .add(
                    RemoveChatAttachmentEvent(
                      attachment.path,
                    ),
                  );
            },
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(
    String text,
  ) {
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