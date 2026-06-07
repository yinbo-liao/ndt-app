import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/company_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('CompanyRepository model parsing', () {
    final sampleJson = {
      'id': 'c1000000-0000-0000-0000-000000000001',
      'name': 'NDT Solutions Pte Ltd',
      'registration_no': 'REG-2024-001',
      'contact_email': 'contact@ndtsolutions.com',
      'contact_phone': '+6567890123',
      'address': '123 Tuas View, Singapore',
      'supervisor': 'Mr. Supervisor',
      'active': true,
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-05-15T10:30:00.000Z',
    };

    test('fromJson parses company correctly', () {
      final model = CompanyModel.fromJson(sampleJson);
      expect(model.name, 'NDT Solutions Pte Ltd');
      expect(model.registrationNo, 'REG-2024-001');
      expect(model.contactEmail, 'contact@ndtsolutions.com');
      expect(model.active, isTrue);
    });

    test('fromJson handles minimal JSON', () {
      final model = CompanyModel.fromJson({
        'id': 'c-id',
        'name': 'Min Co',
      });
      expect(model.name, 'Min Co');
      expect(model.registrationNo, isNull);
      expect(model.active, isTrue);
    });

    test('safeList parses multiple companies', () {
      final jsonList = [sampleJson, {...sampleJson, 'id': 'c2', 'name': 'Co 2'}];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => CompanyModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].name, 'NDT Solutions Pte Ltd');
      expect(models[1].name, 'Co 2');
    });

    test('toJson-roundtrip for company', () {
      final original = CompanyModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = CompanyModel.fromJson(json);
      expect(roundTripped, original);
    });
  });
}
