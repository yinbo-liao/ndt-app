import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/notification_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('NotificationRepository model parsing', () {
    final sampleJson = {
      'id': 'notif1',
      'user_id': 'u1000000-0000-0000-0000-000000000001',
      'title': 'Certificate Expiring Soon',
      'body': 'Your UT Level II certificate expires in 15 days.',
      'type': 'cert_expiry',
      'read': false,
      'created_at': '2026-06-01T08:00:00.000Z',
    };

    test('fromJson parses notification correctly', () {
      final model = NotificationModel.fromJson(sampleJson);
      expect(model.id, 'notif1');
      expect(model.userId, 'u1000000-0000-0000-0000-000000000001');
      expect(model.title, 'Certificate Expiring Soon');
      expect(model.body, 'Your UT Level II certificate expires in 15 days.');
      expect(model.type, 'cert_expiry');
      expect(model.read, isFalse);
      expect(model.createdAt, isNotNull);
    });

    test('fromJson handles read notification', () {
      final json = {...sampleJson, 'read': true};
      final model = NotificationModel.fromJson(json);
      expect(model.read, isTrue);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'n1',
        'user_id': 'u1',
        'title': 'Test',
      };
      final model = NotificationModel.fromJson(json);
      expect(model.body, isNull);
      expect(model.type, isNull);
      expect(model.read, isFalse); // default
    });

    test('fromJson handles all notification types', () {
      for (final type in ['cert_expiry', 'approval_needed', 'rfi_dispatched', 'deployment_assigned']) {
        final json = {...sampleJson, 'type': type};
        final model = NotificationModel.fromJson(json);
        expect(model.type, type);
      }
    });

    test('toJson round-trip preserves fields', () {
      final original = NotificationModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = NotificationModel.fromJson(json);
      expect(roundTripped.title, original.title);
      expect(roundTripped.body, original.body);
      expect(roundTripped.type, original.type);
      expect(roundTripped.read, original.read);
    });

    test('safeList parses multiple notifications', () {
      final jsonList = [
        sampleJson,
        {...sampleJson, 'id': 'n2', 'title': 'Deployment Assigned'},
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => NotificationModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].title, 'Certificate Expiring Soon');
      expect(models[1].title, 'Deployment Assigned');
    });
  });
}
