import 'package:flutter/material.dart';
import 'package:maintai/theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors1.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors1.yellowLight,
                border: Border(
                  bottom: BorderSide(color: AppColors1.border),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors1.yellowPrimary,
                    child: Icon(Icons.smart_toy_outlined, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'MaintAI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors1.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _tile(Icons.chat_bubble_outline, 'New Chat'),
            _tile(Icons.precision_manufacturing_outlined, 'Machines'),
            _tile(Icons.report_problem_outlined, 'Issue History'),
            _tile(Icons.image_outlined, 'Uploads'),
            _tile(Icons.settings_outlined, 'Settings'),
            const Spacer(),
            const Divider(color: AppColors1.border),
            _tile(Icons.logout, 'Logout'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Widget _tile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors1.icon),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors1.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {},
    );
  }
}