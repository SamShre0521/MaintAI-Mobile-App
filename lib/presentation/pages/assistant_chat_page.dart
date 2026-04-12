import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/presentation/bloc/assitant_chat_bloc.dart';
import 'package:maintai/presentation/pages/app_sidebar.dart';
import 'package:maintai/theme/app_colors.dart';


import '../bloc/assistant_chat_event.dart';
import '../bloc/assistant_chat_state.dart';


class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({super.key});

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  final TextEditingController issueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AssistantChatBloc>().add(LoadMachinesEvent());
  }

  @override
  void dispose() {
    issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssistantChatBloc, AssistantChatState>(
      listener: (context, state) {
        if (state.submitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue submitted successfully')),
          );
        }

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors1.background,
        drawer: const AppSidebar(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors1.background,
          surfaceTintColor: AppColors1.background,
          iconTheme: const IconThemeData(color: AppColors1.primaryText),
          title: const Text(
            'SmartAssist',
            style: TextStyle(
              color: AppColors1.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: BlocBuilder<AssistantChatBloc, AssistantChatState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        _headerCard(),
                        const SizedBox(height: 14),
                        _aiBubble('Hello! How can I assist you today?'),
                        const SizedBox(height: 12),
                        _userBubble("Hello! I'm having an issue with one of the machines."),
                        const SizedBox(height: 12),
                        _aiBubble(
                          'I can help with that. Please select the machine and describe the issue.',
                        ),
                        const SizedBox(height: 16),
                        _reportIssueCard(context, state),
                      ],
                    ),
                  ),
                ),
                _bottomMessageBar(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors1.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors1.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors1.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors1.yellowLight,
            child: Icon(Icons.smart_toy_outlined, color: AppColors1.primaryText),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to MaintAI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors1.primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'How can I assist you today?',
                  style: TextStyle(
                    color: AppColors1.secondaryText,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _aiBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors1.aiBubble,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors1.border),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors1.primaryText,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors1.userBubble,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors1.border),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors1.primaryText,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _reportIssueCard(BuildContext context, AssistantChatState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors1.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors1.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors1.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors1.yellowPrimary),
              SizedBox(width: 8),
              Text(
                'Report an issue',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors1.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Select Machine',
            style: TextStyle(
              fontSize: 15,
              color: AppColors1.secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors1.yellowLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors1.border),
            ),
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: state.selectedMachine?.id,
                      hint: const Text('Select machine'),
                      items: state.machines.map((machine) {
                        return DropdownMenuItem<String>(
                          value: machine.id,
                          child: Text('${machine.name} (${machine.id})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          context
                              .read<AssistantChatBloc>()
                              .add(SelectMachineEvent(value));
                        }
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Describe the issue',
            style: TextStyle(
              fontSize: 15,
              color: AppColors1.secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: issueController,
            maxLines: 4,
            onChanged: (value) {
              context.read<AssistantChatBloc>().add(UpdateIssueTextEvent(value));
            },
            decoration: InputDecoration(
              hintText: 'Describe the issue...',
              filled: true,
              fillColor: AppColors1.surface,
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors1.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors1.yellowPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload image',
            style: TextStyle(
              fontSize: 15,
              color: AppColors1.secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () {
              context
                  .read<AssistantChatBloc>()
                  .add(PickImageEvent('machine_error_photo.jpg'));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors1.yellowLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors1.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.camera_alt_outlined, color: AppColors1.icon),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.imageName ?? 'Tap to upload a photo...',
                      style: TextStyle(
                        color: state.imageName == null
                            ? AppColors1.secondaryText
                            : AppColors1.primaryText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (state.imageName != null)
                    IconButton(
                      onPressed: () {
                        context.read<AssistantChatBloc>().add(RemoveImageEvent());
                      },
                      icon: const Icon(Icons.close),
                    )
                  else
                    const Icon(Icons.attach_file_rounded, color: AppColors1.icon),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () {
                      context.read<AssistantChatBloc>().add(SubmitIssueEvent());
                    },
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                'Send',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors1.yellowPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomMessageBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: const BoxDecoration(
        color: AppColors1.surface,
        border: Border(top: BorderSide(color: AppColors1.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors1.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors1.border),
            ),
            child: const Icon(Icons.add, color: AppColors1.icon),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors1.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors1.border),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Type a message',
                style: TextStyle(
                  color: AppColors1.secondaryText,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 54,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors1.yellowPrimary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}