import 'package:equatable/equatable.dart';

/// Daily deployment summary for a specific project.
class DailyProjectSummary extends Equatable {
  final String projectId;
  final String projectName;
  final DateTime deploymentDate;
  final int dayShiftCount;
  final int nightShiftCount;
  final int totalTeams;
  final int totalPersonnel;
  final int completedTests;
  final int inProgressTests;
  final int rejectedTests;
  final double totalTestLength;
  final double totalRejectLength;
  final List<String> locations;

  const DailyProjectSummary({
    required this.projectId,
    required this.projectName,
    required this.deploymentDate,
    this.dayShiftCount = 0,
    this.nightShiftCount = 0,
    this.totalTeams = 0,
    this.totalPersonnel = 0,
    this.completedTests = 0,
    this.inProgressTests = 0,
    this.rejectedTests = 0,
    this.totalTestLength = 0.0,
    this.totalRejectLength = 0.0,
    this.locations = const [],
  });

  int get totalShiftCount => dayShiftCount + nightShiftCount;

  factory DailyProjectSummary.fromJson(Map<String, dynamic> json) {
    return DailyProjectSummary(
      projectId: json['project_id'] as String,
      projectName: json['project_name'] as String,
      deploymentDate: DateTime.parse(json['deployment_date'] as String),
      dayShiftCount: (json['day_shift_count'] as num?)?.toInt() ?? 0,
      nightShiftCount: (json['night_shift_count'] as num?)?.toInt() ?? 0,
      totalTeams: (json['total_teams'] as num?)?.toInt() ?? 0,
      totalPersonnel: (json['total_personnel'] as num?)?.toInt() ?? 0,
      completedTests: (json['completed_tests'] as num?)?.toInt() ?? 0,
      inProgressTests: (json['in_progress_tests'] as num?)?.toInt() ?? 0,
      rejectedTests: (json['rejected_tests'] as num?)?.toInt() ?? 0,
      totalTestLength: (json['total_test_length'] as num?)?.toDouble() ?? 0.0,
      totalRejectLength:
          (json['total_reject_length'] as num?)?.toDouble() ?? 0.0,
      locations: json['locations'] is List
          ? (json['locations'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'project_name': projectName,
        'deployment_date': deploymentDate.toIso8601String().split('T')[0],
        'day_shift_count': dayShiftCount,
        'night_shift_count': nightShiftCount,
        'total_teams': totalTeams,
        'total_personnel': totalPersonnel,
        'completed_tests': completedTests,
        'in_progress_tests': inProgressTests,
        'rejected_tests': rejectedTests,
        'total_test_length': totalTestLength,
        'total_reject_length': totalRejectLength,
        'locations': locations,
      };

  @override
  List<Object?> get props => [
        projectId,
        projectName,
        deploymentDate,
        dayShiftCount,
        nightShiftCount,
        totalTeams,
        totalPersonnel,
        completedTests,
        inProgressTests,
        rejectedTests,
        totalTestLength,
        totalRejectLength,
        locations,
      ];
}

/// Daily deployment summary for a specific NDT company.
class DailyCompanySummary extends Equatable {
  final String companyId;
  final String companyName;
  final DateTime deploymentDate;
  final int totalProjects;
  final int dayShiftCount;
  final int nightShiftCount;
  final int totalTeams;
  final int totalPersonnel;
  final int completedTests;
  final int inProgressTests;
  final int rejectedTests;
  final int notStartedTests;
  final double totalTestLength;
  final double totalRejectLength;
  final double avgRejectRate;

  const DailyCompanySummary({
    required this.companyId,
    required this.companyName,
    required this.deploymentDate,
    this.totalProjects = 0,
    this.dayShiftCount = 0,
    this.nightShiftCount = 0,
    this.totalTeams = 0,
    this.totalPersonnel = 0,
    this.completedTests = 0,
    this.inProgressTests = 0,
    this.rejectedTests = 0,
    this.notStartedTests = 0,
    this.totalTestLength = 0.0,
    this.totalRejectLength = 0.0,
    this.avgRejectRate = 0.0,
  });

  factory DailyCompanySummary.fromJson(Map<String, dynamic> json) {
    return DailyCompanySummary(
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      deploymentDate: DateTime.parse(json['deployment_date'] as String),
      totalProjects: (json['total_projects'] as num?)?.toInt() ?? 0,
      dayShiftCount: (json['day_shift_count'] as num?)?.toInt() ?? 0,
      nightShiftCount: (json['night_shift_count'] as num?)?.toInt() ?? 0,
      totalTeams: (json['total_teams'] as num?)?.toInt() ?? 0,
      totalPersonnel: (json['total_personnel'] as num?)?.toInt() ?? 0,
      completedTests: (json['completed_tests'] as num?)?.toInt() ?? 0,
      inProgressTests: (json['in_progress_tests'] as num?)?.toInt() ?? 0,
      rejectedTests: (json['rejected_tests'] as num?)?.toInt() ?? 0,
      notStartedTests: (json['not_started_tests'] as num?)?.toInt() ?? 0,
      totalTestLength: (json['total_test_length'] as num?)?.toDouble() ?? 0.0,
      totalRejectLength:
          (json['total_reject_length'] as num?)?.toDouble() ?? 0.0,
      avgRejectRate: (json['avg_reject_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'company_id': companyId,
        'company_name': companyName,
        'deployment_date': deploymentDate.toIso8601String().split('T')[0],
        'total_projects': totalProjects,
        'day_shift_count': dayShiftCount,
        'night_shift_count': nightShiftCount,
        'total_teams': totalTeams,
        'total_personnel': totalPersonnel,
        'completed_tests': completedTests,
        'in_progress_tests': inProgressTests,
        'rejected_tests': rejectedTests,
        'not_started_tests': notStartedTests,
        'total_test_length': totalTestLength,
        'total_reject_length': totalRejectLength,
        'avg_reject_rate': avgRejectRate,
      };

  @override
  List<Object?> get props => [
        companyId,
        companyName,
        deploymentDate,
        totalProjects,
        dayShiftCount,
        nightShiftCount,
        totalTeams,
        totalPersonnel,
        completedTests,
        inProgressTests,
        rejectedTests,
        notStartedTests,
        totalTestLength,
        totalRejectLength,
        avgRejectRate,
      ];
}

/// Weekly deployment trend data point.
class WeeklyTrend extends Equatable {
  final DateTime trendDate;
  final int dayShiftCount;
  final int nightShiftCount;
  final int completedTests;
  final double totalTestLength;
  final double totalRejectLength;

  const WeeklyTrend({
    required this.trendDate,
    this.dayShiftCount = 0,
    this.nightShiftCount = 0,
    this.completedTests = 0,
    this.totalTestLength = 0.0,
    this.totalRejectLength = 0.0,
  });

  factory WeeklyTrend.fromJson(Map<String, dynamic> json) {
    return WeeklyTrend(
      trendDate: DateTime.parse(json['trend_date'] as String),
      dayShiftCount: (json['day_shift_count'] as num?)?.toInt() ?? 0,
      nightShiftCount: (json['night_shift_count'] as num?)?.toInt() ?? 0,
      completedTests: (json['completed_tests'] as num?)?.toInt() ?? 0,
      totalTestLength: (json['total_test_length'] as num?)?.toDouble() ?? 0.0,
      totalRejectLength:
          (json['total_reject_length'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'trend_date': trendDate.toIso8601String().split('T')[0],
        'day_shift_count': dayShiftCount,
        'night_shift_count': nightShiftCount,
        'completed_tests': completedTests,
        'total_test_length': totalTestLength,
        'total_reject_length': totalRejectLength,
      };

  @override
  List<Object?> get props => [
        trendDate,
        dayShiftCount,
        nightShiftCount,
        completedTests,
        totalTestLength,
        totalRejectLength,
      ];
}
