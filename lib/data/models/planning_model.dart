import 'package:equatable/equatable.dart';

/// Project NDT Planning model mapped to `project_ndt_planning`.
class PlanningModel extends Equatable {
  final String id;
  final String projectId;
  final String ndtCompanyId;
  final DateTime? ndtRfiDate;
  final String ndtCompanyTask;
  final DateTime? plannedStartDate;
  final DateTime? plannedEndDate;
  final String testingStatus; // 'planned','in_progress','completed','rejected','on_hold'
  final double testLength;
  final double rejectLength;
  final String priority; // 'low','normal','high','urgent'
  final String? typeOfTesting; // UT, MT, PT, RT, VT
  final String? discipline; // 'structure','piping','mechanical','electrical'
  final String? jobDescription;
  final String? siteContact;
  final String? subcontractor;
  final String? jobLocation;
  final String teamDeployStatus; // 'not_deployed','deployed','in_progress','completed'
  final String acceptStatus; // 'accept','reject','pending'
  final bool rfiSentToTeam; // RFI dispatched to team flag (migration 002)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlanningModel({
    required this.id,
    required this.projectId,
    required this.ndtCompanyId,
    this.ndtRfiDate,
    required this.ndtCompanyTask,
    this.plannedStartDate,
    this.plannedEndDate,
    this.testingStatus = 'planned',
    this.testLength = 0.0,
    this.rejectLength = 0.0,
    this.priority = 'normal',
    this.typeOfTesting,
    this.discipline,
    this.jobDescription,
    this.siteContact,
    this.subcontractor,
    this.jobLocation,
    this.teamDeployStatus = 'not_deployed',
    this.acceptStatus = 'pending',
    this.rfiSentToTeam = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PlanningModel.fromJson(Map<String, dynamic> json) {
    return PlanningModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      ndtCompanyId: json['ndt_company_id'] as String,
      ndtRfiDate: json['ndt_rfi_date'] != null
          ? DateTime.tryParse(json['ndt_rfi_date'] as String)
          : null,
      ndtCompanyTask: json['ndt_company_task'] as String,
      plannedStartDate: json['planned_start_date'] != null
          ? DateTime.tryParse(json['planned_start_date'] as String)
          : null,
      plannedEndDate: json['planned_end_date'] != null
          ? DateTime.tryParse(json['planned_end_date'] as String)
          : null,
      testingStatus: json['testing_status'] as String? ?? 'planned',
      testLength: (json['test_length'] as num?)?.toDouble() ?? 0.0,
      rejectLength: (json['reject_length'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority'] as String? ?? 'normal',
      typeOfTesting: json['type_of_testing'] as String?,
      discipline: json['discipline'] as String?,
      jobDescription: json['job_description'] as String?,
      siteContact: json['site_contact'] as String?,
      subcontractor: json['subcontractor'] as String?,
      jobLocation: json['job_location'] as String?,
      teamDeployStatus:
          json['team_deploy_status'] as String? ?? 'not_deployed',
      acceptStatus: json['accept_status'] as String? ?? 'pending',
      rfiSentToTeam: json['rfi_sent_to_team'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'project_id': projectId,
      'ndt_company_id': ndtCompanyId,
      if (ndtRfiDate != null)
        'ndt_rfi_date': ndtRfiDate!.toIso8601String().split('T')[0],
      'ndt_company_task': ndtCompanyTask,
      if (plannedStartDate != null)
        'planned_start_date': plannedStartDate!.toIso8601String().split('T')[0],
      if (plannedEndDate != null)
        'planned_end_date': plannedEndDate!.toIso8601String().split('T')[0],
      'testing_status': testingStatus,
      'test_length': testLength,
      'reject_length': rejectLength,
      'priority': priority,
      if (typeOfTesting != null) 'type_of_testing': typeOfTesting,
      if (discipline != null) 'discipline': discipline,
      if (jobDescription != null) 'job_description': jobDescription,
      if (siteContact != null) 'site_contact': siteContact,
      if (subcontractor != null) 'subcontractor': subcontractor,
      if (jobLocation != null) 'job_location': jobLocation,
      'team_deploy_status': teamDeployStatus,
      'accept_status': acceptStatus,
      'rfi_sent_to_team': rfiSentToTeam,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  PlanningModel copyWith({
    String? id,
    String? projectId,
    String? ndtCompanyId,
    DateTime? ndtRfiDate,
    String? ndtCompanyTask,
    DateTime? plannedStartDate,
    DateTime? plannedEndDate,
    String? testingStatus,
    double? testLength,
    double? rejectLength,
    String? priority,
    String? typeOfTesting,
    String? discipline,
    String? jobDescription,
    String? siteContact,
    String? subcontractor,
    String? jobLocation,
    String? teamDeployStatus,
    String? acceptStatus,
    bool? rfiSentToTeam,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanningModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      ndtRfiDate: ndtRfiDate ?? this.ndtRfiDate,
      ndtCompanyTask: ndtCompanyTask ?? this.ndtCompanyTask,
      plannedStartDate: plannedStartDate ?? this.plannedStartDate,
      plannedEndDate: plannedEndDate ?? this.plannedEndDate,
      testingStatus: testingStatus ?? this.testingStatus,
      testLength: testLength ?? this.testLength,
      rejectLength: rejectLength ?? this.rejectLength,
      priority: priority ?? this.priority,
      typeOfTesting: typeOfTesting ?? this.typeOfTesting,
      discipline: discipline ?? this.discipline,
      jobDescription: jobDescription ?? this.jobDescription,
      siteContact: siteContact ?? this.siteContact,
      subcontractor: subcontractor ?? this.subcontractor,
      jobLocation: jobLocation ?? this.jobLocation,
      teamDeployStatus: teamDeployStatus ?? this.teamDeployStatus,
      acceptStatus: acceptStatus ?? this.acceptStatus,
      rfiSentToTeam: rfiSentToTeam ?? this.rfiSentToTeam,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        ndtCompanyId,
        ndtRfiDate,
        ndtCompanyTask,
        plannedStartDate,
        plannedEndDate,
        testingStatus,
        testLength,
        rejectLength,
        priority,
        typeOfTesting,
        discipline,
        jobDescription,
        siteContact,
        subcontractor,
        jobLocation,
        teamDeployStatus,
        acceptStatus,
        rfiSentToTeam,
        createdAt,
        updatedAt,
      ];
}
