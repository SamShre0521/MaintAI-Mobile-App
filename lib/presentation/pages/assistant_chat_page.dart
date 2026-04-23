// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:maintai/ApiClient.dart';
// import 'package:maintai/presentation/pages/app_sidebar.dart';
// import 'package:maintai/storage/tokenStorage.dart';

// class AssistantChatPage extends StatefulWidget {
//   const AssistantChatPage({super.key});

//   @override
//   State<AssistantChatPage> createState() => _AssistantChatPageState();
// }

// class _AssistantChatPageState extends State<AssistantChatPage>
//     with TickerProviderStateMixin {
//   final TextEditingController issueController = TextEditingController();
//   final ScrollController scrollController = ScrollController();

//   late final ApiClient apiClient;

//   bool isExpanded = false;
//   bool isAiTyping = false;
//   String? sessionId;

//   String selectedMachine = 'Conveyor Belt A (CB-2021-A)';
//   String? selectedImageName = 'machine_error_photo.jpg';

//   final List<String> machines = [
//     'Conveyor Belt A (CB-2021-A)',
//     'Conveyor Belt B (CB-2021-B)',
//     'Conveyor Belt C (CB-2021-C)',
//     'Conveyor Belt D (CB-2021-D)',
//   ];

//   final List<_ChatMessage> messages = [
//     _ChatMessage(
//       id: 'welcome-user',
//       isUser: true,
//       text: "Hello! I'm having an issue with one of the machines.",
//       time: '6:33 PM',
//     ),
//     _ChatMessage(
//       id: 'welcome-ai',
//       isUser: false,
//       text:
//           "I can help with that. Please select the machine and describe the issue. If possible, upload a photo too.",
//       time: '6:33 PM',
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     apiClient = ApiClient(TokenStorage());
//   }

//   @override
//   void dispose() {
//     issueController.dispose();
//     scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!scrollController.hasClients) return;
//       scrollController.animateTo(
//         scrollController.position.maxScrollExtent + 120,
//         duration: const Duration(milliseconds: 350),
//         curve: Curves.easeOutCubic,
//       );
//     });
//   }

//   String _messageId() => DateTime.now().microsecondsSinceEpoch.toString();

//   Future<void> _sendIssue() async {
//     if (issueController.text.trim().isEmpty) return;

//     final issueText = issueController.text.trim();

//     setState(() {
//       messages.add(
//         _ChatMessage(
//           id: _messageId(),
//           isUser: true,
//           text: sessionId == null
//               ? 'Machine: $selectedMachine\nIssue: $issueText'
//               : issueText,
//           time: 'Now',
//         ),
//       );

//       issueController.clear();
//       isExpanded = false;
//       isAiTyping = true;
//     });

//     _scrollToBottom();

//     try {
//       final response = await apiClient.dio.post(
//         '/chat',
//         data: {
//           "message": issueText,
//           if (sessionId != null) "sessionId": sessionId,
//         },
//       );

//       final data = response.data;

//       setState(() {
//         sessionId ??= data["sessionId"];

//         // messages.add(
//         //   _ChatMessage(
//         //     id: _messageId(),
//         //     isUser: false,
//         //     text: data["reply"] ?? "No reply received.",
//         //     time: 'Now',
//         //     animateTyping: true,
//         //   ),
//         // );
//         messages.add(
//   _ChatMessage(
//     id: _messageId(),
//     isUser: false,
//     text: data["reply"] ?? "No reply received.",
//     time: 'Now',
//     animateTyping: true,
//   ),
// );

//         isAiTyping = false;
//       });

//       _scrollToBottom();
//     } catch (e) {
//       setState(() {
//         messages.add(
//           _ChatMessage(
//             id: _messageId(),
//             isUser: false,
//             text: "Something went wrong. Please try again.",
//             time: 'Now',
//           ),
//         );
//         isAiTyping = false;
//       });

//       _scrollToBottom();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F6F1),
//       drawer: const AppSidebar(),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF8F6F1),
//         elevation: 0,
//         surfaceTintColor: const Color(0xFFF8F6F1),
//         centerTitle: true,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: Color(0xFF2E2E2E), size: 28),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: const Text(
//           'SmartAssist',
//           style: TextStyle(
//             color: Color(0xFF2E2E2E),
//             fontSize: 24,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(
//               Icons.notifications_none_rounded,
//               color: Color(0xFF2E2E2E),
//               size: 28,
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: scrollController,
//               padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//               itemCount: messages.length + 2 + (isAiTyping ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return Column(
//                     children: [
//                       _welcomeCard(),
//                       const SizedBox(height: 18),
//                     ],
//                   );
//                 }

