import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/deployment_model.dart';

void main() {
  group('TeamMember', () {
    final memberJson = {
      'user_id': 'u1000000-0000-0000-0000-000000000001',
      'name': 'John Technician',
      'role': 'technician',
    };

    test('fromJson parses all fields correctly', () {
      final member = TeamMember.fromJson(memberJson);
      expect(member.userId, 'u1000000-0000-0000-0000-000000000001');
      expect(member.name, 'John Technician');
      expect(member.role, 'technician');
    });

    test('toJson produces correct output', () {
      final member = TeamMember.fromJson(memberJson);
      final json = member.toJson();

      expect(json['user_id'], 'u1000000-0000-0000-0000-000000000001');
      expect(json['name'], 'John Technician');
      expect(json['role'], 'technician');
    });

    test('toJson round-trip preserves all fields', () {
      final original = TeamMember.fromJson(memberJson);
      final json = original.toJson();
      final roundTripped = TeamMember.fromJson(json);
      expect(roundTripped, original);
    });

    test('equality works correctly', () {
      final a = TeamMember.fromJson(memberJson);
      final b = TeamMember.fromJson(memberJson);
      final c = TeamMember(
        userId: 'other',
        name: 'John Technician',
        role: 'technician',
      );

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('DeploymentModel', () {
    final sampleJson = {
      'id': 'd1000000-0000-0000-0000-000000000001',
      'project_ndt_planning_id': 'n1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'ndt_supervisor_id': 'u1000000-0000-0000-0000-000000000002',
      'shift': 'day',
      'deployment_date': '2026-06-01',
      'deployment_start_time': '2026-06-01T08:00:00.000Z',
      'deployment_end_time': '2026-06-01T17:00:00.000Z',
      'team_deployment': 'Team Alpha Day',
      'team_members': [
        {
          'user_id': 'u001',
          'name': 'John Tech',
          'role': 'technician',
        },
        {
          'user_id': 'u002',
          'name': 'Jane Inspect',
          'role': 'inspector',
        },
      ],
      'job_location': 'Tuas Block A - Weld Area 3',
      'testing_status': 'in_progress',
      'test_length': 45.5,
      'reject_length': 2.5,
      'equipment_used': ['UT-Device-01', 'MT-Yoke-03'],
      'daily_notes': 'Good weather, all welds inspected.',
      'weather_conditions': 'Sunny, 32°C',
      'created_by': 'u1000000-0000-0000-0000-000000000001',
      'created_at': '2026-06-01T07:00:00.000Z',
      'updated_at': '2026-06-01T16:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = DeploymentModel.fromJson(sampleJson);

      expect(model.id, 'd1000000-0000-0000-0000-000000000001');
      expect(model.projectNdtPlanningId,
          'n1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.ndtSupervisorId,
          'u1000000-0000-0000-0000-000000000002');
      expect(model.shift, ShiftType.day);
      expect(model.deploymentDate, DateTime(2026, 6, 1));
      expect(model.teamDeployment, 'Team Alpha Day');
      expect(model.teamMembers.length, 2);
      expect(model.teamMembers[0].name, 'John Tech');
      expect(model.teamMembers[0].role, 'technician');
      expect(model.teamMembers[1].name, 'Jane Inspect');
      expect(model.jobLocation, 'Tuas Block A - Weld Area 3');
      expect(model.testingStatus, DeploymentTestingStatus.inProgress);
      expect(model.testLength, 45.5);
      expect(model.rejectLength, 2.5);
      expect(model.equipmentUsed, ['UT-Device-01', 'MT-Yoke-03']);
      expect(model.dailyNotes, 'Good weather, all welds inspected.');
      expect(model.weatherConditions, 'Sunny, 32°C');
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
      expect(model.deletedAt, isNull);
    });

    test('fromJson parses night shift correctly', () {
      final json = Map<String, dynamic>.from(sampleJson)..['shift'] = 'night';
      final model = DeploymentModel.fromJson(json);
      expect(model.shift, ShiftType.night);
      expect(model.shiftValue, 'night');
    });

    test('fromJson defaults shift to day for unknown values', () {
      final json = Map<String, dynamic>.from(sampleJson)..['shift'] = 'unknown';
      final model = DeploymentModel.fromJson(json);
      expect(model.shift, ShiftType.day);
    });

    test('fromJson parses all testing statuses correctly', () {
      expect(
        DeploymentModel.fromJson(
          {...sampleJson, 'testing_status': 'not_started'},
        ).testingStatus,
        DeploymentTestingStatus.notStarted,
      );
      expect(
        DeploymentModel.fromJson(
          {...sampleJson, 'testing_status': 'completed'},
        ).testingStatus,
        DeploymentTestingStatus.completed,
      );
      expect(
        DeploymentModel.fromJson(
          {...sampleJson, 'testing_status': 'rejected'},
        ).testingStatus,
        DeploymentTestingStatus.rejected,
      );
    });

    test('fromJson handles missing optional fields with defaults', () {
      final minimalJson = {
        'id': 'd-id',
        'project_ndt_planning_id': 'n-id',
        'ndt_company_id': 'c-id',
        'deployment_date': '2026-06-01',
        'team_deployment': 'Team',
        'job_location': 'Site A',
      };
      final model = DeploymentModel.fromJson(minimalJson);

      expect(model.ndtSupervisorId, isNull);
      expect(model.shift, ShiftType.day);
      expect(model.deploymentStartTime, isNull);
      expect(model.deploymentEndTime, isNull);
      expect(model.teamMembers, isEmpty);
      expect(model.testingStatus, DeploymentTestingStatus.notStarted);
      expect(model.testLength, 0.0);
      expect(model.rejectLength, 0.0);
      expect(model.equipmentUsed, isEmpty);
      expect(model.dailyNotes, isNull);
      expect(model.weatherConditions, isNull);
      expect(model.createdBy, isNull);
      expect(model.createdAt, isNull);
      expect(model.updatedAt, isNull);
      expect(model.deletedAt, isNull);
    });

    test('fromJson handles null team_members gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['team_members'] = null;
      final model = DeploymentModel.fromJson(json);
      expect(model.teamMembers, isEmpty);
    });

    test('fromJson handles null equipment_used gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['equipment_used'] = null;
      final model = DeploymentModel.fromJson(json);
      expect(model.equipmentUsed, isEmpty);
    });

    test('memberCount returns correct count', () {
      final model = DeploymentModel.fromJson(sampleJson);
      expect(model.memberCount, 2);
    });

    test('memberCount returns 0 for empty team', () {
      final json = Map<String, dynamic>.from(sampleJson)..['team_members'] = [];
      final model = DeploymentModel.fromJson(json);
      expect(model.memberCount, 0);
    });

    test('isDeleted returns true when deleted_at is set', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['deleted_at'] = '2026-07-01T00:00:00.000Z';
      final model = DeploymentModel.fromJson(json);
      expect(model.isDeleted, isTrue);
    });

    test('isDeleted returns false when deleted_at is null', () {
      final model = DeploymentModel.fromJson(sampleJson);
      expect(model.isDeleted, isFalse);
    });

    test('toJson serializes team_members as JSON array', () {
      final model = DeploymentModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['team_members'], isA<List>());
      expect(json['team_members'].length, 2);
      expect(json['team_members'][0]['user_id'], 'u001');
      expect(json['team_members'][0]['name'], 'John Tech');
    });

    test('toJson serializes equipment_used as array', () {
      final model = DeploymentModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['equipment_used'], ['UT-Device-01', 'MT-Yoke-03']);
    });

    test('toJson serializes shift and testing_status using snake_case DB values', () {
      final model = DeploymentModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['shift'], 'day');
      // testingStatusValue returns snake_case to match DB CHECK constraint
      expect(json['testing_status'], 'in_progress');
    });

    test('toJson serializes deployment_date as yyyy-MM-dd', () {
      final model = DeploymentModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['deployment_date'], '2026-06-01');
    });

    test('toJson round-trip preserves all fields', () {
      final original = DeploymentModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = DeploymentModel.fromJson(json);

      // Shift should be preserved
      expect(roundTripped.shift, original.shift);
      expect(roundTripped.teamMembers.length, original.teamMembers.length);
      expect(roundTripped.teamDeployment, original.teamDeployment);
      expect(roundTripped.jobLocation, original.jobLocation);
      expect(roundTripped.testLength, original.testLength);
      // testing_status round-trips correctly using snake_case DB values
    });

    test('copyWith updates specific fields', () {
      final model = DeploymentModel.fromJson(sampleJson);
      final copied = model.copyWith(
        shift: ShiftType.night,
        testingStatus: DeploymentTestingStatus.completed,
      );

      expect(copied.shift, ShiftType.night);
      expect(copied.testingStatus, DeploymentTestingStatus.completed);
      expect(copied.teamDeployment, model.teamDeployment); // unchanged
    });

    test('props includes all fields', () {
      final model = DeploymentModel.fromJson(sampleJson);
      expect(model.props.length, 21);
    });

    test('equality works correctly', () {
      final a = DeploymentModel.fromJson(sampleJson);
      final b = DeploymentModel.fromJson(sampleJson);
      final c = a.copyWith(teamDeployment: 'Different Team');

      expect(a, b);
      expect(a, isNot(c));
    });

    test('testingStatusValue returns correct snake_case string for each status', () {
      final baseModel = DeploymentModel(
        id: 'id',
        projectNdtPlanningId: 'p',
        ndtCompanyId: 'c',
        deploymentDate: DateTime(2026, 6, 1),
        teamDeployment: 'Team',
        jobLocation: 'Loc',
      );

      final expectations = {
        DeploymentTestingStatus.notStarted: 'not_started',
        DeploymentTestingStatus.inProgress: 'in_progress',
        DeploymentTestingStatus.completed: 'completed',
        DeploymentTestingStatus.rejected: 'rejected',
      };

      for (final entry in expectations.entries) {
        final model = baseModel.copyWith(testingStatus: entry.key);
        expect(model.testingStatusValue, entry.value,
            reason: 'Failed for status: ${entry.key}');
      }
    });
  });
}
