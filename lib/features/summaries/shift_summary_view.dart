import 'package:flutter/material.dart';
import '../../data/models/summary_model.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/charts/shift_comparison_chart.dart';

/// Shift breakdown summary view for the daily summary page.
class ShiftSummaryView extends StatelessWidget {
  final DailyProjectSummary summary;

  const ShiftSummaryView({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shift Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ShiftCard(
                    icon: Icons.wb_sunny,
                    iconColor: AppTheme.dayShiftColor,
                    title: 'Day Shift',
                    count: summary.dayShiftCount,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShiftCard(
                    icon: Icons.nights_stay,
                    iconColor: AppTheme.nightShiftColor,
                    title: 'Night Shift',
                    count: summary.nightShiftCount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ShiftComparisonChart(
              dayCount: summary.dayShiftCount.toDouble(),
              nightCount: summary.nightShiftCount.toDouble(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;

  const _ShiftCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$count deployments',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
