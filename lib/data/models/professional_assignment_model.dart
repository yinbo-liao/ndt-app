import 'package:equatable/equatable.dart';

/// Professional-to-RFI assignment model mapped to
/// `ndt_professional_assignments`.
///
/// Links NDT professionals to specific RFI/planning entries so that
/// supervisors can task individual professionals to projects.
class ProfessionalAssignmentModel extends Equatable {
  final String id;
  final String planningId;
  final String professionalId;
  final String assignedRole; // 'technician','inspector','helper','supervisor'
  final String status; // 'assigned','active','completed','removed'
  final DateTime? assignedAt;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProfessionalAssignmentModel({
    required this.id,
    required this.planningId,
    required this.professionalId,
    this.assignedRole = 'technician',
    this.status = 'assigned',
    this.assignedAt,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfessionalAssignmentModel.fromJson(
      Map<String, dynamic> json) {
    return ProfessionalAssignmentModel(
      id: json['id'] as String,
      planningId: json['planning_id'] as String,
      professionalId: json['professional_id'] as String,
      assignedRole:
          json['assigned_role'] as String? ?? 'technician',
      status: json['status'] as String? ?? 'assigned',
      assignedAt: json['assigned_at'] != null
          ? DateTime.tryParse(json['assigned_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
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
      'planning_id': planningId,
      'professional_id': professionalId,
      'assigned_role': assignedRole,
      'status': status,
      if (assignedAt != null)
        'assigned_at': assignedAt!.toUtc().toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null)
        'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null)
        'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  ProfessionalAssignmentModel copyWith({
    String? id,
    String? planningId,
    String? professionalId,
    String? assignedRole,
    String? status,
    DateTime? assignedAt,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfessionalAssignmentModel(
      id: id ?? this.id,
      planningId: planningId ?? this.planningId,
      professionalId: professionalId ?? this.professionalId,
      assignedRole: assignedRole ?? this.assignedRole,
      status: status ?? this.status,
      assignedAt: assignedAt ?? this.assignedAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        planningId,
        professionalId,
        assignedRole,
        status,
        assignedAt,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
