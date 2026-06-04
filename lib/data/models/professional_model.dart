import 'package:equatable/equatable.dart';

/// NDT Professional Register model mapped to `ndt_professional_register`.
///
/// Tracks individual NDT professionals, their certifications, expiry dates,
/// and working sector (marine or industry). Supports soft delete.
class ProfessionalModel extends Equatable {
  final String id;
  final String name;
  final String typeOfCertificate; // UT, MT, PT, RT, VT
  final String? certifiedBy; // certifying body
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String certificateStatus; // 'valid','expired','pending','revoked'
  final String workingSector; // 'marine_section','industry_section'
  final String? ndtCompanyId;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt; // Soft delete

  const ProfessionalModel({
    required this.id,
    required this.name,
    required this.typeOfCertificate,
    this.certifiedBy,
    required this.issuedDate,
    required this.expiryDate,
    this.certificateStatus = 'valid',
    required this.workingSector,
    this.ndtCompanyId,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Whether the certificate is expiring within 30 days.
  bool get isExpiringSoon {
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= 30 && daysLeft > 0 && certificateStatus == 'valid';
  }

  /// Whether the certificate has expired.
  bool get isExpired {
    final today = DateTime.now();
    final expireDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final startOfToday = DateTime(today.year, today.month, today.day);
    return expireDay.isBefore(startOfToday) && certificateStatus != 'revoked';
  }

  /// Whether the record is soft-deleted.
  bool get isDeleted => deletedAt != null;

  /// Display label for working sector.
  String get sectorLabel =>
      workingSector == 'industry_section' ? 'Industry' : 'Marine';

  factory ProfessionalModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      typeOfCertificate: json['type_of_certificate'] as String,
      certifiedBy: json['certified_by'] as String?,
      issuedDate: DateTime.parse(json['issued_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      certificateStatus:
          json['certificate_status'] as String? ?? 'valid',
      workingSector: json['working_sector'] as String,
      ndtCompanyId: json['ndt_company_id'] as String?,
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
      'name': name,
      'type_of_certificate': typeOfCertificate,
      if (certifiedBy != null) 'certified_by': certifiedBy,
      'issued_date': issuedDate.toIso8601String().split('T')[0],
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      'certificate_status': certificateStatus,
      'working_sector': workingSector,
      if (ndtCompanyId != null) 'ndt_company_id': ndtCompanyId,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null)
        'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null)
        'updated_at': updatedAt!.toUtc().toIso8601String(),
      if (deletedAt != null)
        'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  ProfessionalModel copyWith({
    String? id,
    String? name,
    String? typeOfCertificate,
    String? certifiedBy,
    DateTime? issuedDate,
    DateTime? expiryDate,
    String? certificateStatus,
    String? workingSector,
    String? ndtCompanyId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ProfessionalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      typeOfCertificate: typeOfCertificate ?? this.typeOfCertificate,
      certifiedBy: certifiedBy ?? this.certifiedBy,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      certificateStatus: certificateStatus ?? this.certificateStatus,
      workingSector: workingSector ?? this.workingSector,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        typeOfCertificate,
        certifiedBy,
        issuedDate,
        expiryDate,
        certificateStatus,
        workingSector,
        ndtCompanyId,
        createdBy,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
