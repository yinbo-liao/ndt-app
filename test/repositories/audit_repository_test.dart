import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/audit_log_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('AuditRepository model parsing', () {
    final sampleJson = {
      'id': 'a1000000-0000-0000-0000-000000000001',
      'table_name': 'ndt_contractor_register',
      'record_id': 'r1000000-0000-0000-0000-000000000001',
      'action': 'INSERT',
      'old_data': null,
      'new_data': {
        'certificate_no': 'CERT-UT-001',
        'validation_status': 'valid',
      },
      'changed_by': 'u1000000-0000-0000-0000-000000000001',
      'changed_at': '2026-06-01T08:00:00.000Z',
      'ip_address': '192.168.1.100',
    };

    test('fromJson parses audit log entry correctly', () {
      final model = AuditLogModel.fromJson(sampleJson);
      expect(model.tableName, 'ndt_contractor_register');
      expect(model.recordId, 'r1000000-0000-0000-0000-000000000001');
      expect(model.action, 'INSERT');
      expect(model.oldData, isNull);
      expect(model.newData, isNotNull);
      expect(model.changedBy, 'u1000000-0000-0000-0000-000000000001');
      expect(model.changedAt, isNotNull);
      expect(model.ipAddress, '192.168.1.100');
    });

    test('fromJson handles all action types', () {
      for (final action in ['INSERT', 'UPDATE', 'DELETE']) {
        final json = {...sampleJson, 'action': action};
        final model = AuditLogModel.fromJson(json);
        expect(model.action, action);
      }
    });

    test('fromJson handles UPDATE with both old and new data', () {
      final json = {
        ...sampleJson,
        'action': 'UPDATE',
        'old_data': {'validation_status': 'valid'},
        'new_data': {'validation_status': 'expired'},
      };
      final model = AuditLogModel.fromJson(json);
      expect(model.action, 'UPDATE');
      expect(model.oldData, isNotNull);
      expect(model.newData, isNotNull);
    });

    test('safeList parses multiple audit entries', () {
      final jsonList = [
        sampleJson,
        {
          ...sampleJson,
          'id': 'a2',
          'table_name': 'projects',
          'action': 'UPDATE',
        },
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => AuditLogModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].tableName, 'ndt_contractor_register');
      expect(models[1].tableName, 'projects');
    });
  });
}
