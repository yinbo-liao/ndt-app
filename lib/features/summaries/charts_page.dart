import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    final params = WeeklyTrendParams(
      projectId: widget.projectId,
      startDate: _startDate,
      endDate: _endDate,
    );

    final trendAsync = ref.watch(weeklyTrendProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Charts & Trends'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child:
                        Text('From: ${_startDate.toIsoDateString}'),
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
                    child: Text('To: ${_endDate.toIsoDateString}'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Weekly Deployment Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: trendAsync.when(
                data: (trends) {
                  if (trends.isEmpty) {
                    return Center(
                      child: Text(
                        'No trend data for this period',
                        style: TextStyle(color: Colors.grey[500]),
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
                                  e.value.completedTests.toDouble(),
                                ))
                            .toList(),
                        color: AppTheme.statusCompleted,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.statusCompleted.withAlpha(30),
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
                error: (e, s) => AppErrorWidget(message: '$e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
