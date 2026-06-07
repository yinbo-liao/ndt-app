import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/professional_model.dart';

void main() {
  group('ProfessionalModel', () {
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
      'created_by': 'u1000000-0000-0000-0000-000000000001',
      'created_at': '2026-01-15T08:00:00.000Z',
      'updated_at': '2026-06-01T12:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = ProfessionalModel.fromJson(sampleJson);

      expect(model.id, 'pr1000000-0000-0000-0000-000000000001');
      expect(model.name, 'Ahmed bin Ali');
      expect(model.typeOfCertificate, 'UT');
      expect(model.certifiedBy, 'ASNT');
      expect(model.issuedDate, DateTime(2025, 3, 15));
      expect(model.expiryDate, DateTime(2028, 3, 15));
      expect(model.certificateStatus, 'valid');
      expect(model.workingSector, 'marine_section');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.createdBy, 'u1000000-0000-0000-0000-000000000001');
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
      expect(model.deletedAt, isNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'pr-id',
        'name': 'Min Professional',
        'type_of_certificate': 'MT',
        'issued_date': '2025-01-01',
        'expiry_date': '2028-01-01',
        'working_sector': 'industry_section',
      };
      final model = ProfessionalModel.fromJson(minimalJson);

      expect(model.certifiedBy, isNull);
      expect(model.certificateStatus, 'valid'); // default
      expect(model.ndtCompanyId, isNull);
      expect(model.createdBy, isNull);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
      expect(model.deletedAt, isNull);
    });

    test('fromJson defaults certificate_status to valid when null', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['certificate_status'] = null;
      final model = ProfessionalModel.fromJson(json);
      expect(model.certificateStatus, 'valid');
    });

    test('fromJson handles deleted_at for soft-deleted records', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['deleted_at'] = '2026-07-01T00:00:00.000Z';
      final model = ProfessionalModel.fromJson(json);
      expect(model.deletedAt, isNotNull);
    });

    test('sectorLabel returns Marine for marine_section', () {
      final model = ProfessionalModel.fromJson(sampleJson);
      expect(model.sectorLabel, 'Marine');
    });

    test('sectorLabel returns Industry for industry_section', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['working_sector'] = 'industry_section';
      final model = ProfessionalModel.fromJson(json);
      expect(model.sectorLabel, 'Industry');
    });

    test('isExpired returns true when expiry date is in the past', () {
      final model = ProfessionalModel(
        id: 'id',
        name: 'Expired Pro',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2022, 1, 1),
        expiryDate: DateTime(2023, 1, 1),
        workingSector: 'marine_section',
      );
      expect(model.isExpired, isTrue);
    });

    test('isExpired returns false when expiry date is in the future', () {
      final futureDate = DateTime.now().add(const Duration(days: 365));
      final model = ProfessionalModel(
        id: 'id',
        name: 'Valid Pro',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: futureDate,
        workingSector: 'marine_section',
      );
      expect(model.isExpired, isFalse);
    });

    test('isExpired returns false when status is revoked', () {
      final model = ProfessionalModel(
        id: 'id',
        name: 'Revoked Pro',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2022, 1, 1),
        expiryDate: DateTime(2023, 1, 1),
        certificateStatus: 'revoked',
        workingSector: 'marine_section',
      );
      expect(model.isExpired, isFalse);
    });

    test('isExpiringSoon returns true when valid and <= 30 days left', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
      final model = ProfessionalModel(
        id: 'id',
        name: 'Expiring',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: futureDate,
        certificateStatus: 'valid',
        workingSector: 'marine_section',
      );
      expect(model.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon returns false when > 30 days', () {
      final futureDate = DateTime.now().add(const Duration(days: 60));
      final model = ProfessionalModel(
        id: 'id',
        name: 'Not Expiring',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: futureDate,
        certificateStatus: 'valid',
        workingSector: 'marine_section',
      );
      expect(model.isExpiringSoon, isFalse);
    });

    test('isDeleted returns true when deleted_at is set', () {
      final model = ProfessionalModel(
        id: 'id',
        name: 'Deleted',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: DateTime(2028, 1, 1),
        workingSector: 'marine_section',
        deletedAt: DateTime(2026, 1, 1),
      );
      expect(model.isDeleted, isTrue);
    });

    test('isDeleted returns false when deleted_at is null', () {
      final model = ProfessionalModel.fromJson(sampleJson);
      expect(model.isDeleted, isFalse);
    });

    test('toJson serializes dates as yyyy-MM-dd', () {
      final model = ProfessionalModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['issued_date'], '2025-03-15');
      expect(json['expiry_date'], '2028-03-15');
    });

    test('toJson excludes null optional fields', () {
      final model = ProfessionalModel(
        id: 'id',
        name: 'Name',
        typeOfCertificate: 'UT',
        issuedDate: DateTime(2025, 1, 1),
        expiryDate: DateTime(2028, 1, 1),
        workingSector: 'marine_section',
      );
      final json = model.toJson();

      expect(json.containsKey('certified_by'), isFalse);
      expect(json.containsKey('ndt_company_id'), isFalse);
      expect(json.containsKey('created_by'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = ProfessionalModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = ProfessionalModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = ProfessionalModel.fromJson(sampleJson);
      final copied = model.copyWith(
        name: 'New Name',
        certificateStatus: 'expired',
      );

      expect(copied.name, 'New Name');
      expect(copied.certificateStatus, 'expired');
      expect(copied.typeOfCertificate, model.typeOfCertificate); // unchanged
    });

    test('props includes all fields', () {
      final model = ProfessionalModel.fromJson(sampleJson);
      expect(model.props.length, 13);
    });

    test('equality works correctly', () {
      final a = ProfessionalModel.fromJson(sampleJson);
      final b = ProfessionalModel.fromJson(sampleJson);
      final c = a.copyWith(name: 'Different');

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
