import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maintai/presentation/pages/app_sidebar.dart';

class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage({super.key});

  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage>
    with TickerProviderStateMixin {
  final TextEditingController issueController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isExpanded = false;
  bool isAiTyping = false;

  String selectedMachine = 'Conveyor Belt A (CB-2021-A)';
  String? selectedImageName = 'machine_error_photo.jpg';

  final List<String> machines = [
    'Conveyor Belt A (CB-2021-A)',
    'Conveyor Belt B (CB-2021-B)',
    'Conveyor Belt C (CB-2021-C)',
    'Conveyor Belt D (CB-2021-D)',
  ];

  final List<_ChatMessage> messages = [
    _ChatMessage(
      isUser: true,
      text: "Hello! I'm having an issue with one of the machines.",
      time: '6:33 PM',
    ),
    _ChatMessage(
      isUser: false,
      text:
          "I can help with that. Please select the machine and describe the issue. If possible, upload a photo too.",
      time: '6:33 PM',
    ),
  ];

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

  Future<void> _sendIssue() async {
    if (issueController.text.trim().isEmpty) return;

    final issueText = issueController.text.trim();

    setState(() {
      messages.add(
        _ChatMessage(
          isUser: true,
          text: 'Machine: $selectedMachine\nIssue: $issueText',
          time: 'Now',
        ),
      );
      issueController.clear();
      selectedImageName = null;
      isExpanded = false;
      isAiTyping = true;
    });

    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      messages.add(
        _ChatMessage(
          isUser: false,
          text:
              'Got it. I have logged the issue for $selectedMachine. Based on your description, I recommend checking for overheating, loose alignment, friction at the rollers, and belt tension. Uploading an image next time can help me narrow it down faster.',
          time: 'Now',
          animateTyping: true,
        ),
      );
      isAiTyping = false;
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.menu, color: Color(0xFF2E2E2E), size: 28),
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
              itemCount: messages.length + 2 + (isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      _welcomeCard(),
                      const SizedBox(height: 18),
                    ],
                  );
                }

                final adjustedIndex = index - 1;

                if (adjustedIndex < messages.length) {
                  final msg = messages[adjustedIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AnimatedMessageWrapper(
                      child: msg.isUser
                          ? _userBubble(
                              text: msg.text,
                              time: msg.time,
                            )
                          : _aiBubble(
                              text: msg.text,
                              time: msg.time,
                              animateTyping: msg.animateTyping,
                            ),
                    ),
                  );
                }

                if (isAiTyping && adjustedIndex == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: _TypingBubble(),
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
            child: isExpanded
                ? _expandedBottomCard(key: const ValueKey('expanded'))
                : _compactBottomBar(key: const ValueKey('compact')),
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE4DCC8)),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF8EFCB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                size: 34,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to MaintAI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Share the issue and I will help you troubleshoot it.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7A7A7A),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userBubble({
    required String text,
    required String time,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8EFCB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE4DCC8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.45,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiBubble({
    required String text,
    required String time,
    bool animateTyping = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(color: Color(0xFFE4DCC8)),
              ),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Color(0xFF2E2E2E),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  animateTyping
                      ? TypewriterText(
                          text: text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: Color(0xFF2E2E2E),
                          ),
                        )
                      : Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.45,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8D8D8D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactBottomBar({Key? key}) {
    return Row(
      key: key,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = true;
            });
          },
          child: AnimatedScale(
            scale: isExpanded ? 0.95 : 1,
            duration: const Duration(milliseconds: 180),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF737373),
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = true;
              });
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4DCC8)),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Tap + to report issue',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8D8D8D),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
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
      ],
    );
  }

  Widget _expandedBottomCard({Key? key}) {
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
                setState(() {
                  isExpanded = false;
                });
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
              value: selectedMachine,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: machines.map((machine) {
                return DropdownMenuItem<String>(
                  value: machine,
                  child: Text(
                    machine,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedMachine = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        _label('Describe the issue'),
        const SizedBox(height: 8),
        TextField(
          controller: issueController,
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
            setState(() {
              selectedImageName ??= 'machine_error_photo.jpg';
            });
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
                    selectedImageName ?? 'Tap to upload image',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedImageName == null
                          ? const Color(0xFF9A9A9A)
                          : const Color(0xFF2E2E2E),
                    ),
                  ),
                ),
                if (selectedImageName != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedImageName = null;
                      });
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
            onPressed: _sendIssue,
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

class _ChatMessage {
  final bool isUser;
  final String text;
  final String time;
  final bool animateTyping;

  _ChatMessage({
    required this.isUser,
    required this.text,
    required this.time,
    this.animateTyping = false,
  });
}

class AnimatedMessageWrapper extends StatefulWidget {
  final Widget child;

  const AnimatedMessageWrapper({super.key, required this.child});

  @override
  State<AnimatedMessageWrapper> createState() => _AnimatedMessageWrapperState();
}

class _AnimatedMessageWrapperState extends State<AnimatedMessageWrapper> {
  double opacity = 0;
  double translateY = 12;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 20), () {
      if (!mounted) return;
      setState(() {
        opacity = 1;
        translateY = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, translateY, 0),
        child: widget.child,
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String visibleText = '';
  Timer? timer;
  int index = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (!mounted) return;
      if (index < widget.text.length) {
        setState(() {
          visibleText += widget.text[index];
          index++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showCursor = index < widget.text.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: visibleText, style: widget.style),
          if (showCursor)
            TextSpan(
              text: '▋',
              style: widget.style.copyWith(
                color: const Color(0xFFF1C84B),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = (controller.value - index * 0.15).clamp(0.0, 1.0);
        final scale = 0.8 + (progress > 0 ? (1 - (progress - 0.5).abs() * 2) * 0.4 : 0);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFFF1C84B),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Color(0xFFE4DCC8)),
            ),
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Color(0xFF2E2E2E),
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE4DCC8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0),
              const SizedBox(width: 6),
              _dot(1),
              const SizedBox(width: 6),
              _dot(2),
            ],
          ),
        ),
      ],
    );
  }
}

