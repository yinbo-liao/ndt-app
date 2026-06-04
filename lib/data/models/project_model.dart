import 'package:equatable/equatable.dart';

/// Project model mapped to the `projects` table.
class ProjectModel extends Equatable {
  final String id;
  final String projectName;
  final String projectCode;
  final String? jobTrade;
  final String location;
  final String? clientName;
  final String? classification;
  final String? qaInchargeId;
  final String? ndtCompanyId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProjectModel({
    required this.id,
    required this.projectName,
    required this.projectCode,
    this.jobTrade,
    required this.location,
    this.clientName,
    this.classification,
    this.qaInchargeId,
    this.ndtCompanyId,
    this.startDate,
    this.endDate,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      projectName: json['project_name'] as String,
      projectCode: json['project_code'] as String,
      jobTrade: json['job_trade'] as String?,
      location: json['location'] as String,
      clientName: json['client_name'] as String?,
      classification: json['classification'] as String?,
      qaInchargeId: json['qa_incharge_id'] as String?,
      ndtCompanyId: json['ndt_company_id'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      active: json['active'] as bool? ?? true,
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
      'project_name': projectName,
      'project_code': projectCode,
      if (jobTrade != null) 'job_trade': jobTrade,
      'location': location,
      if (clientName != null) 'client_name': clientName,
      if (classification != null) 'classification': classification,
      if (qaInchargeId != null) 'qa_incharge_id': qaInchargeId,
      if (ndtCompanyId != null) 'ndt_company_id': ndtCompanyId,
      if (startDate != null) 'start_date': startDate!.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate!.toIso8601String().split('T')[0],
      'active': active,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? projectName,
    String? projectCode,
    String? jobTrade,
    String? location,
    String? clientName,
    String? classification,
    String? qaInchargeId,
    String? ndtCompanyId,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      projectCode: projectCode ?? this.projectCode,
      jobTrade: jobTrade ?? this.jobTrade,
      location: location ?? this.location,
      clientName: clientName ?? this.clientName,
      classification: classification ?? this.classification,
      qaInchargeId: qaInchargeId ?? this.qaInchargeId,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectName,
        projectCode,
        jobTrade,
        location,
        clientName,
        classification,
        qaInchargeId,
        ndtCompanyId,
        startDate,
        endDate,
        active,
        createdAt,
        updatedAt,
      ];
}
