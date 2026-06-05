import 'package:equatable/equatable.dart';

/// Audit log model mapped to `audit_logs`.
class AuditLogModel extends Equatable {
  final String id;
  final String tableName;
  final String recordId;
  final String action; // 'INSERT','UPDATE','DELETE'
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final String? changedBy;
  final DateTime? changedAt;
  final String? ipAddress;
  // Populated from Supabase join: users!changed_by(full_name, email)
  final String? changedByUserName;
  final String? changedByUserEmail;

  const AuditLogModel({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.action,
    this.oldData,
    this.newData,
    this.changedBy,
    this.changedAt,
    this.ipAddress,
    this.changedByUserName,
    this.changedByUserEmail,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String,
      tableName: json['table_name'] as String,
      recordId: json['record_id'] as String,
      action: json['action'] as String,
      oldData: json['old_data'] as Map<String, dynamic>?,
      newData: json['new_data'] as Map<String, dynamic>?,
      changedBy: json['changed_by'] as String?,
      changedAt: json['changed_at'] != null
          ? DateTime.tryParse(json['changed_at'] as String)
          : null,
      ipAddress: json['ip_address'] as String?,
      changedByUserName:
          (json['users'] as Map<String, dynamic>?)?['full_name'] as String?,
      changedByUserEmail:
          (json['users'] as Map<String, dynamic>?)?['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      if (oldData != null) 'old_data': oldData,
      if (newData != null) 'new_data': newData,
      if (changedBy != null) 'changed_by': changedBy,
      if (changedAt != null)
        'changed_at': changedAt!.toUtc().toIso8601String(),
      if (ipAddress != null) 'ip_address': ipAddress,
    };
  }

  @override
  List<Object?> get props => [
        id,
        tableName,
        recordId,
        action,
        oldData,
        newData,
        changedBy,
        changedAt,
        ipAddress,
        changedByUserName,
        changedByUserEmail,
      ];
}
