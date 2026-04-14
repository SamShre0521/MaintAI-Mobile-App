// import 'package:flutter/material.dart';
// import 'package:maintai/theme/app_colors.dart';

// class AppSidebar extends StatelessWidget {
//   const AppSidebar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: AppColors1.surface,
//       child: SafeArea(
//         child: Column(
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: AppColors1.yellowLight,
//                 border: Border(
//                   bottom: BorderSide(color: AppColors1.border),
//                 ),
//               ),
//               child: const Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 24,
//                     backgroundColor: AppColors1.yellowPrimary,
//                     child: Icon(Icons.smart_toy_outlined, color: Colors.white),
//                   ),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       'MaintAI',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors1.primaryText,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _tile(Icons.chat_bubble_outline, 'New Chat'),
//             _tile(Icons.precision_manufacturing_outlined, 'Machines'),
//             _tile(Icons.report_problem_outlined, 'Issue History'),
//             _tile(Icons.image_outlined, 'Uploads'),
//             _tile(Icons.settings_outlined, 'Settings'),
//             const Spacer(),
//             const Divider(color: AppColors1.border),
//             _tile(Icons.logout, 'Logout'),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }

//   static Widget _tile(IconData icon, String title) {
//     return ListTile(
//       leading: Icon(icon, color: AppColors1.icon),
//       title: Text(
//         title,
//         style: const TextStyle(
//           color: AppColors1.primaryText,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       onTap: () {},
//     );
//   }
// }



import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

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
            _tile(Icons.chat_bubble_outline, 'New Chat'),
            _tile(Icons.precision_manufacturing_outlined, 'Machines'),
            _tile(Icons.report_problem_outlined, 'Issue History'),
            _tile(Icons.image_outlined, 'Uploads'),
            _tile(Icons.settings_outlined, 'Settings'),
            const Spacer(),
            const Divider(),
            _tile(Icons.logout, 'Logout'),
          ],
        ),
      ),
    );
  }

  static Widget _tile(IconData icon, String title) {
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
      onTap: () {},
    );
  }
}