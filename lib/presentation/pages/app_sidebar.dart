import 'package:flutter/material.dart';

class ChatHistoryItem {
  final String sessionId;
  final String title;

  const ChatHistoryItem({
    required this.sessionId,
    required this.title,
  });
}

class AppSidebar extends StatelessWidget {
  final List<ChatHistoryItem> historyItems;
  final VoidCallback onNewChat;
  final void Function(String sessionId) onSelectHistory;
  final VoidCallback onMachines;
  final VoidCallback onUploads;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const AppSidebar({
    super.key,
    required this.historyItems,
    required this.onNewChat,
    required this.onSelectHistory,
    required this.onMachines,
    required this.onUploads,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F1DD),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE4DCC8)),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFF1C84B),
                    child: Icon(Icons.smart_toy_outlined, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'MaintAI',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                ],
              ),
            ),
            _tile(
              icon: Icons.chat_bubble_outline,
              title: 'New Chat',
              onTap: onNewChat,
            ),
            _tile(
              icon: Icons.precision_manufacturing_outlined,
              title: 'Machines',
              onTap: onMachines,
            ),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                leading: const Icon(
                  Icons.report_problem_outlined,
                  color: Color(0xFF666666),
                ),
                title: const Text(
                  'Issue History',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E2E2E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                childrenPadding: const EdgeInsets.only(left: 16, right: 8),
                children: historyItems.isEmpty
                    ? const [
                        Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No previous chats',
                              style: TextStyle(
                                color: Color(0xFF8D8D8D),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ]
                    : historyItems.map((item) {
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 16),
                          leading: const Icon(
                            Icons.history,
                            size: 18,
                            color: Color(0xFF8D8D8D),
                          ),
                          title: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                          onTap: () => onSelectHistory(item.sessionId),
                        );
                      }).toList(),
              ),
            ),
            _tile(
              icon: Icons.image_outlined,
              title: 'Uploads',
              onTap: onUploads,
            ),
            _tile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: onSettings,
            ),
            const Spacer(),
            const Divider(),
            _tile(
              icon: Icons.logout,
              title: 'Logout',
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF666666)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2E2E2E),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}