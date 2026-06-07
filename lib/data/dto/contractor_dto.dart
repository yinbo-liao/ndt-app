import '../models/contractor_model.dart';

/// Data Transfer Object for enriched contractor list views.
///
/// Combines contractor data with related entity names
/// (company name, professional name) for display in lists.
class ContractorDTO {
  final ContractorModel contractor;
  final String? companyName;
  final String? professionalName;

  const ContractorDTO({
    required this.contractor,
    this.companyName,
    this.professionalName,
  });

  /// Display label for the associated company.
  String get companyLabel => companyName ?? 'Unknown';

  /// Display label for the associated professional.
  String get professionalLabel => professionalName ?? '—';

  factory ContractorDTO.fromJson(Map<String, dynamic> json) {
    final companies = json['ndt_companies'] as Map<String, dynamic>?;
    // Professional join requires ndt_professional_id column in DB
    // (see migration 006_contractor_professional_link.sql).
    // Once the migration is applied, add:
    //   ,ndt_professional_register:ndt_professional_id(name)
    // to the select query and uncomment the line below.
    final professionals =
        json['ndt_professional_register'] as Map<String, dynamic>?;

    return ContractorDTO(
      contractor: ContractorModel.fromJson(json),
      companyName: companies?['name'] as String?,
      professionalName: professionals?['name'] as String?,
    );
  }
}
