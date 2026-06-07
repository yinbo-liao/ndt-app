import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/professional_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('ProfessionalRepository model parsing', () {
    final sampleJson = {
      'id': 'pr1000000-0000-0000-0000-000000000001',
      'name': 'Ahmed bin Ali',
      'type_of_certificate': 'UT',
      'certified_by': 'ASNT',
      'issued_date': '2025-03-15',
      'expiry_date': '2028-03-15',
      'certificate_status': 'valid',
      'working_sector': 'marine_section',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
    };

    test('fromJson parses professional correctly', () {
      final model = ProfessionalModel.fromJson(sampleJson);
      expect(model.name, 'Ahmed bin Ali');
      expect(model.typeOfCertificate, 'UT');
      expect(model.certifiedBy, 'ASNT');
      expect(model.issuedDate, DateTime(2025, 3, 15));
      expect(model.expiryDate, DateTime(2028, 3, 15));
      expect(model.certificateStatus, 'valid');
      expect(model.workingSector, 'marine_section');
    });

    test('sectorLabel returns correct display text', () {
      final marine = ProfessionalModel.fromJson(sampleJson);
      expect(marine.sectorLabel, 'Marine');

      final industry = ProfessionalModel.fromJson({
        ...sampleJson,
        'working_sector': 'industry_section',
      });
      expect(industry.sectorLabel, 'Industry');
    });

    test('isExpired detects expired certificates', () {
      final expired = ProfessionalModel(
        id: 'id',
        name: 'Expired',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2022, 1, 1),
        expiryDate: DateTime(2023, 1, 1),
        workingSector: 'marine_section',
      );
      expect(expired.isExpired, isTrue);

      final valid = ProfessionalModel(
        id: 'id',
        name: 'Valid',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: DateTime(2028, 1, 1),
        workingSector: 'marine_section',
      );
      expect(valid.isExpired, isFalse);
    });

    test('isDeleted detects soft-deleted records', () {
      final active = ProfessionalModel.fromJson(sampleJson);
      expect(active.isDeleted, isFalse);

      final deleted = ProfessionalModel(
        id: 'id',
        name: 'Deleted',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: DateTime(2028, 1, 1),
        workingSector: 'marine_section',
        deletedAt: DateTime(2026, 1, 1),
      );
      expect(deleted.isDeleted, isTrue);
    });

    test('safeList parses multiple professionals', () {
      final jsonList = [sampleJson, {...sampleJson, 'id': 'pr2', 'name': 'Bob'}];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => ProfessionalModel.fromJson(json)).toList();

      expect(models.length, 2);
      expect(models[0].name, 'Ahmed bin Ali');
      expect(models[1].name, 'Bob');
    });
  });
}
