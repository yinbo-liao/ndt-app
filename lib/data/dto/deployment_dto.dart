import '../models/deployment_model.dart';

/// Data Transfer Object for enriched deployment list views.
///
/// Combines deployment data with related entity names
/// (project name, company name) for display in lists.
class DeploymentDTO {
  final DeploymentModel deployment;
  final String? projectName;
  final String? projectCode;
  final String? companyName;
  final String? planningTask;

  const DeploymentDTO({
    required this.deployment,
    this.projectName,
    this.projectCode,
    this.companyName,
    this.planningTask,
  });

  /// Builds a deployment name for display.
  String get displayTitle => '${projectName ?? 'Unknown'} - ${deployment.teamDeployment}';

  /// Whether this is a day shift deployment.
  bool get isDayShift => deployment.shift == ShiftType.day;

  /// Whether this is a night shift deployment.
  bool get isNightShift => deployment.shift == ShiftType.night;

  factory DeploymentDTO.fromJson(Map<String, dynamic> json) {
    // Supabase embedded foreign key uses table name as key
    final planning = json['project_ndt_planning'] as Map<String, dynamic>?;
    final project = planning?['projects'] as Map<String, dynamic>?;
    final company = json['ndt_companies'] as Map<String, dynamic>?;

    return DeploymentDTO(
      deployment: DeploymentModel.fromJson(json),
      projectName: project?['project_name'] as String?,
      projectCode: project?['project_code'] as String?,
      companyName: company?['name'] as String?,
      planningTask: planning?['ndt_company_task'] as String?,
    );
  }
}
