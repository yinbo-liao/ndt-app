import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final sampleJson = {
      'id': 'u1000000-0000-0000-0000-000000000001',
      'full_name': 'John Doe',
      'email': 'john@example.com',
      'role': 'admin',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'phone': '+6512345678',
      'employee_id': 'EMP001',
      'active': true,
      'created_at': '2026-01-15T08:00:00.000Z',
      'updated_at': '2026-06-01T12:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = UserModel.fromJson(sampleJson);

      expect(model.id, 'u1000000-0000-0000-0000-000000000001');
      expect(model.fullName, 'John Doe');
      expect(model.email, 'john@example.com');
      expect(model.role, 'admin');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.phone, '+6512345678');
      expect(model.employeeId, 'EMP001');
      expect(model.active, isTrue);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'u-id',
        'full_name': 'Min User',
        'email': 'min@test.com',
        'role': 'ndt_team',
      };
      final model = UserModel.fromJson(minimalJson);

      expect(model.ndtCompanyId, isNull);
      expect(model.phone, isNull);
      expect(model.employeeId, isNull);
      expect(model.active, isTrue); // default
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('fromJson defaults active to true when null', () {
      final json = Map<String, dynamic>.from(sampleJson)..['active'] = null;
      final model = UserModel.fromJson(json);
      expect(model.active, isTrue);
    });

    test('toJson includes all non-null fields', () {
      final model = UserModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['full_name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['role'], 'admin');
      expect(json['ndt_company_id'], 'c1000000-0000-0000-0000-000000000001');
      expect(json['phone'], '+6512345678');
      expect(json['employee_id'], 'EMP001');
      expect(json['active'], true);
    });

    test('toJson excludes null optional fields', () {
      final model = UserModel(
        id: 'id',
        fullName: 'Name',
        email: 'e@test.com',
        role: 'ndt_team',
      );
      final json = model.toJson();

      expect(json.containsKey('phone'), isFalse);
      expect(json.containsKey('employee_id'), isFalse);
      expect(json.containsKey('ndt_company_id'), isFalse);
    });

    test('toJson excludes id when empty', () {
      final model = UserModel(
        id: '',
        fullName: 'Name',
        email: 'e@test.com',
        role: 'ndt_team',
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = UserModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = UserModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = UserModel.fromJson(sampleJson);
      final copied = model.copyWith(fullName: 'Jane Doe', role: 'ndt_company');

      expect(copied.fullName, 'Jane Doe');
      expect(copied.role, 'ndt_company');
      expect(copied.email, model.email); // unchanged
      expect(copied.ndtCompanyId, model.ndtCompanyId); // unchanged
    });

    test('copyWith updates optional field correctly', () {
      final model = UserModel.fromJson(sampleJson);
      final copied = model.copyWith(phone: '+6598765432');

      expect(copied.phone, '+6598765432');
      expect(copied.ndtCompanyId, model.ndtCompanyId); // unchanged
    });

    test('copyWith preserves original value when not specified', () {
      final model = UserModel.fromJson(sampleJson);
      final copied = model.copyWith(fullName: 'New Name');

      expect(copied.phone, model.phone); // preserved
      expect(copied.employeeId, model.employeeId); // preserved
      expect(copied.fullName, 'New Name'); // updated
    });

    test('props includes all fields', () {
      final model = UserModel.fromJson(sampleJson);
      expect(model.props.length, 10);
    });

    test('equality works correctly', () {
      final a = UserModel.fromJson(sampleJson);
      final b = UserModel.fromJson(sampleJson);
      final c = a.copyWith(fullName: 'Different');

      expect(a, b);
      expect(a, isNot(c));
    });

    test('createdAt and updatedAt parse as UTC timestamps', () {
      final model = UserModel.fromJson(sampleJson);
      expect(model.createdAt!.isUtc, isTrue);
      expect(model.updatedAt!.isUtc, isTrue);
    });
  });
}
