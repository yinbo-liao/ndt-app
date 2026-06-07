import 'package:equatable/equatable.dart';

/// Shift type: day or night.
enum ShiftType { day, night }

/// Testing status for deployments.
enum DeploymentTestingStatus { notStarted, inProgress, completed, rejected }

/// A team member assigned to a deployment.
class TeamMember extends Equatable {
  final String userId;
  final String name;
  final String role;

  const TeamMember({
    required this.userId,
    required this.name,
    required this.role,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'role': role,
    };
  }

  @override
  List<Object?> get props => [userId, name, role];
}

/// NDT Team Deployment model mapped to `ndt_team_deployments`.
///
/// Includes shift management, team composition via JSONB,
/// equipment tracking, and soft delete support.
class DeploymentModel extends Equatable {
  final String id;
  final String projectNdtPlanningId;
  final String ndtCompanyId;
  final String? ndtSupervisorId;
  final ShiftType shift;
  final DateTime deploymentDate;
  final DateTime? deploymentStartTime;
  final DateTime? deploymentEndTime;
  final String teamDeployment; // Team name/identifier
  final List<TeamMember> teamMembers; // JSONB array of team members
  final String jobLocation;
  final DeploymentTestingStatus testingStatus;
  final double testLength;
  final double rejectLength;
  final List<String> equipmentUsed; // JSONB array of equipment IDs/names
  final String? dailyNotes;
  final String? weatherConditions;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt; // Soft delete

  const DeploymentModel({
    required this.id,
    required this.projectNdtPlanningId,
    required this.ndtCompanyId,
    this.ndtSupervisorId,
    this.shift = ShiftType.day,
    required this.deploymentDate,
    this.deploymentStartTime,
    this.deploymentEndTime,
    required this.teamDeployment,
    this.teamMembers = const [],
    required this.jobLocation,
    this.testingStatus = DeploymentTestingStatus.notStarted,
    this.testLength = 0.0,
    this.rejectLength = 0.0,
    this.equipmentUsed = const [],
    this.dailyNotes,
    this.weatherConditions,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // ── Helpers ────────────────────────────────────────────────

  /// The shift as a database string value.
  String get shiftValue => shift.name;

  /// The testing status as a database string value (snake_case for DB CHECK constraint).
  String get testingStatusValue {
    switch (testingStatus) {
      case DeploymentTestingStatus.notStarted:
        return 'not_started';
      case DeploymentTestingStatus.inProgress:
        return 'in_progress';
      case DeploymentTestingStatus.completed:
        return 'completed';
      case DeploymentTestingStatus.rejected:
        return 'rejected';
    }
  }

  /// Total number of team members assigned.
  int get memberCount => teamMembers.length;

  /// Whether the deployment is soft-deleted.
  bool get isDeleted => deletedAt != null;

  // ── Serialization ─────────────────────────────────────────

  factory DeploymentModel.fromJson(Map<String, dynamic> json) {
    return DeploymentModel(
      id: json['id'] as String,
      projectNdtPlanningId: json['project_ndt_planning_id'] as String,
      ndtCompanyId: json['ndt_company_id'] as String,
      ndtSupervisorId: json['ndt_supervisor_id'] as String?,
      shift: _parseShift(json['shift'] as String?),
      deploymentDate: DateTime.parse(json['deployment_date'] as String),
      deploymentStartTime: json['deployment_start_time'] != null
          ? DateTime.tryParse(json['deployment_start_time'] as String)
          : null,
      deploymentEndTime: json['deployment_end_time'] != null
          ? DateTime.tryParse(json['deployment_end_time'] as String)
          : null,
      teamDeployment: json['team_deployment'] as String,
      teamMembers: _parseTeamMembers(json['team_members']),
      jobLocation: json['job_location'] as String,
      testingStatus:
          _parseTestingStatus(json['testing_status'] as String?),
      testLength: (json['test_length'] as num?)?.toDouble() ?? 0.0,
      rejectLength: (json['reject_length'] as num?)?.toDouble() ?? 0.0,
      equipmentUsed: _parseStringList(json['equipment_used']),
      dailyNotes: json['daily_notes'] as String?,
      weatherConditions: json['weather_conditions'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'project_ndt_planning_id': projectNdtPlanningId,
      'ndt_company_id': ndtCompanyId,
      if (ndtSupervisorId != null) 'ndt_supervisor_id': ndtSupervisorId,
      'shift': shiftValue,
      'deployment_date': deploymentDate.toIso8601String().split('T')[0],
      if (deploymentStartTime != null)
        'deployment_start_time': deploymentStartTime!.toUtc().toIso8601String(),
      if (deploymentEndTime != null)
        'deployment_end_time': deploymentEndTime!.toUtc().toIso8601String(),
      'team_deployment': teamDeployment,
      'team_members': teamMembers.map((m) => m.toJson()).toList(),
      'job_location': jobLocation,
      'testing_status': testingStatusValue,
      'test_length': testLength,
      'reject_length': rejectLength,
      'equipment_used': equipmentUsed,
      if (dailyNotes != null) 'daily_notes': dailyNotes,
      if (weatherConditions != null) 'weather_conditions': weatherConditions,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  DeploymentModel copyWith({
    String? id,
    String? projectNdtPlanningId,
    String? ndtCompanyId,
    String? ndtSupervisorId,
    ShiftType? shift,
    DateTime? deploymentDate,
    DateTime? deploymentStartTime,
    DateTime? deploymentEndTime,
    String? teamDeployment,
    List<TeamMember>? teamMembers,
    String? jobLocation,
    DeploymentTestingStatus? testingStatus,
    double? testLength,
    double? rejectLength,
    List<String>? equipmentUsed,
    String? dailyNotes,
    String? weatherConditions,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return DeploymentModel(
      id: id ?? this.id,
      projectNdtPlanningId:
          projectNdtPlanningId ?? this.projectNdtPlanningId,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      ndtSupervisorId: ndtSupervisorId ?? this.ndtSupervisorId,
      shift: shift ?? this.shift,
      deploymentDate: deploymentDate ?? this.deploymentDate,
      deploymentStartTime: deploymentStartTime ?? this.deploymentStartTime,
      deploymentEndTime: deploymentEndTime ?? this.deploymentEndTime,
      teamDeployment: teamDeployment ?? this.teamDeployment,
      teamMembers: teamMembers ?? this.teamMembers,
      jobLocation: jobLocation ?? this.jobLocation,
      testingStatus: testingStatus ?? this.testingStatus,
      testLength: testLength ?? this.testLength,
      rejectLength: rejectLength ?? this.rejectLength,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      dailyNotes: dailyNotes ?? this.dailyNotes,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectNdtPlanningId,
        ndtCompanyId,
        ndtSupervisorId,
        shift,
        deploymentDate,
        deploymentStartTime,
        deploymentEndTime,
        teamDeployment,
        teamMembers,
        jobLocation,
        testingStatus,
        testLength,
        rejectLength,
        equipmentUsed,
        dailyNotes,
        weatherConditions,
        createdBy,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  // ── Private Parsers ───────────────────────────────────────

  static ShiftType _parseShift(String? value) {
    if (value == 'night') return ShiftType.night;
    return ShiftType.day;
  }

  static DeploymentTestingStatus _parseTestingStatus(String? value) {
    switch (value) {
      case 'in_progress':
        return DeploymentTestingStatus.inProgress;
      case 'completed':
        return DeploymentTestingStatus.completed;
      case 'rejected':
        return DeploymentTestingStatus.rejected;
      default:
        return DeploymentTestingStatus.notStarted;
    }
  }

  static List<TeamMember> _parseTeamMembers(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
