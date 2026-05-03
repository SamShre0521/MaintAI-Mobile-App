import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/feedback_isssues.dart';
import 'package:maintai/domain/repositories/impl/assistantrepoimpl.dart';
import 'package:maintai/domain/repositories/impl/authrepoimpl.dart';
import 'package:maintai/domain/usecase/authorizations.dart';
import 'package:maintai/presentation/bloc/auth_bloc.dart';
import 'package:maintai/presentation/bloc/manager_dashboard_bloc.dart';
import 'package:maintai/presentation/bloc/manager_dashboard_event.dart';
import 'package:maintai/presentation/bloc/manager_dashboard_state.dart';
import 'package:maintai/presentation/pages/app_sidebar.dart';
import 'package:maintai/presentation/pages/auth.dart';
import 'package:maintai/presentation/pages/manager_review_issue.dart';
import 'package:maintai/storage/tokenStorage.dart';
import 'package:maintai/domain/usecase/getMachines.dart';
import 'package:maintai/domain/usecase/sendChatMessage.dart';
import 'package:maintai/domain/usecase/getSessions.dart';
import 'package:maintai/domain/usecase/getSessionMessages.dart';
import 'package:maintai/presentation/bloc/assitant_chat_bloc.dart';
import 'package:maintai/presentation/bloc/assistant_chat_event.dart';
import 'package:maintai/presentation/pages/assistant_chat_page.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagerDashboardBloc, ManagerDashboardState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F6F1),
          drawer: AppSidebar(
            userName: 'Manager',
            userRole: 'Manager',
            
            historyItems: const [],
            onManagerDashboard: () {
              Navigator.pop(context);
            },
            onNewChat: () {
              Navigator.pop(context);

              final tokenStorage = TokenStorage();
              final apiClient = ApiClient(tokenStorage);
              final assistantRepository = AssistantRepositoryImpl(apiClient);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) =>
                        AssistantChatBloc(
                            getMachines: GetMachines(assistantRepository),
                            sendChatMessage: SendChatMessage(
                              assistantRepository,
                            ),
                            getSessions: GetSessions(assistantRepository),
                            getSessionMessages: GetSessionMessages(
                              assistantRepository,
                            ),
                          )
                          ..add(LoadMachinesEvent())
                          ..add(LoadSessionsEvent()),
                    child: const AssistantChatPage(),
                  ),
                ),
              );
            },
            
            onSelectHistory: (_) {},
            onMachines: () {
              Navigator.pop(context);
            },
            onUploads: () {
              Navigator.pop(context);
            },
            onSettings: () {
              Navigator.pop(context);
            },
            onLogout: () async {
              Navigator.pop(context);

              await TokenStorage().clearToken();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) {
                      final tokenStorage = TokenStorage();
                      final apiClient = ApiClient(tokenStorage);
                      final repository = Authrepoimpl(apiClient, tokenStorage);

                      return AuthBloc(
                        LoginUseCase(repository),
                        SignupUseCase(repository),
                      );
                    },
                    child: const AuthPage(),
                  ),
                ),
                (route) => false,
              );
            },
          ),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF8F6F1),
            elevation: 0,
            surfaceTintColor: const Color(0xFFF8F6F1),
            // leading: IconButton(
            //   onPressed: () {},
            //   icon: const Icon(
            //     Icons.menu_rounded,
            //     color: Color(0xFF2E2E2E),
            //     size: 30,
            //   ),
            // ),
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF2E2E2E),
                  size: 30,
                ),
              ),
            ),
            title: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF1C84B),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'MaintAI',
                  style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF2E2E2E),
                      size: 30,
                    ),
                  ),
                  if (state.pendingCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1C84B),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          state.pendingCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF1C84B)),
                )
              : RefreshIndicator(
                  color: const Color(0xFFF1C84B),
                  onRefresh: () async {
                    context.read<ManagerDashboardBloc>().add(
                      LoadManagerDashboardEvent(),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                    children: [
                      const Text(
                        'Manager Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Review engineer feedback before storing approved solutions in the knowledge base.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.12,
                        children: [
                          _MetricCard(
                            icon: Icons.chat_bubble_outline_rounded,
                            iconColor: const Color(0xFFF1C84B),
                            title: 'Total Feedbacks',
                            value: '${state.pendingFeedbacks.length}',
                            subtitle: 'In your department',
                            subtitleColor: const Color(0xFF16A34A),
                          ),
                          _MetricCard(
                            icon: Icons.pending_actions_rounded,
                            iconColor: const Color(0xFFF97316),
                            title: 'Pending',
                            value: '${state.pendingCount}',
                            subtitle: 'Needs review',
                            subtitleColor: const Color(0xFFF97316),
                          ),
                          _MetricCard(
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: const Color(0xFF22C55E),
                            title: 'Approved',
                            value: '${state.approvedCount}',
                            subtitle: 'Approved issues',
                            subtitleColor: const Color(0xFF16A34A),
                          ),
                          const _MetricCard(
                            icon: Icons.hourglass_bottom_rounded,
                            iconColor: Color(0xFF7C3AED),
                            title: 'Avg. Review',
                            value: '--',
                            subtitle: 'Coming soon',
                            subtitleColor: Color(0xFF7A7A7A),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _SectionCard(
                        title: 'Pending Approvals',
                        count: state.pendingCount,
                        child: state.pendingFeedbacks.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: Text(
                                  'No pending approvals.',
                                  style: TextStyle(
                                    color: Color(0xFF7A7A7A),
                                    fontSize: 15,
                                  ),
                                ),
                              )
                            : Column(
                                children: state.pendingFeedbacks.map((issue) {
                                  return _PendingFeedbackTile(
                                    feedback: issue,
                                    onReview: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: context
                                                .read<ManagerDashboardBloc>(),
                                            child: ManagerReviewIssuePage(
                                              feedback: issue,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE4DCC8))),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 14,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _BottomNavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isActive: true,
                    onTap: () {},
                  ),
                  _BottomNavItem(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending',
                    badge: state.pendingCount,
                    onTap: () {},
                  ),
                  _BottomNavItem(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Approved',
                    onTap: () {},
                  ),
                  _BottomNavItem(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    onTap: () async {
                      await TokenStorage().clearToken();

                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) {
                              final tokenStorage = TokenStorage();
                              final apiClient = ApiClient(tokenStorage);
                              final repository = Authrepoimpl(
                                apiClient,
                                tokenStorage,
                              );

                              return AuthBloc(
                                LoginUseCase(repository),
                                SignupUseCase(repository),
                              );
                            },
                            child: const AuthPage(),
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Color subtitleColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4DCC8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E2E2E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final int count;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4DCC8)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1C84B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    context.read<ManagerDashboardBloc>().add(
                      LoadManagerDashboardEvent(),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _PendingFeedbackTile extends StatelessWidget {
  final FeedbackIssue feedback;
  final VoidCallback onReview;

  const _PendingFeedbackTile({required this.feedback, required this.onReview});

  @override
  Widget build(BuildContext context) {
    final isCorrect = feedback.engineerFeedback.toLowerCase() == 'correct';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isCorrect
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFFF7ED),
            child: Icon(
              isCorrect
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: isCorrect
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF97316),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${feedback.engineerName} • ${feedback.department}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(status: feedback.managerStatus),
          const SizedBox(width: 8),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: onReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1C84B),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Review',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isPending ? const Color(0xFFFFF7ED) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.isEmpty ? 'pending' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isPending ? const Color(0xFFF97316) : const Color(0xFF16A34A),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badge;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFF1C84B) : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 78,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 26),
                if (badge != null && badge! > 0)
                  Positioned(
                    top: -7,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1C84B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
