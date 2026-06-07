import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/planning_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('PlanningRepository model parsing', () {
    final sampleJson = {
      'id': 'n1000000-0000-0000-0000-000000000001',
      'project_id': 'p1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'ndt_rfi_date': '2026-02-01',
      'ndt_company_task': 'Weld inspection',
      'planned_start_date': '2026-02-15',
      'planned_end_date': '2026-03-15',
      'testing_status': 'in_progress',
      'test_length': 120.5,
      'reject_length': 2.5,
      'priority': 'high',
      'type_of_testing': 'UT',
      'discipline': 'structure',
      'team_deploy_status': 'deployed',
      'accept_status': 'pending',
      'rfi_sent_to_team': false,
    };

    test('fromJson parses planning entry correctly', () {
      final model = PlanningModel.fromJson(sampleJson);
      expect(model.projectId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.ndtCompanyTask, 'Weld inspection');
      expect(model.testingStatus, 'in_progress');
      expect(model.priority, 'high');
      expect(model.typeOfTesting, 'UT');
      expect(model.discipline, 'structure');
      expect(model.teamDeployStatus, 'deployed');
      expect(model.acceptStatus, 'pending');
      expect(model.rfiSentToTeam, isFalse);
      expect(model.testLength, 120.5);
      expect(model.rejectLength, 2.5);
    });

    test('fromJson applies correct defaults', () {
      final minimalJson = {
        'id': 'n-id',
        'project_id': 'p-id',
        'ndt_company_id': 'c-id',
        'ndt_company_task': 'Task',
      };
      final model = PlanningModel.fromJson(minimalJson);
      expect(model.testingStatus, 'planned');
      expect(model.priority, 'normal');
      expect(model.teamDeployStatus, 'not_deployed');
      expect(model.acceptStatus, 'pending');
      expect(model.rfiSentToTeam, isFalse);
      expect(model.testLength, 0.0);
      expect(model.rejectLength, 0.0);
    });

    test('rfiSentToTeam defaults to false when null', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['rfi_sent_to_team'] = null;
      final model = PlanningModel.fromJson(json);
      expect(model.rfiSentToTeam, isFalse);
    });

    test('safeList parses multiple planning entries', () {
      final jsonList = [
        sampleJson,
        {...sampleJson, 'id': 'n2', 'priority': 'urgent'},
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => PlanningModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].priority, 'high');
      expect(models[1].priority, 'urgent');
    });

    test('toJson round-trip preserves rfiSentToTeam', () {
      final original = PlanningModel.fromJson(sampleJson);
      final json = original.toJson();
      expect(json['rfi_sent_to_team'], isFalse);
      final roundTripped = PlanningModel.fromJson(json);
      expect(roundTripped.rfiSentToTeam, isFalse);
    });
  });
}
