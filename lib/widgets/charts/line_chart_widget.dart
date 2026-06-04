import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Reusable line chart widget for trend data.
class LineChartWidget extends StatelessWidget {
  final List<LineChartBarData> lineBars;
  final List<String> bottomLabels;
  final String? xAxisTitle;
  final String? yAxisTitle;

  const LineChartWidget({
    super.key,
    required this.lineBars,
    this.bottomLabels = const [],
    this.xAxisTitle,
    this.yAxisTitle,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: lineBars,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}
