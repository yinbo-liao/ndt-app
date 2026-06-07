import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/professional_assignment_model.dart';

void main() {
  group('ProfessionalAssignmentModel', () {
    final sampleJson = {
      'id': 'pa1000000-0000-0000-0000-000000000001',
      'planning_id': 'n1000000-0000-0000-0000-000000000001',
      'professional_id': 'p1000000-0000-0000-0000-000000000001',
      'assigned_role': 'technician',
      'status': 'assigned',
      'assigned_at': '2026-06-01T08:00:00.000Z',
      'created_by': 'u1000000-0000-0000-0000-000000000001',
      'created_at': '2026-06-01T08:00:00.000Z',
      'updated_at': '2026-06-01T08:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = ProfessionalAssignmentModel.fromJson(sampleJson);
      expect(model.id, 'pa1000000-0000-0000-0000-000000000001');
      expect(model.planningId, 'n1000000-0000-0000-0000-000000000001');
      expect(model.professionalId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.assignedRole, 'technician');
      expect(model.status, 'assigned');
      expect(model.assignedAt, isNotNull);
      expect(model.assignedAt!.year, 2026);
      expect(model.assignedAt!.month, 6);
      expect(model.assignedAt!.day, 1);
      expect(model.createdBy, 'u1000000-0000-0000-0000-000000000001');
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'id': 'pa1',
        'planning_id': 'n1',
        'professional_id': 'p1',
      };
      final model = ProfessionalAssignmentModel.fromJson(json);
      expect(model.assignedRole, 'technician');
      expect(model.status, 'assigned');
      expect(model.assignedAt, isNull);
      expect(model.createdBy, isNull);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('fromJson handles null timestamps gracefully', () {
      final json = {
        ...sampleJson,
        'assigned_at': null,
        'created_at': null,
        'updated_at': null,
      };
      final model = ProfessionalAssignmentModel.fromJson(json);
      expect(model.assignedAt, isNull);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('fromJson parses all assigned_role values', () {
      for (final role in ['technician', 'inspector', 'helper', 'supervisor']) {
        final json = {...sampleJson, 'assigned_role': role};
        final model = ProfessionalAssignmentModel.fromJson(json);
        expect(model.assignedRole, role);
      }
    });

    test('fromJson parses all status values', () {
      for (final status in ['assigned', 'active', 'completed', 'removed']) {
        final json = {...sampleJson, 'status': status};
        final model = ProfessionalAssignmentModel.fromJson(json);
        expect(model.status, status);
      }
    });

    test('toJson includes all required fields', () {
      final model = ProfessionalAssignmentModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['planning_id'], 'n1000000-0000-0000-0000-000000000001');
      expect(json['professional_id'], 'p1000000-0000-0000-0000-000000000001');
      expect(json['assigned_role'], 'technician');
      expect(json['status'], 'assigned');
    });

    test('toJson excludes id when empty', () {
      final model = ProfessionalAssignmentModel(
        id: '',
        planningId: 'n1',
        professionalId: 'p1',
      );
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
    });

    test('toJson round-trip preserves all fields', () {
      final original = ProfessionalAssignmentModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = ProfessionalAssignmentModel.fromJson(json);
      expect(roundTripped.planningId, original.planningId);
      expect(roundTripped.professionalId, original.professionalId);
      expect(roundTripped.assignedRole, original.assignedRole);
      expect(roundTripped.status, original.status);
      expect(roundTripped.assignedAt, original.assignedAt);
    });

    test('copyWith updates specific fields', () {
      final model = ProfessionalAssignmentModel.fromJson(sampleJson);
      final copied = model.copyWith(
        assignedRole: 'supervisor',
        status: 'completed',
      );
      expect(copied.assignedRole, 'supervisor');
      expect(copied.status, 'completed');
      expect(copied.planningId, model.planningId); // unchanged
    });

    test('props includes all fields', () {
      final model = ProfessionalAssignmentModel.fromJson(sampleJson);
      expect(model.props.length, 9);
    });

    test('equality works correctly', () {
      final a = ProfessionalAssignmentModel.fromJson(sampleJson);
      final b = ProfessionalAssignmentModel.fromJson(sampleJson);
      final c = a.copyWith(status: 'completed');
      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
