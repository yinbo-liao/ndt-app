import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Reusable bar chart widget wrapping fl_chart's BarChart.
class BarChartWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<String> bottomLabels;
  final String? xAxisTitle;
  final String? yAxisTitle;

  const BarChartWidget({
    super.key,
    required this.barGroups,
    this.bottomLabels = const [],
    this.xAxisTitle,
    this.yAxisTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(),
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= bottomLabels.length) {
                  return const SizedBox.shrink();
                }
                return Text(
                  bottomLabels[index],
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
      ),
    );
  }

  double _calculateMaxY() {
    double max = 0;
    for (final group in barGroups) {
      for (final rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    return max * 1.2; // 20% padding
  }
}
