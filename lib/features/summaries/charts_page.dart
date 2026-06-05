import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/charts/line_chart_widget.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import 'summary_controller.dart';

/// Charts page showing weekly trend and shift comparison.
class ChartsPage extends ConsumerStatefulWidget {
  final String projectId;

  const ChartsPage({super.key, required this.projectId});

  @override
  ConsumerState<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends ConsumerState<ChartsPage> {
  late DateTime _startDate;
  late DateTime _endDate;
  List<ProjectModel> _projects = [];
  String? _selectedProjectId;
  bool _loadingProjects = true;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 7));
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
    final projectId = _selectedProjectId ?? '';

    final params = projectId.isNotEmpty
        ? WeeklyTrendParams(
            projectId: projectId,
            startDate: _startDate,
            endDate: _endDate,
          )
        : null;

    final trendAsync =
        params != null ? ref.watch(weeklyTrendProvider(params)) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts & Trends'),
      ),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project selector
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedProjectId),
                        initialValue: _selectedProjectId,
                        decoration: const InputDecoration(
                          labelText: 'Select Project',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                        items: _projects
                            .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.projectName)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedProjectId = v);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date range selector
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                }
                              },
                              child: Text(
                                  'From: ${_startDate.toIsoDateString}'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: _startDate,
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                }
                              },
                              child: Text(
                                  'To: ${_endDate.toIsoDateString}'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Weekly Deployment Trend',
                        style:
                            Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Chart
                      if (trendAsync == null)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Text('Select a project to view trends.'),
                          ),
                        )
                      else
                        SizedBox(
                          height: 250,
                          child: trendAsync.when(
                            data: (trends) {
                              if (trends.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No trend data for this period',
                                    style: TextStyle(
                                        color: Colors.grey[500]),
                                  ),
                                );
                              }

                              return LineChartWidget(
                                lineBars: [
                                  LineChartBarData(
                                    spots: trends
                                        .asMap()
                                        .entries
                                        .map((e) => FlSpot(
                                              e.key.toDouble(),
                                              e.value.completedTests
                                                  .toDouble(),
                                            ))
                                        .toList(),
                                    color: AppTheme.statusCompleted,
                                    dotData:
                                        const FlDotData(show: true),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.statusCompleted
                                          .withAlpha(30),
                                    ),
                                  ),
                                ],
                                bottomLabels: trends
                                    .map((t) =>
                                        '${t.trendDate.month}/${t.trendDate.day}')
                                    .toList(),
                              );
                            },
                            loading: () => const LoadingIndicator(),
                            error: (e, s) =>
                                AppErrorWidget(message: '$e'),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
