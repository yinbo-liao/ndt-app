import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/company_model.dart';

void main() {
  group('CompanyModel', () {
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

    test('fromJson parses all fields correctly', () {
      final model = CompanyModel.fromJson(sampleJson);

      expect(model.id, 'c1000000-0000-0000-0000-000000000001');
      expect(model.name, 'NDT Solutions Pte Ltd');
      expect(model.registrationNo, 'REG-2024-001');
      expect(model.contactEmail, 'contact@ndtsolutions.com');
      expect(model.contactPhone, '+6567890123');
      expect(model.address, '123 Tuas View, Singapore');
      expect(model.supervisor, 'Mr. Supervisor');
      expect(model.active, isTrue);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'c-id',
        'name': 'Minimal Company',
      };
      final model = CompanyModel.fromJson(minimalJson);

      expect(model.registrationNo, isNull);
      expect(model.contactEmail, isNull);
      expect(model.contactPhone, isNull);
      expect(model.address, isNull);
      expect(model.supervisor, isNull);
      expect(model.active, isTrue);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('fromJson defaults active to true when null', () {
      final json = Map<String, dynamic>.from(sampleJson)..['active'] = null;
      final model = CompanyModel.fromJson(json);
      expect(model.active, isTrue);
    });

    test('fromJson sets active to false', () {
      final json = Map<String, dynamic>.from(sampleJson)..['active'] = false;
      final model = CompanyModel.fromJson(json);
      expect(model.active, isFalse);
    });

    test('toJson includes all fields', () {
      final model = CompanyModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['name'], 'NDT Solutions Pte Ltd');
      expect(json['registration_no'], 'REG-2024-001');
      expect(json['contact_email'], 'contact@ndtsolutions.com');
      expect(json['contact_phone'], '+6567890123');
      expect(json['address'], '123 Tuas View, Singapore');
      expect(json['supervisor'], 'Mr. Supervisor');
      expect(json['active'], true);
    });

    test('toJson excludes null optional fields', () {
      final model = CompanyModel(id: 'id', name: 'Test Co');
      final json = model.toJson();

      expect(json.containsKey('registration_no'), isFalse);
      expect(json.containsKey('contact_email'), isFalse);
      expect(json.containsKey('contact_phone'), isFalse);
      expect(json.containsKey('address'), isFalse);
      expect(json.containsKey('supervisor'), isFalse);
    });

    test('toJson excludes id when empty', () {
      final model = CompanyModel(id: '', name: 'Test Co');
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = CompanyModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = CompanyModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = CompanyModel.fromJson(sampleJson);
      final copied = model.copyWith(
        name: 'New Name',
        address: 'New Address',
      );

      expect(copied.name, 'New Name');
      expect(copied.address, 'New Address');
      expect(copied.registrationNo, model.registrationNo); // unchanged
      expect(copied.active, model.active); // unchanged
    });

    test('props includes all fields', () {
      final model = CompanyModel.fromJson(sampleJson);
      expect(model.props.length, 10);
    });

    test('equality works correctly', () {
      final a = CompanyModel.fromJson(sampleJson);
      final b = CompanyModel.fromJson(sampleJson);
      final c = a.copyWith(name: 'Different');

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
