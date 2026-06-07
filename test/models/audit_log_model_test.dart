import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/audit_log_model.dart';

void main() {
  group('AuditLogModel', () {
    final sampleJson = {
      'id': 'al-00000000-0000-0000-0000-000000000001',
      'table_name': 'ndt_contractor_register',
      'record_id': 'r1000000-0000-0000-0000-000000000001',
      'action': 'UPDATE',
      'old_data': {'validation_status': 'pending'},
      'new_data': {'validation_status': 'valid'},
      'changed_by': 'u1000000-0000-0000-0000-000000000001',
      'changed_at': '2026-06-01T12:00:00.000Z',
      'ip_address': '192.168.1.100',
      'users': {
        'full_name': 'Admin User',
        'email': 'admin@example.com',
      },
    };

    test('fromJson parses all fields correctly', () {
      final model = AuditLogModel.fromJson(sampleJson);

      expect(model.id, 'al-00000000-0000-0000-0000-000000000001');
      expect(model.tableName, 'ndt_contractor_register');
      expect(model.recordId, 'r1000000-0000-0000-0000-000000000001');
      expect(model.action, 'UPDATE');
      expect(model.oldData, {'validation_status': 'pending'});
      expect(model.newData, {'validation_status': 'valid'});
      expect(model.changedBy, 'u1000000-0000-0000-0000-000000000001');
      expect(model.changedAt, isNotNull);
      expect(model.ipAddress, '192.168.1.100');
      expect(model.changedByUserName, 'Admin User');
      expect(model.changedByUserEmail, 'admin@example.com');
    });

    test('fromJson parses user join fields from nested users object', () {
      final model = AuditLogModel.fromJson(sampleJson);
      expect(model.changedByUserName, 'Admin User');
      expect(model.changedByUserEmail, 'admin@example.com');
    });

    test('fromJson handles missing users join', () {
      final json = Map<String, dynamic>.from(sampleJson)..remove('users');
      final model = AuditLogModel.fromJson(json);

      expect(model.changedByUserName, isNull);
      expect(model.changedByUserEmail, isNull);
    });

    test('fromJson handles missing optional fields', () {
      final minimalJson = {
        'id': 'al-id',
        'table_name': 'projects',
        'record_id': 'p-id',
        'action': 'INSERT',
      };
      final model = AuditLogModel.fromJson(minimalJson);

      expect(model.oldData, isNull);
      expect(model.newData, isNull);
      expect(model.changedBy, isNull);
      expect(model.changedAt, isNull);
      expect(model.ipAddress, isNull);
      expect(model.changedByUserName, isNull);
      expect(model.changedByUserEmail, isNull);
    });

    test('fromJson handles null oldData and newData', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['old_data'] = null
        ..['new_data'] = null;
      final model = AuditLogModel.fromJson(json);

      expect(model.oldData, isNull);
      expect(model.newData, isNull);
    });

    test('fromJson parses all action types', () {
      expect(
        AuditLogModel.fromJson({...sampleJson, 'action': 'INSERT'}).action,
        'INSERT',
      );
      expect(
        AuditLogModel.fromJson({...sampleJson, 'action': 'UPDATE'}).action,
        'UPDATE',
      );
      expect(
        AuditLogModel.fromJson({...sampleJson, 'action': 'DELETE'}).action,
        'DELETE',
      );
    });

    test('toJson includes all required fields', () {
      final model = AuditLogModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['table_name'], 'ndt_contractor_register');
      expect(json['record_id'], 'r1000000-0000-0000-0000-000000000001');
      expect(json['action'], 'UPDATE');
      expect(json['old_data'], {'validation_status': 'pending'});
      expect(json['new_data'], {'validation_status': 'valid'});
      expect(json['changed_by'], 'u1000000-0000-0000-0000-000000000001');
      expect(json['ip_address'], '192.168.1.100');
    });

    test('toJson excludes null optional fields', () {
      final model = AuditLogModel(
        id: 'id',
        tableName: 'test',
        recordId: 'r-id',
        action: 'INSERT',
      );
      final json = model.toJson();

      expect(json.containsKey('old_data'), isFalse);
      expect(json.containsKey('new_data'), isFalse);
      expect(json.containsKey('changed_by'), isFalse);
      expect(json.containsKey('changed_at'), isFalse);
      expect(json.containsKey('ip_address'), isFalse);
    });

    test('toJson does NOT include user join fields', () {
      final model = AuditLogModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json.containsKey('users'), isFalse);
      expect(json.containsKey('changed_by_user_name'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = AuditLogModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = AuditLogModel.fromJson(json);

      // Join fields won't survive round-trip (they come from join, not stored)
      expect(roundTripped.id, original.id);
      expect(roundTripped.tableName, original.tableName);
      expect(roundTripped.recordId, original.recordId);
      expect(roundTripped.action, original.action);
      expect(roundTripped.oldData, original.oldData);
      expect(roundTripped.newData, original.newData);
      expect(roundTripped.changedBy, original.changedBy);
    });

    test('props includes all fields', () {
      final model = AuditLogModel.fromJson(sampleJson);
      expect(model.props.length, 11);
    });

    test('equality works correctly', () {
      final a = AuditLogModel.fromJson(sampleJson);
      final b = AuditLogModel.fromJson(sampleJson);
      final c = AuditLogModel(
        id: 'different',
        tableName: 'test',
        recordId: 'r',
        action: 'DELETE',
      );

      expect(a, b);
      expect(a, isNot(c));
    });

    test('toJson excludes id when empty', () {
      final model = AuditLogModel(
        id: '',
        tableName: 'test',
        recordId: 'r',
        action: 'INSERT',
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
    });
  });
}
