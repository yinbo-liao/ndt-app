import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/assignment_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('AssignmentRepository model parsing', () {
    final sampleJson = {
      'id': 'a1000000-0000-0000-0000-000000000001',
      'user_id': 'u1000000-0000-0000-0000-000000000001',
      'project_id': 'p1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'assigned_role': 'supervisor',
      'status': 'active',
      'assigned_from': '2026-02-01',
      'assigned_to': '2026-12-31',
    };

    test('fromJson parses assignment correctly', () {
      final model = AssignmentModel.fromJson(sampleJson);
      expect(model.userId, 'u1000000-0000-0000-0000-000000000001');
      expect(model.projectId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.assignedRole, AssignmentRole.supervisor);
      expect(model.status, AssignmentStatus.active);
      expect(model.assignedFrom, DateTime(2026, 2, 1));
      expect(model.assignedTo, DateTime(2026, 12, 31));
    });

    test('fromJson defaults role to technician when unknown', () {
      final json = {...sampleJson, 'assigned_role': 'unknown'};
      final model = AssignmentModel.fromJson(json);
      expect(model.assignedRole, AssignmentRole.technician);
    });

    test('fromJson defaults status to active when unknown', () {
      final json = {...sampleJson, 'status': 'unknown'};
      final model = AssignmentModel.fromJson(json);
      expect(model.status, AssignmentStatus.active);
    });

    test('roleValue returns correct DB strings', () {
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

    test('statusValue returns correct DB strings', () {
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
    });

    test('safeList parses multiple assignments', () {
      final jsonList = [
        sampleJson,
        {...sampleJson, 'id': 'a2', 'assigned_role': 'technician'},
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => AssignmentModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].assignedRole, AssignmentRole.supervisor);
      expect(models[1].assignedRole, AssignmentRole.technician);
    });
  });
}
