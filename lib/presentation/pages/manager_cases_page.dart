import 'package:flutter/material.dart';
import 'package:maintai/ApiClient.dart';
import 'package:maintai/domain/entities/feedback_isssues.dart';
import 'package:maintai/domain/repositories/impl/managerrepoimpl.dart';
import 'package:maintai/domain/usecase/getFeedbackByStatus.dart';
import 'package:maintai/presentation/pages/manager_review_issue.dart';
import 'package:maintai/storage/tokenStorage.dart';

class ManagerCasesPage extends StatefulWidget {
  final String status;

  const ManagerCasesPage({
    super.key,
    required this.status,
  });

  @override
  State<ManagerCasesPage> createState() => _ManagerCasesPageState();
}

class _ManagerCasesPageState extends State<ManagerCasesPage> {
  bool isLoading = true;
  String? errorMessage;
  List<FeedbackIssue> cases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final tokenStorage = TokenStorage();
      final apiClient = ApiClient(tokenStorage);
      final repository = ManagerRepositoryImpl(apiClient);
      final usecase = GetFeedbacksByStatus(repository);

      final data = await usecase(widget.status);

      if (!mounted) return;

      setState(() {
        cases = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load ${widget.status} cases';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = widget.status.toLowerCase() == 'approved';
    final title = isApproved ? 'Approved Cases' : 'Pending Cases';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F1),
        elevation: 0,
        surfaceTintColor: const Color(0xFFF8F6F1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$title (${cases.length})',
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadCases,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF1C84B),
              ),
            )
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : cases.isEmpty
                  ? Center(
                      child: Text(
                        isApproved
                            ? 'No approved cases yet.'
                            : 'No pending cases.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF7A7A7A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFF1C84B),
                      onRefresh: _loadCases,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cases.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = cases[index];

                          return _CaseTile(
                            feedback: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManagerReviewIssuePage(
                                    feedback: item,
                                    isReadOnly: isApproved,
                                  ),
                                ),
                              ).then((_) => _loadCases());
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}

class _CaseTile extends StatelessWidget {
  final FeedbackIssue feedback;
  final VoidCallback onTap;

  const _CaseTile({
    required this.feedback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = feedback.managerStatus.toLowerCase() == 'approved';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE4DCC8)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  isApproved ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED),
              child: Icon(
                isApproved
                    ? Icons.check_circle_rounded
                    : Icons.pending_actions_rounded,
                color: isApproved
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
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${feedback.engineerName} • ${feedback.department}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}