import 'package:equatable/equatable.dart';

/// User model mapped to the `users` table (profiles extension of auth.users).
class UserModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String role; // 'admin', 'ndt_company', 'ndt_team'
  final String? ndtCompanyId;
  final String? phone;
  final String? employeeId;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.ndtCompanyId,
    this.phone,
    this.employeeId,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      ndtCompanyId: json['ndt_company_id'] as String?,
      phone: json['phone'] as String?,
      employeeId: json['employee_id'] as String?,
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
      'full_name': fullName,
      'email': email,
      'role': role,
      if (ndtCompanyId != null) 'ndt_company_id': ndtCompanyId,
      if (phone != null) 'phone': phone,
      if (employeeId != null) 'employee_id': employeeId,
      'active': active,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? role,
    String? ndtCompanyId,
    String? phone,
    String? employeeId,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      phone: phone ?? this.phone,
      employeeId: employeeId ?? this.employeeId,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        role,
        ndtCompanyId,
        phone,
        employeeId,
        active,
        createdAt,
        updatedAt,
      ];
}
