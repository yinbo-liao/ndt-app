import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/dto/contractor_dto.dart';

void main() {
  group('ContractorDTO', () {
    final sampleJson = {
      'id': 'r1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'type_of_ndt': 'Ultrasonic Testing',
      'type_of_ndt_certificate': 'UT Level II',
      'certificate_no': 'CERT-UT-001',
      'issue_date': '2025-01-15',
      'expire_date': '2028-01-15',
      'validation_status': 'valid',
      'report_month': '2026-01-01',
      'ndt_companies': {'name': 'Test NDT Company Ltd'},
    };

    test('fromJson parses contractor with joined company name', () {
      final dto = ContractorDTO.fromJson(sampleJson);
      expect(dto.contractor.certificateNo, 'CERT-UT-001');
      expect(dto.companyName, 'Test NDT Company Ltd');
    });

    test('companyLabel returns company name when present', () {
      final dto = ContractorDTO.fromJson(sampleJson);
      expect(dto.companyLabel, 'Test NDT Company Ltd');
    });

    test('companyLabel returns Unknown when company not joined', () {
      final json = {
        'id': 'r1',
        'ndt_company_id': 'c1',
        'type_of_ndt': 'UT',
        'type_of_ndt_certificate': 'UT Level II',
        'certificate_no': 'CERT-UT',
        'issue_date': '2025-01-15',
        'expire_date': '2028-01-15',
        'report_month': '2026-01-01',
      };
      final dto = ContractorDTO.fromJson(json);
      expect(dto.companyLabel, 'Unknown');
    });

    test('professionalLabel returns — when no professional joined', () {
      final dto = ContractorDTO.fromJson(sampleJson);
      expect(dto.professionalLabel, '—'); // em dash
    });

    test('fromJson with professional join parses professionalName', () {
      final json = {
        ...sampleJson,
        'ndt_professional_register': {'name': 'John Smith'},
      };
      final dto = ContractorDTO.fromJson(json);
      expect(dto.professionalName, 'John Smith');
      expect(dto.professionalLabel, 'John Smith');
    });

    test('fromJson with null joined tables does not crash', () {
      final json = {
        ...sampleJson,
        'ndt_companies': null,
        'ndt_professional_register': null,
      };
      final dto = ContractorDTO.fromJson(json);
      expect(dto.companyName, isNull);
      expect(dto.professionalName, isNull);
    });
  });
}
