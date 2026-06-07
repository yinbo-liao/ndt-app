import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/project_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('ProjectRepository model parsing', () {
    final sampleJson = {
      'id': 'p1000000-0000-0000-0000-000000000001',
      'project_name': 'Tuas Mega Port Construction',
      'project_code': 'TMP-2026-01',
      'job_trade': 'Structural Steel',
      'location': 'Tuas, Singapore',
      'client_name': 'Port Authority',
      'classification': 'ABS',
      'start_date': '2026-02-01',
      'end_date': '2026-12-31',
      'active': true,
    };

    test('fromJson parses project correctly', () {
      final model = ProjectModel.fromJson(sampleJson);
      expect(model.projectName, 'Tuas Mega Port Construction');
      expect(model.projectCode, 'TMP-2026-01');
      expect(model.location, 'Tuas, Singapore');
      expect(model.classification, 'ABS');
      expect(model.startDate, DateTime(2026, 2, 1));
      expect(model.endDate, DateTime(2026, 12, 31));
      expect(model.active, isTrue);
    });

    test('fromJson handles project without dates', () {
      final minimalJson = {
        'id': 'p-id',
        'project_name': 'Min Project',
        'project_code': 'MIN-001',
        'location': 'Somewhere',
      };
      final model = ProjectModel.fromJson(minimalJson);
      expect(model.startDate, isNull);
      expect(model.endDate, isNull);
      expect(model.classification, isNull);
      expect(model.active, isTrue);
    });

    test('safeList parses multiple projects', () {
      final jsonList = [
        sampleJson,
        {...sampleJson, 'id': 'p2', 'project_name': 'Project 2'},
      ];
      final safeList = SupabaseClientWrapper.safeList(jsonList);
      final models =
          safeList.map((json) => ProjectModel.fromJson(json)).toList();
      expect(models.length, 2);
      expect(models[0].projectCode, 'TMP-2026-01');
      expect(models[1].projectName, 'Project 2');
    });

    test('toJson serializes dates as yyyy-MM-dd', () {
      final model = ProjectModel.fromJson(sampleJson);
      final json = model.toJson();
      expect(json['start_date'], '2026-02-01');
      expect(json['end_date'], '2026-12-31');
    });
  });
}
