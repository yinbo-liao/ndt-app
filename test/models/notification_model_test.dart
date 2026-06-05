import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    final sampleJson = {
      'id': 't1000000-0000-0000-0000-000000000001',
      'user_id': 'u1000000-0000-0000-0000-000000000002',
      'title': 'Certificate Expiring Soon',
      'body': 'CERT-UT-001 expires on 2026-06-01.',
      'type': 'cert_expiry',
      'read': false,
      'created_at': '2026-05-01T08:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = NotificationModel.fromJson(sampleJson);

      expect(model.id, 't1000000-0000-0000-0000-000000000001');
      expect(model.userId, 'u1000000-0000-0000-0000-000000000002');
      expect(model.title, 'Certificate Expiring Soon');
      expect(model.body, 'CERT-UT-001 expires on 2026-06-01.');
      expect(model.type, 'cert_expiry');
      expect(model.read, isFalse);
      expect(model.createdAt, isNotNull);
    });

    test('fromJson handles missing optional fields', () {
      final minimalJson = {
        'id': 't-id',
        'user_id': 'u-id',
        'title': 'Test',
      };
      final model = NotificationModel.fromJson(minimalJson);
      expect(model.body, isNull);
      expect(model.type, isNull);
      expect(model.read, isFalse);
      expect(model.createdAt, isNull);
    });

    test('default read is false', () {
      final model = NotificationModel(
        id: 'id',
        userId: 'uid',
        title: 'Test',
      );
      expect(model.read, isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = NotificationModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = NotificationModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = NotificationModel.fromJson(sampleJson);
      final copied = model.copyWith(read: true, title: 'Updated');
      expect(copied.read, isTrue);
      expect(copied.title, 'Updated');
      expect(copied.body, model.body); // unchanged
    });

    test('toJson excludes null optional fields', () {
      final model = NotificationModel(
        id: 'id',
        userId: 'uid',
        title: 'Test',
        read: true,
      );
      final json = model.toJson();
      expect(json.containsKey('body'), isFalse);
      expect(json.containsKey('type'), isFalse);
      expect(json['read'], true);
    });

    test('props includes all fields', () {
      final model = NotificationModel.fromJson(sampleJson);
      expect(model.props.length, 7);
    });
  });
}
