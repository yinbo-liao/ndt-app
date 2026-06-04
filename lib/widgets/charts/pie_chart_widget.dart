import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Reusable pie chart widget for distribution data.
class PieChartWidget extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final String? centerText;
  final double radius;

  const PieChartWidget({
    super.key,
    required this.sections,
    this.centerText,
    this.radius = 100,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: radius * 0.5,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

/// Helper to build a standard pie chart section.
PieChartSectionData buildPieSection({
  required double value,
  required Color color,
  required String label,
  double radius = 50,
  TextStyle? titleStyle,
}) {
  return PieChartSectionData(
    value: value,
    color: color,
    radius: radius,
    title: value > 0 ? label : '',
    titleStyle: titleStyle ??
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
  );
}