//                 final adjustedIndex = index - 1;

//                 if (adjustedIndex < messages.length) {
//                   final msg = messages[adjustedIndex];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 14),
//                     child: AnimatedMessageWrapper(
//                       key: ValueKey(msg.id),
//                       child: msg.isUser
//                           ? _userBubble(text: msg.text, time: msg.time)
//                           : _aiBubble(message: msg),
//                     ),
//                   );
//                 }

//                 if (isAiTyping && adjustedIndex == messages.length) {
//                   return const Padding(
//                     padding: EdgeInsets.only(bottom: 14),
//                     child: _TypingBubble(),
//                   );
//                 }

//                 return const SizedBox(height: 90);
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         top: false,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 320),
//           curve: Curves.easeInOutCubic,
//           padding: EdgeInsets.only(
//             left: 12,
//             right: 12,
//             top: 10,
//             bottom: MediaQuery.of(context).padding.bottom + 10,
//           ),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             border: Border(top: BorderSide(color: Color(0xFFE4DCC8))),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0x14000000),
//                 blurRadius: 14,
//                 offset: Offset(0, -3),
//               ),
//             ],
//           ),
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             switchInCurve: Curves.easeOutCubic,
//             switchOutCurve: Curves.easeInCubic,
//             transitionBuilder: (child, animation) {
//               return SizeTransition(
//                 sizeFactor: animation,
//                 axisAlignment: -1,
//                 child: FadeTransition(
//                   opacity: animation,
//                   child: child,
//                 ),
//               );
//             },
//             child: sessionId == null
//                 ? (isExpanded
//                     ? _expandedBottomCard(key: const ValueKey('expanded'))
//                     : _compactBottomBar(key: const ValueKey('compact')))
//                 : _chatInputBar(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _welcomeCard() {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0.95, end: 1),
//       duration: const Duration(milliseconds: 450),
//       curve: Curves.easeOutCubic,
//       builder: (context, value, child) {
//         return Transform.scale(scale: value, child: child);
//       },
//       child: Container(
//         padding: const EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: const Color(0xFFE4DCC8)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 64,
//               height: 64,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFF8EFCB),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.smart_toy_outlined,
//                 size: 34,
//                 color: Color(0xFF2E2E2E),
//               ),
//             ),
//             const SizedBox(width: 16),
//             const Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome to MaintAI',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF2E2E2E),
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Text(
//                     'Share the issue and I will help you troubleshoot it.',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF7A7A7A),
//                       height: 1.35,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _userBubble({
//     required String text,
//     required String time,
//   }) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 310),
//         padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8EFCB),
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(color: const Color(0xFFE4DCC8)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 16,
//                 height: 1.45,
//                 color: Color(0xFF2E2E2E),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Text(
//                 time,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Color(0xFF8D8D8D),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Widget _aiBubble({
//   //   required _ChatMessage message,
//   // }) {
//   //   const bodyStyle = TextStyle(
//   //     fontSize: 16,
//   //     height: 1.45,
//   //     color: Color(0xFF2E2E2E),
//   //   );

//   //   return Align(
//   //     alignment: Alignment.centerLeft,
//   //     child: Row(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Container(
//   //           width: 42,
//   //           height: 42,
//   //           decoration: const BoxDecoration(
//   //             color: Colors.white,
//   //             shape: BoxShape.circle,
//   //             border: Border.fromBorderSide(
//   //               BorderSide(color: Color(0xFFE4DCC8)),
//   //             ),
//   //           ),
//   //           child: const Icon(
//   //             Icons.smart_toy_outlined,
//   //             color: Color(0xFF2E2E2E),
//   //             size: 22,
//   //           ),
//   //         ),
//   //         const SizedBox(width: 10),
//   //         Flexible(
//   //           child: Container(
//   //             padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//   //             decoration: BoxDecoration(
//   //               color: Colors.white,
//   //               borderRadius: BorderRadius.circular(24),
//   //               border: Border.all(color: const Color(0xFFE4DCC8)),
//   //             ),
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 message.animateTyping
//   //                     ? TypewriterText(
//   //                         key: ValueKey(message.id),
//   //                         text: message.text,
//   //                         style: bodyStyle,
//   //                         onCompleted: () {
//   //                           if (!mounted) return;
//   //                           setState(() {
//   //                             message.animateTyping = false;
//   //                           });
//   //                         },
//   //                       )
//   //                     : MarkdownBody(
//   //                         data: message.text,
//   //                         selectable: true,
//   //                         shrinkWrap: true,
//   //                         styleSheet: MarkdownStyleSheet(
//   //                           p: bodyStyle,
//   //                           h1: const TextStyle(
//   //                             fontSize: 22,
//   //                             fontWeight: FontWeight.w700,
//   //                             color: Color(0xFF2E2E2E),
//   //                           ),
//   //                           h2: const TextStyle(
//   //                             fontSize: 20,
//   //                             fontWeight: FontWeight.w700,
//   //                             color: Color(0xFF2E2E2E),
//   //                           ),
//   //                           h3: const TextStyle(
//   //                             fontSize: 18,
//   //                             fontWeight: FontWeight.w700,
//   //                             color: Color(0xFF2E2E2E),
//   //                           ),
//   //                           strong: const TextStyle(
//   //                             fontWeight: FontWeight.w700,
//   //                             color: Color(0xFF2E2E2E),
//   //                           ),
//   //                           listBullet: bodyStyle,
//   //                           blockquote: bodyStyle,
//   //                         ),
//   //                       ),
//   //                 const SizedBox(height: 6),
//   //                 Align(
//   //                   alignment: Alignment.bottomRight,
//   //                   child: Text(
//   //                     message.time,
//   //                     style: const TextStyle(
//   //                       fontSize: 12,
//   //                       color: Color(0xFF8D8D8D),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _aiBubble({
//   required _ChatMessage message,
// }) {
//   return Align(
//     alignment: Alignment.centerLeft,
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 42,
//           height: 42,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             border: Border.fromBorderSide(
//               BorderSide(color: Color(0xFFE4DCC8)),
//             ),
//           ),
//           child: const Icon(
//             Icons.smart_toy_outlined,
//             color: Color(0xFF2E2E2E),
//             size: 22,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Flexible(
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(24),
//               border: Border.all(color: const Color(0xFFE4DCC8)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 message.animateTyping
//                     ? TypewriterMarkdown(
//                         key: ValueKey(message.id),
//                         text: message.text,
//                         onCompleted: () {
//                           if (!mounted) return;
//                           setState(() {
//                             message.animateTyping = false;
//                           });
//                         },
//                       )
//                     : MarkdownBody(
//                         data: message.text,
//                         selectable: true,
//                         shrinkWrap: true,
//                         styleSheet: MarkdownStyleSheet(
//                           p: const TextStyle(
//                             fontSize: 16,
//                             height: 1.45,
//                             color: Color(0xFF2E2E2E),
//                           ),
//                           h1: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF2E2E2E),
//                           ),
//                           h2: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF2E2E2E),
//                           ),
//                           h3: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF2E2E2E),
//                           ),
//                           strong: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             color: Color(0xFF2E2E2E),
//                           ),
//                           listBullet: const TextStyle(
//                             fontSize: 16,
//                             height: 1.45,
//                             color: Color(0xFF2E2E2E),
//                           ),
//                         ),
//                       ),
//                 const SizedBox(height: 6),
//                 Align(
//                   alignment: Alignment.bottomRight,
//                   child: Text(
//                     message.time,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Color(0xFF8D8D8D),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _compactBottomBar({Key? key}) {
//     return Row(
//       key: key,
//       children: [
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               isExpanded = true;
//             });
//           },
//           child: AnimatedScale(
//             scale: isExpanded ? 0.95 : 1,
//             duration: const Duration(milliseconds: 180),
//             child: Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8F6F1),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFE4DCC8)),
//               ),
//               child: const Icon(
//                 Icons.add,
//                 color: Color(0xFF737373),
//                 size: 28,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 isExpanded = true;
//               });
//             },
//             child: Container(
//               height: 48,
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8F6F1),
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: const Color(0xFFE4DCC8)),
//               ),
//               alignment: Alignment.centerLeft,
//               child: const Text(
//                 'Tap + to report issue',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFF8D8D8D),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           width: 48,
//           height: 48,
//           decoration: BoxDecoration(
//             color: const Color(0xFFF1C84B),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Icon(Icons.send_rounded, color: Colors.white),
//         ),
//       ],
//     );
//   }

