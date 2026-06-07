import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/project_model.dart';
import '../../data/models/summary_model.dart';
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
  String? _selectedProjectId;
  bool _loadingProjects = true;

  @override
  void initState() {
    super.initState();
    _selectedProjectId =
        widget.projectId.isNotEmpty ? widget.projectId : null;
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final repo = ProjectRepository();
      final projects = await repo.getAll();
      if (mounted) {
        setState(() {
          _projects = projects;
          _loadingProjects = false;
          // Auto-select first project if none is set
          if (_selectedProjectId == null && projects.isNotEmpty) {
            _selectedProjectId = projects.first.id;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProjects = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final projectId = _selectedProjectId ?? '';
    final summaryAsync =
        projectId.isNotEmpty ? ref.watch(dailyProjectSummaryProvider(projectId)) : null;

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
      body: _loadingProjects
          ? const LoadingIndicator(message: 'Loading projects...')
          : _projects.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('No projects found. Create one first.',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                )
              : summaryAsync == null
                  ? _buildProjectSelector()
                  : summaryAsync.when(
                      data: (summary) {
                        if (summary == null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text('No data for ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                                  style: TextStyle(color: Colors.grey[500])),
                            ),
                          );
                        }
                        return _buildContent(
                            context, summary, selectedDate, isAdmin);
                      },
                      loading: () => const LoadingIndicator(
                          message: 'Loading summary...'),
                      error: (error, st) => AppErrorWidget(
                        message: 'Failed to load: $error',
                        onRetry: () => ref.invalidate(
                            dailyProjectSummaryProvider(projectId)),
                      ),
                    ),
    );
  }

  Widget _buildProjectSelector() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select a Project',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Choose a project to view its daily deployment summary.',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedProjectId,
            decoration: const InputDecoration(
              labelText: 'Project',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            items: _projects
                .map((p) => DropdownMenuItem(
                    value: p.id, child: Text(p.projectName)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedProjectId = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyProjectSummary summary,
      DateTime selectedDate, bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project selector
          if (_projects.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedProjectId,
              decoration: const InputDecoration(
                labelText: 'Select Project',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              items: _projects
                  .map((p) => DropdownMenuItem(
                      value: p.id, child: Text(p.projectName)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedProjectId = v);
              },
            ),
            const SizedBox(height: 16),
          ],
          Text(
            DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
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
        ],
      ),
    );
  }
}
