import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/assignment_model.dart';

void main() {
  group('AssignmentModel', () {
    final sampleJson = {
      'id': 'a1000000-0000-0000-0000-000000000001',
      'user_id': 'u1000000-0000-0000-0000-000000000001',
      'project_id': 'p1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'assigned_role': 'supervisor',
      'status': 'active',
      'assigned_from': '2026-02-01',
      'assigned_to': '2026-12-31',
      'created_at': '2026-01-15T08:00:00.000Z',
      'updated_at': '2026-06-01T12:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = AssignmentModel.fromJson(sampleJson);

      expect(model.id, 'a1000000-0000-0000-0000-000000000001');
      expect(model.userId, 'u1000000-0000-0000-0000-000000000001');
      expect(model.projectId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.assignedRole, AssignmentRole.supervisor);
      expect(model.status, AssignmentStatus.active);
      expect(model.assignedFrom, DateTime(2026, 2, 1));
      expect(model.assignedTo, DateTime(2026, 12, 31));
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'a-id',
        'user_id': 'u-id',
        'project_id': 'p-id',
        'ndt_company_id': 'c-id',
      };
      final model = AssignmentModel.fromJson(minimalJson);

      expect(model.assignedRole, AssignmentRole.technician);
      expect(model.status, AssignmentStatus.active);
      expect(model.assignedFrom, isNull);
      expect(model.assignedTo, isNull);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
    });

    test('fromJson parses all role values correctly', () {
      expect(
        AssignmentModel.fromJson({...sampleJson, 'assigned_role': 'supervisor'})
            .assignedRole,
        AssignmentRole.supervisor,
      );
      expect(
        AssignmentModel.fromJson({...sampleJson, 'assigned_role': 'inspector'})
            .assignedRole,
        AssignmentRole.inspector,
      );
      expect(
        AssignmentModel.fromJson({...sampleJson, 'assigned_role': 'helper'})
            .assignedRole,
        AssignmentRole.helper,
      );
      expect(
        AssignmentModel.fromJson({...sampleJson, 'assigned_role': 'unknown'})
            .assignedRole,
        AssignmentRole.technician, // default
      );
    });

    test('fromJson parses all status values correctly', () {
      expect(
        AssignmentModel.fromJson({...sampleJson, 'status': 'completed'}).status,
        AssignmentStatus.completed,
      );
      expect(
        AssignmentModel.fromJson({...sampleJson, 'status': 'on_hold'}).status,
        AssignmentStatus.onHold,
      );
      expect(
        AssignmentModel.fromJson({...sampleJson, 'status': 'removed'}).status,
        AssignmentStatus.removed,
      );
      expect(
        AssignmentModel.fromJson({...sampleJson, 'status': 'unknown'}).status,
        AssignmentStatus.active, // default
      );
    });

    test('roleValue returns correct DB string', () {
      expect(
        AssignmentModel(
          id: 'id',
          userId: 'u',
          projectId: 'p',
          ndtCompanyId: 'c',
          assignedRole: AssignmentRole.supervisor,
        ).roleValue,
        'supervisor',
      );
      expect(
        AssignmentModel(
          id: 'id',
          userId: 'u',
          projectId: 'p',
          ndtCompanyId: 'c',
          assignedRole: AssignmentRole.inspector,
        ).roleValue,
        'inspector',
      );
    });

    test('statusValue returns correct DB string', () {
      expect(
        AssignmentModel(
          id: 'id',
          userId: 'u',
          projectId: 'p',
          ndtCompanyId: 'c',
          status: AssignmentStatus.completed,
        ).statusValue,
        'completed',
      );
      expect(
        AssignmentModel(
          id: 'id',
          userId: 'u',
          projectId: 'p',
          ndtCompanyId: 'c',
          status: AssignmentStatus.onHold,
        ).statusValue,
        'on_hold',
      );
      expect(
        AssignmentModel(
          id: 'id',
          userId: 'u',
          projectId: 'p',
          ndtCompanyId: 'c',
          status: AssignmentStatus.removed,
        ).statusValue,
        'removed',
      );
    });

    test('toJson serializes dates as yyyy-MM-dd', () {
      final model = AssignmentModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['assigned_from'], '2026-02-01');
      expect(json['assigned_to'], '2026-12-31');
    });

    test('toJson serializes role and status as DB strings', () {
      final model = AssignmentModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['assigned_role'], 'supervisor');
      expect(json['status'], 'active');
    });

    test('toJson round-trip preserves all fields', () {
      final original = AssignmentModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = AssignmentModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('copyWith updates specific fields', () {
      final model = AssignmentModel.fromJson(sampleJson);
      final copied = model.copyWith(
        assignedRole: AssignmentRole.inspector,
        status: AssignmentStatus.completed,
      );

      expect(copied.assignedRole, AssignmentRole.inspector);
      expect(copied.status, AssignmentStatus.completed);
      expect(copied.userId, model.userId); // unchanged
    });

    test('props includes all fields', () {
      final model = AssignmentModel.fromJson(sampleJson);
      expect(model.props.length, 10);
    });

    test('equality works correctly', () {
      final a = AssignmentModel.fromJson(sampleJson);
      final b = AssignmentModel.fromJson(sampleJson);
      final c = a.copyWith(userId: 'different');

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
