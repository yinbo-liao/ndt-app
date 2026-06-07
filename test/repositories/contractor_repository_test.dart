import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/contractor_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('ContractorRepository model parsing', () {
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
    };

    test('ContractorModel.fromJson parses a contractor correctly', () {
      final model = ContractorModel.fromJson(sampleJson);
      expect(model.certificateNo, 'CERT-UT-001');
      expect(model.typeOfNdt, 'Ultrasonic Testing');
      expect(model.validationStatus, 'valid');
      expect(model.issueDate, DateTime(2025, 1, 15));
      expect(model.expireDate, DateTime(2028, 1, 15));
      expect(model.reportMonth, DateTime(2026, 1, 1));
    });

    test('isExpiringSoon detects certificates expiring in 30 days', () {
      final futureDate = DateTime.now().add(const Duration(days: 10));
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

    test('deletedAt is null for active records', () {
      final model = ContractorModel.fromJson(sampleJson);
      expect(model.deletedAt, isNull);
    });

    test('deletedAt is set for soft-deleted records', () {
      final json = {...sampleJson, 'deleted_at': '2026-07-01T00:00:00.000Z'};
      final model = ContractorModel.fromJson(json);
      expect(model.deletedAt, isNotNull);
    });
  });

  group('safeList parsing', () {
    test('parses list of contractor JSON into models', () {
      final jsonList = [
        {
          'id': 'r1',
          'ndt_company_id': 'c1',
          'type_of_ndt': 'UT',
          'type_of_ndt_certificate': 'UT Level II',
          'certificate_no': 'CERT-UT',
          'issue_date': '2025-01-15',
          'expire_date': '2028-01-15',
          'report_month': '2026-01-01',
        },
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => ContractorModel.fromJson(json)).toList();

      expect(models.length, 1);
      expect(models[0].certificateNo, 'CERT-UT');
    });

    test('handles empty response gracefully', () {
      final safeList = SupabaseClientWrapper.safeList([]);
      final models =
          safeList.map((json) => ContractorModel.fromJson(json)).toList();
      expect(models, isEmpty);
    });
  });
}
