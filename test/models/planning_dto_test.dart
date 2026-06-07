import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/dto/planning_dto.dart';

void main() {
  group('PlanningDTO', () {
    final sampleJson = {
      'id': 'n1000000-0000-0000-0000-000000000001',
      'project_id': 'p1000000-0000-0000-0000-000000000001',
      'ndt_company_id': 'c1000000-0000-0000-0000-000000000001',
      'ndt_company_task': 'Structural NDT Inspection',
      'testing_status': 'planned',
      'priority': 'normal',
      'projects': {
        'project_name': 'Tuas Mega Port',
        'project_code': 'TMP-001',
      },
      'ndt_companies': {'name': 'Alpha NDT Services'},
    };

    test('fromJson parses planning with joined project and company', () {
      final dto = PlanningDTO.fromJson(sampleJson);
      expect(dto.planning.ndtCompanyTask, 'Structural NDT Inspection');
      expect(dto.projectName, 'Tuas Mega Port');
      expect(dto.projectCode, 'TMP-001');
      expect(dto.companyName, 'Alpha NDT Services');
    });

    test('projectLabel combines project name and code', () {
      final dto = PlanningDTO.fromJson(sampleJson);
      expect(dto.projectLabel, 'Tuas Mega Port (TMP-001)');
    });

    test('projectLabel shows only name when code is null', () {
      final json = {
        ...sampleJson,
        'projects': {'project_name': 'Solo Project'},
      };
      final dto = PlanningDTO.fromJson(json);
      expect(dto.projectLabel, 'Solo Project');
    });

    test('projectLabel shows fallback when project name is null', () {
      final json = {
        ...sampleJson,
        'projects': null,
      };
      final dto = PlanningDTO.fromJson(json);
      expect(dto.projectLabel, 'Unknown Project');
      expect(dto.projectName, isNull);
      expect(dto.projectCode, isNull);
    });

    test('companyLabel returns company name when present', () {
      final dto = PlanningDTO.fromJson(sampleJson);
      expect(dto.companyLabel, 'Alpha NDT Services');
    });

    test('companyLabel returns Unknown Company when null', () {
      final json = {
        ...sampleJson,
        'ndt_companies': null,
      };
      final dto = PlanningDTO.fromJson(json);
      expect(dto.companyLabel, 'Unknown Company');
    });

    test('fromJson handles null joined tables gracefully', () {
      final json = {
        ...sampleJson,
        'projects': null,
        'ndt_companies': null,
      };
      final dto = PlanningDTO.fromJson(json);
      expect(dto.projectName, isNull);
      expect(dto.companyName, isNull);
    });

    test('fromJson preserves planning model integrity', () {
      final dto = PlanningDTO.fromJson(sampleJson);
      expect(dto.planning.id, 'n1000000-0000-0000-0000-000000000001');
      expect(dto.planning.testingStatus, 'planned');
      expect(dto.planning.priority, 'normal');
    });
  });
}
