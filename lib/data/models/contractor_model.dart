import 'package:equatable/equatable.dart';
import '../../core/utils/extensions.dart';

/// NDT Contractor Register model mapped to `ndt_contractor_register`.
class ContractorModel extends Equatable {
  final String id;
  final String ndtCompanyId;
  final String typeOfNdt;
  final String typeOfNdtCertificate;
  final String certificateNo;
  final String? certificateType;
  final DateTime issueDate;
  final DateTime expireDate;
  final String validationStatus; // 'valid', 'expired', 'pending', 'revoked'
  final DateTime reportMonth; // First day of reporting month
  final String? ndtProfessionalId; // FK to ndt_professional_register
  final String? techId; // 4-character technician reference ID
  final String? technicianName; // Name of the technician
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt; // Soft delete

  const ContractorModel({
    required this.id,
    required this.ndtCompanyId,
    required this.typeOfNdt,
    required this.typeOfNdtCertificate,
    required this.certificateNo,
    this.certificateType,
    required this.issueDate,
    required this.expireDate,
    this.validationStatus = 'pending',
    required this.reportMonth,
    this.ndtProfessionalId,
    this.techId,
    this.technicianName,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Whether the certificate is expiring within 30 days.
  bool get isExpiringSoon {
    final daysLeft = expireDate.difference(DateTime.now()).inDays;
    return daysLeft <= 30 && daysLeft > 0 && validationStatus == 'valid';
  }

  factory ContractorModel.fromJson(Map<String, dynamic> json) {
    return ContractorModel(
      id: json['id'] as String,
      ndtCompanyId: json['ndt_company_id'] as String,
      typeOfNdt: json['type_of_ndt'] as String,
      typeOfNdtCertificate: json['type_of_ndt_certificate'] as String,
      certificateNo: json['certificate_no'] as String,
      certificateType: json['certificate_type'] as String?,
      issueDate: DateTime.parse(json['issue_date'] as String),
      expireDate: DateTime.parse(json['expire_date'] as String),
      validationStatus: json['validation_status'] as String? ?? 'pending',
      reportMonth: DateTime.parse(json['report_month'] as String),
      ndtProfessionalId: json['ndt_professional_id'] as String?,
      techId: json['tech_id'] as String?,
      technicianName: json['technician_name'] as String?,
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
      'ndt_company_id': ndtCompanyId,
      'type_of_ndt': typeOfNdt,
      'type_of_ndt_certificate': typeOfNdtCertificate,
      'certificate_no': certificateNo,
      if (certificateType != null) 'certificate_type': certificateType,
      'issue_date': issueDate.toIso8601String().split('T')[0],
      'expire_date': expireDate.toIso8601String().split('T')[0],
      'validation_status': validationStatus,
      'report_month': reportMonth.toIsoDateString,
      if (ndtProfessionalId != null) 'ndt_professional_id': ndtProfessionalId,
      if (techId != null) 'tech_id': techId,
      if (technicianName != null) 'technician_name': technicianName,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  ContractorModel copyWith({
    String? id,
    String? ndtCompanyId,
    String? typeOfNdt,
    String? typeOfNdtCertificate,
    String? certificateNo,
    String? certificateType,
    DateTime? issueDate,
    DateTime? expireDate,
    String? validationStatus,
    DateTime? reportMonth,
    String? ndtProfessionalId,
    String? techId,
    String? technicianName,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return ContractorModel(
      id: id ?? this.id,
      ndtCompanyId: ndtCompanyId ?? this.ndtCompanyId,
      typeOfNdt: typeOfNdt ?? this.typeOfNdt,
      typeOfNdtCertificate: typeOfNdtCertificate ?? this.typeOfNdtCertificate,
      certificateNo: certificateNo ?? this.certificateNo,
      certificateType: certificateType ?? this.certificateType,
      issueDate: issueDate ?? this.issueDate,
      expireDate: expireDate ?? this.expireDate,
      validationStatus: validationStatus ?? this.validationStatus,
      reportMonth: reportMonth ?? this.reportMonth,
      ndtProfessionalId: ndtProfessionalId ?? this.ndtProfessionalId,
      techId: techId ?? this.techId,
      technicianName: technicianName ?? this.technicianName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ndtCompanyId,
        typeOfNdt,
        typeOfNdtCertificate,
        certificateNo,
        certificateType,
        issueDate,
        expireDate,
        validationStatus,
        reportMonth,
        ndtProfessionalId,
        techId,
        technicianName,
        createdBy,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
