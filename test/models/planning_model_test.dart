import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/planning_model.dart';

void main() {
  group('PlanningModel', () {
    final sampleJson = {
      'id': 'n1000000-0000-0000-0000-000000000001',
      'project_id': 'p1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'ndt_rfi_date': '2026-02-01',
      'ndt_company_task': 'Weld inspection',
      'planned_start_date': '2026-02-15',
      'planned_end_date': '2026-03-15',
      'testing_status': 'completed',
      'test_length': 120.5,
      'reject_length': 2.5,
      'priority': 'high',
      'type_of_testing': 'UT',
      'discipline': 'structure',
      'job_description': 'Inspect all column beam welds',
      'site_contact': 'Mr. Tan 91234567',
      'subcontractor': null,
      'job_location': 'Tuas Block A',
      'team_deploy_status': 'completed',
      'accept_status': 'accept',
      'rfi_sent_to_team': true,
      'created_at': '2026-02-01T08:00:00.000Z',
      'updated_at': '2026-03-15T17:00:00.000Z',
    };

    test('fromJson parses all fields correctly', () {
      final model = PlanningModel.fromJson(sampleJson);

      expect(model.id, 'n1000000-0000-0000-0000-000000000001');
      expect(model.projectId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.ndtRfiDate, DateTime(2026, 2, 1));
      expect(model.ndtCompanyTask, 'Weld inspection');
      expect(model.plannedStartDate, DateTime(2026, 2, 15));
      expect(model.plannedEndDate, DateTime(2026, 3, 15));
      expect(model.testingStatus, 'completed');
      expect(model.testLength, 120.5);
      expect(model.rejectLength, 2.5);
      expect(model.priority, 'high');
      expect(model.typeOfTesting, 'UT');
      expect(model.discipline, 'structure');
      expect(model.jobDescription, 'Inspect all column beam welds');
      expect(model.siteContact, 'Mr. Tan 91234567');
      expect(model.subcontractor, isNull);
      expect(model.jobLocation, 'Tuas Block A');
      expect(model.teamDeployStatus, 'completed');
      expect(model.acceptStatus, 'accept');
      expect(model.rfiSentToTeam, isTrue);
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson handles missing rfi_sent_to_team with default false', () {
      final jsonWithoutRfi = Map<String, dynamic>.from(sampleJson)
        ..remove('rfi_sent_to_team');
      final model = PlanningModel.fromJson(jsonWithoutRfi);
      expect(model.rfiSentToTeam, isFalse);
    });

    test('fromJson handles null rfi_sent_to_team with default false', () {
      final jsonWithNullRfi = Map<String, dynamic>.from(sampleJson)
        ..['rfi_sent_to_team'] = null;
      final model = PlanningModel.fromJson(jsonWithNullRfi);
      expect(model.rfiSentToTeam, isFalse);
    });

    test('toJson includes rfi_sent_to_team', () {
      final model = PlanningModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['rfi_sent_to_team'], true);
    });

    test('toJson includes rfi_sent_to_team even when false', () {
      final model = PlanningModel.fromJson(sampleJson).copyWith(rfiSentToTeam: false);
      final json = model.toJson();
      expect(json['rfi_sent_to_team'], false);
    });

    test('copyWith preserves rfiSentToTeam', () {
      final model = PlanningModel.fromJson(sampleJson);
      final copied = model.copyWith(ndtCompanyTask: 'Changed task');
      expect(copied.rfiSentToTeam, isTrue);
      expect(copied.ndtCompanyTask, 'Changed task');
    });

    test('toJson round-trip preserves all fields', () {
      final original = PlanningModel.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = PlanningModel.fromJson(json);
      expect(roundTripped, original);
    });

    test('props includes rfiSentToTeam', () {
      final model = PlanningModel.fromJson(sampleJson);
      expect(model.props.contains(true), isTrue); // rfiSentToTeam = true
    });

    test('defaults are applied correctly', () {
      final model = PlanningModel(
        id: 'test-id',
        projectId: 'proj-id',
        ndtCompanyId: 'comp-id',
        ndtCompanyTask: 'Task',
      );
      expect(model.testingStatus, 'planned');
      expect(model.priority, 'normal');
      expect(model.teamDeployStatus, 'not_deployed');
      expect(model.acceptStatus, 'pending');
      expect(model.rfiSentToTeam, false);
      expect(model.testLength, 0.0);
      expect(model.rejectLength, 0.0);
    });
  });
}
