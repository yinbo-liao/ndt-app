import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/cards/summary_card.dart';
import '../../providers/role_provider.dart';
import 'shift_summary_view.dart';
import 'summary_controller.dart';

/// Daily deployment summary page for a specific project.
class DailySummaryPage extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const DailySummaryPage({
    super.key,
    required this.projectId,
    this.projectName = '',
  });

  @override
  ConsumerState<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends ConsumerState<DailySummaryPage> {
  List<ProjectModel> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final repo = ProjectRepository();
      final projects = await repo.getAll();
      if (mounted) setState(() => _projects = projects);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final summaryAsync = ref.watch(dailyProjectSummaryProvider(widget.projectId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Deployment Summary'),
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
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: 'add-deploy-daily',
              onPressed: () => context.push('/deployments/create'),
              child: const Icon(Icons.add),
            )
          : null,
      body: summaryAsync.when(
        data: (summary) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project selector
                if (_projects.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: widget.projectId.isNotEmpty ? widget.projectId : null,
                    decoration: const InputDecoration(
                      labelText: 'Select Project',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    items: _projects
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.projectName)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context.go('/reports/daily?projectId=$v&projectName=${Uri.encodeComponent(_projects.firstWhere((p) => p.id == v).projectName)}');
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (summary != null) ...[
                  const SizedBox(height: 8),
                  Text(summary.projectName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      SummaryCard(title: 'Total Teams', value: summary.totalTeams.toString(), icon: Icons.groups, color: Colors.blue),
                      SummaryCard(title: 'Personnel', value: summary.totalPersonnel.toString(), icon: Icons.people, color: Colors.green),
                      SummaryCard(title: 'Completed', value: summary.completedTests.toString(), icon: Icons.check_circle, color: Colors.teal),
                      SummaryCard(title: 'In Progress', value: summary.inProgressTests.toString(), icon: Icons.pending, color: Colors.orange),
                      SummaryCard(title: 'Rejected', value: summary.rejectedTests.toString(), icon: Icons.cancel, color: Colors.red),
                      SummaryCard(title: 'Test Length', value: '${summary.totalTestLength.toStringAsFixed(1)}m', icon: Icons.straighten, color: Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ShiftSummaryView(summary: summary),
                  const SizedBox(height: 24),
                  if (summary.locations.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Job Locations', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8, runSpacing: 8,
                              children: summary.locations.map((l) => Chip(label: Text(l), avatar: const Icon(Icons.location_on, size: 18))).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text('No data for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                          style: TextStyle(color: Colors.grey[500])),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading summary...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load summary: $error',
          onRetry: () => ref.invalidate(dailyProjectSummaryProvider(widget.projectId)),
        ),
      ),
    );
  }
}
