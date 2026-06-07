import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/user_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('UserRepository model parsing', () {
    final sampleJson = {
      'id': 'u1000000-0000-0000-0000-000000000001',
      'full_name': 'John Doe',
      'email': 'john@example.com',
      'role': 'admin',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'phone': '+65 1234 5678',
      'employee_id': 'EMP-001',
      'active': true,
      'created_at': '2026-01-01T00:00:00.000Z',
      'updated_at': '2026-06-01T00:00:00.000Z',
    };

    test('fromJson parses user correctly', () {
      final model = UserModel.fromJson(sampleJson);
      expect(model.id, 'u1000000-0000-0000-0000-000000000001');
      expect(model.fullName, 'John Doe');
      expect(model.email, 'john@example.com');
      expect(model.role, 'admin');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.phone, '+65 1234 5678');
      expect(model.employeeId, 'EMP-001');
      expect(model.active, isTrue);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'u1',
        'full_name': 'Jane Smith',
        'email': 'jane@example.com',
        'role': 'ndt_team',
      };
      final model = UserModel.fromJson(json);
      expect(model.ndtCompanyId, isNull);
      expect(model.phone, isNull);
      expect(model.employeeId, isNull);
      expect(model.active, isTrue); // defaults to true
    });

    test('fromJson handles all role values', () {
      for (final role in ['admin', 'ndt_company', 'ndt_team']) {
        final json = {...sampleJson, 'role': role};
        final model = UserModel.fromJson(json);
        expect(model.role, role);
      }
    });

    test('fromJson handles active false', () {
      final json = {...sampleJson, 'active': false};
      final model = UserModel.fromJson(json);
      expect(model.active, isFalse);
    });

    test('toJson excludes id when empty', () {
      final model = UserModel(
        id: '',
        fullName: 'Test',
        email: 'test@example.com',
        role: 'admin',
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['full_name'], 'Test');
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'admin');
    });

    test('toJson round-trip preserves all fields', () {
      final original = UserModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = UserModel.fromJson(json);
      expect(roundTripped.fullName, original.fullName);
      expect(roundTripped.email, original.email);
      expect(roundTripped.role, original.role);
      expect(roundTripped.active, original.active);
    });

    test('safeList parses multiple users', () {
      final jsonList = [sampleJson, {...sampleJson, 'id': 'u2', 'role': 'ndt_team'}];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => UserModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].role, 'admin');
      expect(models[1].role, 'ndt_team');
    });
  });
}
