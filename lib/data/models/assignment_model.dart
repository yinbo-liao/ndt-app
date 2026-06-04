import 'package:equatable/equatable.dart';

/// Assignment role: supervisor, technician, inspector, or helper.
enum AssignmentRole { supervisor, technician, inspector, helper }

/// Assignment status: active, completed, on_hold, or removed.
enum AssignmentStatus { active, completed, onHold, removed }

/// NDT Team Assignment model mapped to `ndt_team_assignments`.
class AssignmentModel extends Equatable {
  final String id;
  final String userId;
  final String projectId;
  final String ndtCompanyId;
  final AssignmentRole assignedRole;
  final AssignmentStatus status;
  final DateTime? assignedFrom;
  final DateTime? assignedTo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AssignmentModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.ndtCompanyId,
    this.assignedRole = AssignmentRole.technician,
    this.status = AssignmentStatus.active,
    this.assignedFrom,
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
  });

  // ── DB string helpers ─────────────────────────────────────

  String get roleValue => assignedRole.name;
  String get statusValue {
    switch (status) {
      case AssignmentStatus.completed:
        return 'completed';
      case AssignmentStatus.onHold:
        return 'on_hold';
      case AssignmentStatus.removed:
        return 'removed';
      default:
        return 'active';
    }
  }

  // ── Serialization ─────────────────────────────────────────

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String,
      ndtCompanyId: json['ndt_company_id'] as String,
      assignedRole: _parseRole(json['assigned_role'] as String?),
      status: _parseStatus(json['status'] as String?),
      assignedFrom: json['assigned_from'] != null
          ? DateTime.tryParse(json['assigned_from'] as String)
          : null,
      assignedTo: json['assigned_to'] != null
          ? DateTime.tryParse(json['assigned_to'] as String)
          : null,
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
      'user_id': userId,
      'project_id': projectId,
      'ndt_company_id': ndtCompanyId,
      'assigned_role': roleValue,
      'status': statusValue,
      if (assignedFrom != null)
        'assigned_from': assignedFrom!.toIso8601String().split('T')[0],
      if (assignedTo != null)
        'assigned_to': assignedTo!.toIso8601String().split('T')[0],
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  AssignmentModel copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? ndtCompanyId,
    AssignmentRole? assignedRole,
    AssignmentStatus? status,
    DateTime? assignedFrom,
    DateTime? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      assignedRole: assignedRole ?? this.assignedRole,
      status: status ?? this.status,
      assignedFrom: assignedFrom ?? this.assignedFrom,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        projectId,
        ndtCompanyId,
        assignedRole,
        status,
        assignedFrom,
        assignedTo,
        createdAt,
        updatedAt,
      ];

  static AssignmentRole _parseRole(String? value) {
    switch (value) {
      case 'supervisor':
        return AssignmentRole.supervisor;
      case 'inspector':
        return AssignmentRole.inspector;
      case 'helper':
        return AssignmentRole.helper;
      default:
        return AssignmentRole.technician;
    }
  }

  static AssignmentStatus _parseStatus(String? value) {
    switch (value) {
      case 'completed':
        return AssignmentStatus.completed;
      case 'on_hold':
        return AssignmentStatus.onHold;
      case 'removed':
        return AssignmentStatus.removed;
      default:
        return AssignmentStatus.active;
    }
  }
}
