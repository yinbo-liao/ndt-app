import 'package:equatable/equatable.dart';

/// NDT Company model mapped to the `ndt_companies` table.
class CompanyModel extends Equatable {
  final String id;
  final String name;
  final String? registrationNo;
  final String? contactEmail;
  final String? contactPhone;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyModel({
    required this.id,
    required this.name,
    this.registrationNo,
    this.contactEmail,
    this.contactPhone,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      registrationNo: json['registration_no'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
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
      'name': name,
      if (registrationNo != null) 'registration_no': registrationNo,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (contactPhone != null) 'contact_phone': contactPhone,
      'active': active,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
    };
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? registrationNo,
    String? contactEmail,
    String? contactPhone,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      registrationNo: registrationNo ?? this.registrationNo,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        registrationNo,
        contactEmail,
        contactPhone,
        active,
        createdAt,
        updatedAt,
      ];
}
