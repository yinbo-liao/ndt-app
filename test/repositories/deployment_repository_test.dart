import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/deployment_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('DeploymentRepository model parsing', () {
    final sampleJson = {
      'id': 'd1000000-0000-0000-0000-000000000001',
      'project_ndt_planning_id': 'n1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'shift': 'day',
      'deployment_date': '2026-06-01',
      'team_deployment': 'Team Alpha',
      'team_members': [
        {'user_id': 'u001', 'name': 'John', 'role': 'technician'},
      ],
      'job_location': 'Tuas Block A',
      'testing_status': 'in_progress',
      'test_length': 45.5,
      'reject_length': 2.5,
      'equipment_used': ['UT-Device-01'],
    };

    test('fromJson parses deployment with team members', () {
      final model = DeploymentModel.fromJson(sampleJson);
      expect(model.teamDeployment, 'Team Alpha');
      expect(model.shift, ShiftType.day);
      expect(model.teamMembers.length, 1);
      expect(model.teamMembers[0].name, 'John');
      expect(model.teamMembers[0].role, 'technician');
      expect(model.testLength, 45.5);
      expect(model.rejectLength, 2.5);
      expect(model.equipmentUsed, ['UT-Device-01']);
      expect(model.testingStatus, DeploymentTestingStatus.inProgress);
    });

    test('parse night shift correctly', () {
      final json = {...sampleJson, 'shift': 'night'};
      final model = DeploymentModel.fromJson(json);
      expect(model.shift, ShiftType.night);
      expect(model.shiftValue, 'night');
    });

    test('parse all testing statuses', () {
      final statusMap = {
        'not_started': DeploymentTestingStatus.notStarted,
        'completed': DeploymentTestingStatus.completed,
        'rejected': DeploymentTestingStatus.rejected,
      };

      statusMap.forEach((dbValue, expected) {
        final json = {...sampleJson, 'testing_status': dbValue};
        final model = DeploymentModel.fromJson(json);
        expect(model.testingStatus, expected,
            reason: 'Failed for status: $dbValue');
      });
    });

    test('handle null team_members gracefully', () {
      final json = {...sampleJson, 'team_members': null};
      final model = DeploymentModel.fromJson(json);
      expect(model.teamMembers, isEmpty);
      expect(model.memberCount, 0);
    });

    test('handle null equipment_used gracefully', () {
      final json = {...sampleJson, 'equipment_used': null};
      final model = DeploymentModel.fromJson(json);
      expect(model.equipmentUsed, isEmpty);
    });

    test('memberCount returns correct count', () {
      final json = {
        ...sampleJson,
        'team_members': [
          {'user_id': 'u1', 'name': 'A', 'role': 't'},
          {'user_id': 'u2', 'name': 'B', 'role': 'i'},
          {'user_id': 'u3', 'name': 'C', 'role': 's'},
        ],
      };
      final model = DeploymentModel.fromJson(json);
      expect(model.memberCount, 3);
    });

    test('isDeleted returns correct value based on deletedAt', () {
      final active = DeploymentModel.fromJson(sampleJson);
      expect(active.isDeleted, isFalse);

      final deleted = DeploymentModel.fromJson({
        ...sampleJson,
        'deleted_at': '2026-07-01T00:00:00.000Z',
      });
      expect(deleted.isDeleted, isTrue);
    });

    test('safeList parses multiple deployments', () {
      final jsonList = [
        sampleJson,
        {...sampleJson, 'id': 'd2', 'shift': 'night'},
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => DeploymentModel.fromJson(json)).toList();

      expect(models.length, 2);
      expect(models[0].shift, ShiftType.day);
      expect(models[1].shift, ShiftType.night);
    });

    test('toJson includes team_members as JSON array', () {
      final model = DeploymentModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['team_members'], isA<List>());
      expect(json['team_members'][0]['user_id'], 'u001');
    });
  });
}