//   Widget _expandedBottomCard({Key? key}) {
//     return Column(
//       key: key,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             const Icon(
//               Icons.warning_amber_rounded,
//               color: Color(0xFFF1C84B),
//               size: 26,
//             ),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Text(
//                 'Report an issue',
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2E2E2E),
//                 ),
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   isExpanded = false;
//                 });
//               },
//               icon: const Icon(Icons.keyboard_arrow_down_rounded),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         _label('Select Machine'),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8F1DD),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: const Color(0xFFE4DCC8)),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedMachine,
//               isExpanded: true,
//               icon: const Icon(Icons.keyboard_arrow_down_rounded),
//               items: machines.map((machine) {
//                 return DropdownMenuItem<String>(
//                   value: machine,
//                   child: Text(
//                     machine,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF2E2E2E),
//                     ),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   setState(() {
//                     selectedMachine = value;
//                   });
//                 }
//               },
//             ),
//           ),
//         ),
//         const SizedBox(height: 14),
//         _label('Describe the issue'),
//         const SizedBox(height: 8),
//         TextField(
//           controller: issueController,
//           maxLines: 3,
//           decoration: InputDecoration(
//             hintText: 'Type issue here...',
//             hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
//             filled: true,
//             fillColor: const Color(0xFFF8F6F1),
//             contentPadding: const EdgeInsets.all(16),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(18),
//               borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(18),
//               borderSide: const BorderSide(color: Color(0xFFE4DCC8)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(18),
//               borderSide: const BorderSide(color: Color(0xFFF1C84B)),
//             ),
//           ),
//         ),
//         const SizedBox(height: 14),
//         _label('Upload image'),
//         const SizedBox(height: 8),
//         GestureDetector(
//           onTap: () {
//             setState(() {
//               selectedImageName ??= 'machine_error_photo.jpg';
//             });
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F1DD),
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: const Color(0xFFE4DCC8)),
//             ),
//             child: Row(
//               children: [
//                 const Icon(
//                   Icons.camera_alt_outlined,
//                   color: Color(0xFF8D8D8D),
//                   size: 26,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     selectedImageName ?? 'Tap to upload image',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: selectedImageName == null
//                           ? const Color(0xFF9A9A9A)
//                           : const Color(0xFF2E2E2E),
//                     ),
//                   ),
//                 ),
//                 if (selectedImageName != null)
//                   IconButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedImageName = null;
//                       });
//                     },
//                     icon: const Icon(
//                       Icons.close,
//                       color: Color(0xFF555555),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           width: double.infinity,
//           height: 54,
//           child: ElevatedButton.icon(
//             onPressed: _sendIssue,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF1C84B),
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//             icon: const Icon(Icons.send_rounded),
//             label: const Text(
//               'Send',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _label(String text) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 15,
//           color: Color(0xFF7D7D7D),
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _chatInputBar() {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F6F1),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFE4DCC8)),
//             ),
//             child: TextField(
//               controller: issueController,
//               decoration: const InputDecoration(
//                 hintText: 'Type your message...',
//                 border: InputBorder.none,
//               ),
//               onSubmitted: (_) => _sendIssue(),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         GestureDetector(
//           onTap: _sendIssue,
//           child: Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF1C84B),
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.send_rounded,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class TypewriterMarkdown extends StatefulWidget {
//   final String text;
//   final VoidCallback? onCompleted;

//   const TypewriterMarkdown({
//     super.key,
//     required this.text,
//     this.onCompleted,
//   });

//   @override
//   State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
// }

// class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
//   Timer? timer;
//   int currentIndex = 0;
//   late final List<int> breakpoints;

//   @override
//   void initState() {
//     super.initState();
//     breakpoints = _buildBreakpoints(widget.text);

//     timer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
//       if (!mounted) return;

//       if (currentIndex < breakpoints.length - 1) {
//         setState(() {
//           currentIndex++;
//         });
//       } else {
//         timer.cancel();
//         widget.onCompleted?.call();
//       }
//     });
//   }

//   List<int> _buildBreakpoints(String text) {
//     final points = <int>[0];

//     for (int i = 1; i <= text.length; i++) {
//       final char = text[i - 1];

//       // reveal on spaces/newlines/punctuation instead of every char
//       if (char == ' ' ||
//           char == '\n' ||
//           char == '.' ||
//           char == ',' ||
//           char == ':' ||
//           char == ';' ||
//           char == '-') {
//         points.add(i);
//       }
//     }

//     if (points.last != text.length) {
//       points.add(text.length);
//     }

//     return points;
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final visibleText = widget.text.substring(0, breakpoints[currentIndex]);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         MarkdownBody(
//           data: visibleText,
//           selectable: true,
//           shrinkWrap: true,
//           styleSheet: MarkdownStyleSheet(
//             p: const TextStyle(
//               fontSize: 16,
//               height: 1.45,
//               color: Color(0xFF2E2E2E),
//             ),
//             h1: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF2E2E2E),
//             ),
//             h2: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF2E2E2E),
//             ),
//             h3: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF2E2E2E),
//             ),
//             strong: const TextStyle(
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF2E2E2E),
//             ),
//             listBullet: const TextStyle(
//               fontSize: 16,
//               height: 1.45,
//               color: Color(0xFF2E2E2E),
//             ),
//           ),
//         ),
//         const SizedBox(height: 2),
//         const Text(
//           '▋',
//           style: TextStyle(
//             color: Color(0xFFF1C84B),
//             fontSize: 16,
//             height: 1.0,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ChatMessage {
//   final String id;
//   final bool isUser;
//   final String text;
//   final String time;
//   bool animateTyping;

//   _ChatMessage({
//     required this.id,
//     required this.isUser,
//     required this.text,
//     required this.time,
//     this.animateTyping = false,
//   });
// }

// class AnimatedMessageWrapper extends StatefulWidget {
//   final Widget child;

//   const AnimatedMessageWrapper({
//     super.key,
//     required this.child,
//   });

//   @override
//   State<AnimatedMessageWrapper> createState() => _AnimatedMessageWrapperState();
// }

// class _AnimatedMessageWrapperState extends State<AnimatedMessageWrapper> {
//   double opacity = 0;
//   double translateY = 12;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 20), () {
//       if (!mounted) return;
//       setState(() {
//         opacity = 1;
//         translateY = 0;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 260),
//       opacity: opacity,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 260),
//         curve: Curves.easeOutCubic,
//         transform: Matrix4.translationValues(0, translateY, 0),
//         child: widget.child,
//       ),
//     );
//   }
// }

// class TypewriterText extends StatefulWidget {
//   final String text;
//   final TextStyle style;
//   final VoidCallback? onCompleted;

//   const TypewriterText({
//     super.key,
//     required this.text,
//     required this.style,
//     this.onCompleted,
//   });

//   @override
//   State<TypewriterText> createState() => _TypewriterTextState();
// }

// class _TypewriterTextState extends State<TypewriterText> {
//   String visibleText = '';
//   Timer? timer;
//   int index = 0;

//   @override
//   void initState() {
//     super.initState();
//     timer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
//       if (!mounted) return;
//       if (index < widget.text.length) {
//         setState(() {
//           visibleText += widget.text[index];
//           index++;
//         });
//       } else {
//         timer.cancel();
//         widget.onCompleted?.call();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final showCursor = index < widget.text.length;
//     return Text.rich(
//       TextSpan(
//         children: [
//           TextSpan(text: visibleText, style: widget.style),
//           if (showCursor)
//             TextSpan(
//               text: '▋',
//               style: widget.style.copyWith(
//                 color: const Color(0xFFF1C84B),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _TypingBubble extends StatefulWidget {
//   const _TypingBubble();

//   @override
//   State<_TypingBubble> createState() => _TypingBubbleState();
// }

// class _TypingBubbleState extends State<_TypingBubble>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   Widget _dot(int index) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         final progress = (controller.value - index * 0.15).clamp(0.0, 1.0);
//         final scale =
//             0.8 + (progress > 0 ? (1 - (progress - 0.5).abs() * 2) * 0.4 : 0);
//         return Transform.scale(scale: scale, child: child);
//       },
//       child: Container(
//         width: 8,
//         height: 8,
//         decoration: const BoxDecoration(
//           color: Color(0xFFF1C84B),
//           shape: BoxShape.circle,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           width: 42,
//           height: 42,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             border: Border.fromBorderSide(
//               BorderSide(color: Color(0xFFE4DCC8)),
//             ),
//           ),
//           child: const Icon(
//             Icons.smart_toy_outlined,
//             color: Color(0xFF2E2E2E),
//             size: 22,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(color: const Color(0xFFE4DCC8)),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _dot(0),
//               const SizedBox(width: 6),
//               _dot(1),
//               const SizedBox(width: 6),
//               _dot(2),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }






///// This file is deprecated and will be removed in future releases. Please use the new chat page implementation instead.
//// See assistant_chat_page.dart for the new implementation.\

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:maintai/domain/entities/chat_message.dart';
import 'package:maintai/presentation/bloc/assistant_chat_event.dart';
import 'package:maintai/presentation/bloc/assistant_chat_state.dart';
import 'package:maintai/presentation/bloc/assitant_chat_bloc.dart';
import 'package:maintai/presentation/pages/app_sidebar.dart';

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
                          _welcomeCard(),
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
                              ? _userBubble(
                                  text: msg.text,
                                  time: msg.time,
                                )
                              : _aiBubble(
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
                child: state.sessionId == null
                    ? (state.isExpanded
                        ? _expandedBottomCard(
                            key: const ValueKey('expanded'),
                            state: state,
                          )
                        : _compactBottomBar(
                            key: const ValueKey('compact'),
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
    required ChatMessage message,
    required VoidCallback onTypingCompleted,
  }) {
    final markdownStyle = MarkdownStyleSheet(
      p: const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF2E2E2E),
      ),
      h1: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E2E),
      ),
      h2: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E2E),
      ),
      h3: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E2E),
      ),
      strong: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF2E2E2E),
      ),
      listBullet: const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF2E2E2E),
      ),
    );

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
                  message.animateTyping
                      ? TypewriterMarkdown(
                          key: ValueKey(message.id),
                          text: message.text,
                          styleSheet: markdownStyle,
                          onCompleted: onTypingCompleted,
                        )
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          shrinkWrap: true,
                          styleSheet: markdownStyle,
                        ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message.time,
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
            context.read<AssistantChatBloc>().add(
                  ToggleExpandedComposerEvent(true),
                );
          },
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
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<AssistantChatBloc>().add(
                    ToggleExpandedComposerEvent(true),
                  );
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

  Widget _expandedBottomCard({
    Key? key,
    required AssistantChatState state,
  }) {
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
                      context.read<AssistantChatBloc>().add(
                            RemoveImageEvent(),
                          );
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
            onPressed: _sendMessage,
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

class AnimatedMessageWrapper extends StatefulWidget {
  final Widget child;

  const AnimatedMessageWrapper({
    super.key,
    required this.child,
  });

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

class TypewriterMarkdown extends StatefulWidget {
  final String text;
  final MarkdownStyleSheet styleSheet;
  final VoidCallback? onCompleted;

  const TypewriterMarkdown({
    super.key,
    required this.text,
    required this.styleSheet,
    this.onCompleted,
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
  int currentIndex = 0;
  late final List<int> breakpoints;

  @override
  void initState() {
    super.initState();
    breakpoints = _buildBreakpoints(widget.text);
    _startTyping();
  }

  void _startTyping() async {
    while (mounted && currentIndex < breakpoints.length - 1) {
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() {
        currentIndex++;
      });
    }
    widget.onCompleted?.call();
  }

  List<int> _buildBreakpoints(String text) {
    final points = <int>[0];

    for (int i = 1; i <= text.length; i++) {
      final char = text[i - 1];
      if (char == ' ' ||
          char == '\n' ||
          char == '.' ||
          char == ',' ||
          char == ':' ||
          char == ';') {
        points.add(i);
      }
    }

    if (points.last != text.length) {
      points.add(text.length);
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = widget.text.substring(0, breakpoints[currentIndex]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: visibleText,
          selectable: true,
          shrinkWrap: true,
          styleSheet: widget.styleSheet,
        ),
        const SizedBox(height: 2),
        const Text(
          '▋',
          style: TextStyle(
            color: Color(0xFFF1C84B),
            fontSize: 16,
            height: 1.0,
          ),
        ),
      ],
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
        final scale =
            0.8 + (progress > 0 ? (1 - (progress - 0.5).abs() * 2) * 0.4 : 0);
        return Transform.scale(scale: scale, child: child);
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