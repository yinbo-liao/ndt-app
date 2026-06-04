/// Summary DTO for chart data serialization.
///
/// Provides normalized structures for fl_chart consumption.
class ChartDataPoint {
  final String label;
  final double value;
  final String? color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

/// Shift comparison data for bar/column charts.
class ShiftComparisonData {
  final String label; // e.g., project name or date
  final double dayCount;
  final double nightCount;

  const ShiftComparisonData({
    required this.label,
    required this.dayCount,
    required this.nightCount,
  });
}

/// Contractor summary breakdown for pie/donut charts.
class ContractorSummaryData {
  final int total;
  final int validCount;
  final int expiredCount;
  final int pendingCount;
  final int revokedCount;
  final int expiringSoon;
  final double complianceRate;

  const ContractorSummaryData({
    this.total = 0,
    this.validCount = 0,
    this.expiredCount = 0,
    this.pendingCount = 0,
    this.revokedCount = 0,
    this.expiringSoon = 0,
    this.complianceRate = 0.0,
  });

  factory ContractorSummaryData.fromJson(Map<String, dynamic> json) {
    return ContractorSummaryData(
      total: (json['total'] as num?)?.toInt() ?? 0,
      validCount: (json['valid_count'] as num?)?.toInt() ?? 0,
      expiredCount: (json['expired_count'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      revokedCount: (json['revoked_count'] as num?)?.toInt() ?? 0,
      expiringSoon: (json['expiring_soon'] as num?)?.toInt() ?? 0,
      complianceRate: (json['compliance_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  List<ChartDataPoint> toChartData() {
    return [
      ChartDataPoint(label: 'Valid', value: validCount.toDouble()),
      ChartDataPoint(label: 'Expired', value: expiredCount.toDouble()),
      ChartDataPoint(label: 'Pending', value: pendingCount.toDouble()),
      ChartDataPoint(label: 'Revoked', value: revokedCount.toDouble()),
    ];
  }
}
