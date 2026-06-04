import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import 'summary_controller.dart';

/// Project NDT status summary page for a company.
class ProjectSummaryPage extends ConsumerWidget {
  const ProjectSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(currentUserCompanyIdProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isCompany = ref.watch(isNdtCompanyProvider);

    if (companyId == null) {
      return const Center(child: Text('No company assigned'));
    }

    final summaryAsync = ref.watch(projectStatusSummaryProvider(companyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project NDT Status'),
      ),
      // FAB to add new planning/RFI (admin & ndt_company)
      floatingActionButton: (isAdmin || isCompany)
          ? FloatingActionButton.extended(
              heroTag: 'add-planning-from-status',
              onPressed: () => context.push('/planning/create'),
              icon: const Icon(Icons.add),
              label: const Text('New RFI'),
            )
          : null,
      body: summaryAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) {
            return EmptyState(
              message: 'No project status data available',
              icon: Icons.assessment_outlined,
              actionLabel: (isAdmin || isCompany) ? 'Add NDT RFI' : null,
              onAction: (isAdmin || isCompany)
                  ? () => context.push('/planning/create')
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(projectStatusSummaryProvider(companyId)),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final item = summaries[index];
                return _ProjectStatusCard(data: item);
              },
            ),
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading status...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load status: $error',
          onRetry: () =>
              ref.invalidate(projectStatusSummaryProvider(companyId)),
        ),
      ),
    );
  }
}

class _ProjectStatusCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ProjectStatusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final projectName = data['project_name'] as String? ?? 'Unknown';
    final projectCode = data['project_code'] as String? ?? '';
    final projectId = data['project_id'] as String? ?? '';
    final completed = (data['completed_tests'] as num?)?.toInt() ?? 0;
    final total = (data['total_deployments'] as num?)?.toInt() ?? 0;
    final completionRate =
        (data['completion_rate'] as num?)?.toDouble() ?? 0.0;
    final rejectRate = (data['reject_rate'] as num?)?.toDouble() ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: projectId.isNotEmpty
            ? () => context.push('/planning?projectId=$projectId')
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(projectName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  Text(projectCode,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniStat(label: 'Completed', value: '$completed/$total', color: Colors.green),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Completion', value: '${completionRate.toStringAsFixed(1)}%', color: Colors.blue),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'Reject Rate', value: '${rejectRate.toStringAsFixed(1)}%', color: rejectRate > 10 ? Colors.red : Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: projectId.isNotEmpty
                        ? () => context.push('/planning?projectId=$projectId')
                        : null,
                    icon: const Icon(Icons.assignment_turned_in, size: 16),
                    label: const Text('View RFIs', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: projectId.isNotEmpty
                        ? () => context.push('/deployments/create')
                        : null,
                    icon: const Icon(Icons.engineering, size: 16),
                    label: const Text('Add Deployment', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
      ],
    );
  }
}
