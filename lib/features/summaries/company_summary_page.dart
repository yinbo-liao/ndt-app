import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/summary_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import 'summary_controller.dart';

/// Daily company-wide summary page.
class CompanySummaryPage extends ConsumerWidget {
  const CompanySummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(currentUserCompanyIdProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isCompany = ref.watch(isNdtCompanyProvider);

    if (companyId == null) {
      return const Center(child: Text('No company assigned'));
    }

    final summaryAsync =
        ref.watch(dailyCompanySummaryProvider(companyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Daily Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      // FAB to add deployment (admin & ndt_company)
      floatingActionButton: (isAdmin || isCompany)
          ? FloatingActionButton.extended(
              heroTag: 'add-deployment-from-summary',
              onPressed: () => context.push('/deployments/create'),
              icon: const Icon(Icons.add),
              label: const Text('Add Deployment'),
            )
          : null,
      body: summaryAsync.when(
        data: (summary) {
          if (summary == null) {
            return EmptyState(
              message: 'No data for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
              icon: Icons.calendar_today,
              actionLabel: (isAdmin || isCompany) ? 'Add Deployment' : null,
              onAction: (isAdmin || isCompany) ? () => context.push('/deployments/create') : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(dailyCompanySummaryProvider(companyId)),
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(summary.companyName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600])),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    SummaryCard(
                      title: 'Projects',
                      value: summary.totalProjects.toString(),
                      icon: Icons.business,
                      color: Colors.blue,
                    ),
                    SummaryCard(
                      title: 'Day Shifts',
                      value: summary.dayShiftCount.toString(),
                      icon: Icons.wb_sunny,
                      color: Colors.orange,
                    ),
                    SummaryCard(
                      title: 'Night Shifts',
                      value: summary.nightShiftCount.toString(),
                      icon: Icons.nights_stay,
                      color: Colors.indigo,
                    ),
                    SummaryCard(
                      title: 'Total Teams',
                      value: summary.totalTeams.toString(),
                      icon: Icons.groups,
                      color: Colors.green,
                    ),
                    SummaryCard(
                      title: 'Personnel',
                      value: summary.totalPersonnel.toString(),
                      icon: Icons.people,
                      color: Colors.teal,
                    ),
                    SummaryCard(
                      title: 'Completed',
                      value: summary.completedTests.toString(),
                      icon: Icons.check_circle,
                      color: Colors.teal,
                    ),
                    SummaryCard(
                      title: 'Rejected',
                      value: summary.rejectedTests.toString(),
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                    SummaryCard(
                      title: 'Reject Rate',
                      value: '${summary.avgRejectRate.toStringAsFixed(1)}%',
                      icon: Icons.trending_up,
                      color: summary.avgRejectRate > 10
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ),
                // Quick action buttons at the bottom
                const SizedBox(height: 20),
                if (isAdmin || isCompany) ...[
                  Text('Quick Actions', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/deployments/create'),
                        icon: const Icon(Icons.engineering, size: 18),
                        label: const Text('Add Deployment'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/planning/create'),
                        icon: const Icon(Icons.assignment_turned_in, size: 18),
                        label: const Text('Create RFI'),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ));
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading summary...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load summary: $error',
          onRetry: () => ref.invalidate(dailyCompanySummaryProvider(companyId)),
        ),
      ),
    );
  }
}
