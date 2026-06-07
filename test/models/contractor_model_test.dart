import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/contractor_model.dart';

void main() {
  group('ContractorModel', () {
    final sampleJson = {
      'id': 'r1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'type_of_ndt': 'Ultrasonic Testing',
      'type_of_ndt_certificate': 'UT Level II',
      'certificate_no': 'CERT-UT-001',
      'certificate_type': 'ASNT',
      'issue_date': '2025-01-15',
      'expire_date': '2028-01-15',
      'validation_status': 'valid',
      'report_month': '2026-01-01',
      'created_by': 'u1000000-0000-0000-0000-000000000001',
      'created_at': '2026-01-15T08:00:00.000Z',
      'updated_at': '2026-06-01T12:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = ContractorModel.fromJson(sampleJson);

      expect(model.id, 'r1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.typeOfNdt, 'Ultrasonic Testing');
      expect(model.typeOfNdtCertificate, 'UT Level II');
      expect(model.certificateNo, 'CERT-UT-001');
      expect(model.certificateType, 'ASNT');
      expect(model.issueDate, DateTime(2025, 1, 15));
      expect(model.expireDate, DateTime(2028, 1, 15));
      expect(model.validationStatus, 'valid');
      expect(model.reportMonth, DateTime(2026, 1, 1));
      expect(model.createdBy, 'u1000000-0000-0000-0000-000000000001');
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
      expect(model.deletedAt, isNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'r-id',
        'ndt_company_id': 'c-id',
        'type_of_ndt': 'MT',
        'type_of_ndt_certificate': 'MT Level I',
        'certificate_no': 'CERT-MT',
        'issue_date': '2025-06-01',
        'expire_date': '2028-06-01',
        'report_month': '2026-06-01',
      };
      final model = ContractorModel.fromJson(minimalJson);

      expect(model.certificateType, isNull);
      expect(model.validationStatus, 'pending'); // default
      expect(model.createdBy, isNull);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
      expect(model.deletedAt, isNull);
    });

    test('fromJson defaults validation_status to pending when null', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['validation_status'] = null;
      final model = ContractorModel.fromJson(json);
      expect(model.validationStatus, 'pending');
    });

    test('fromJson handles deleted_at for soft-deleted records', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['deleted_at'] = '2026-07-01T00:00:00.000Z';
      final model = ContractorModel.fromJson(json);
      expect(model.deletedAt, isNotNull);
    });

    test('isExpiringSoon returns true when valid and <= 30 days left', () {
      final futureDate = DateTime.now().add(const Duration(days: 15));
      final model = ContractorModel(
        id: 'id',
        ndtCompanyId: 'c-id',
        typeOfNdt: 'UT',
        typeOfNdtCertificate: 'UT',
        certificateNo: 'CERT',
        issueDate: DateTime(2025, 1, 1),
        expireDate: futureDate,
        validationStatus: 'valid',
        reportMonth: DateTime(2026, 6, 1),
      );
      expect(model.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon returns false when expired', () {
      final model = ContractorModel(
        id: 'id',
        ndtCompanyId: 'c-id',
        typeOfNdt: 'UT',
        typeOfNdtCertificate: 'UT',
        certificateNo: 'CERT',
        issueDate: DateTime(2023, 1, 1),
        expireDate: DateTime(2024, 1, 1),
        validationStatus: 'valid',
        reportMonth: DateTime(2026, 6, 1),
      );
      expect(model.isExpiringSoon, isFalse);
    });

    test('isExpiringSoon returns false when > 30 days left', () {
      final futureDate = DateTime.now().add(const Duration(days: 60));
      final model = ContractorModel(
        id: 'id',
        ndtCompanyId: 'c-id',
        typeOfNdt: 'UT',
        typeOfNdtCertificate: 'UT',
        certificateNo: 'CERT',
        issueDate: DateTime(2025, 1, 1),
        expireDate: futureDate,
        validationStatus: 'valid',
        reportMonth: DateTime(2026, 6, 1),
      );
      expect(model.isExpiringSoon, isFalse);
    });

    test('toJson serializes dates as yyyy-MM-dd', () {
      final model = ContractorModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['issue_date'], '2025-01-15');
      expect(json['expire_date'], '2028-01-15');
      expect(json['report_month'], '2026-01-01');
    });

    test('toJson excludes null optional fields', () {
      final model = ContractorModel(
        id: 'id',
        ndtCompanyId: 'c-id',
        typeOfNdt: 'UT',
        typeOfNdtCertificate: 'UT Level I',
        certificateNo: 'CERT',
        issueDate: DateTime(2025, 1, 1),
        expireDate: DateTime(2028, 1, 1),
        reportMonth: DateTime(2026, 6, 1),
      );
      final json = model.toJson();

      expect(json.containsKey('certificate_type'), isFalse);
      expect(json.containsKey('created_by'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
      expect(json.containsKey('deleted_at'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = ContractorModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = ContractorModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = ContractorModel.fromJson(sampleJson);
      final copied = model.copyWith(
        validationStatus: 'expired',
        certificateNo: 'CERT-UPDATED',
      );

      expect(copied.validationStatus, 'expired');
      expect(copied.certificateNo, 'CERT-UPDATED');
      expect(copied.typeOfNdt, model.typeOfNdt); // unchanged
    });

    test('props includes all fields', () {
      final model = ContractorModel.fromJson(sampleJson);
      expect(model.props.length, 17);
    });

    test('equality works correctly', () {
      final a = ContractorModel.fromJson(sampleJson);
      final b = ContractorModel.fromJson(sampleJson);
      final c = a.copyWith(certificateNo: 'DIFFERENT');

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
