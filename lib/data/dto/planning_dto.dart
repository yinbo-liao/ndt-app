import '../models/planning_model.dart';

/// Data Transfer Object for enriched planning (RFI) views.
///
/// Combines planning data with related entity names
/// (project name/code, company name) for display in detail views.
class PlanningDTO {
  final PlanningModel planning;
  final String? projectName;
  final String? projectCode;
  final String? companyName;

  const PlanningDTO({
    required this.planning,
    this.projectName,
    this.projectCode,
    this.companyName,
  });

  /// Display title combining project name and code.
  String get projectLabel {
    if (projectName != null && projectCode != null) {
      return '$projectName ($projectCode)';
    }
    return projectName ?? 'Unknown Project';
  }

  /// Display label for the associated NDT company.
  String get companyLabel => companyName ?? 'Unknown Company';

  factory PlanningDTO.fromJson(Map<String, dynamic> json) {
    final projects = json['projects'] as Map<String, dynamic>?;
    final companies = json['ndt_companies'] as Map<String, dynamic>?;

    return PlanningDTO(
      planning: PlanningModel.fromJson(json),
      projectName: projects?['project_name'] as String?,
      projectCode: projects?['project_code'] as String?,
      companyName: companies?['name'] as String?,
    );
  }
}
