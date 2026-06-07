import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/summary_model.dart';

void main() {
  group('DailyProjectSummary', () {
    final sampleJson = {
      'project_id': 'p1000000-0000-0000-0000-000000000001',
      'project_name': 'Tuas Mega Port',
      'deployment_date': '2026-06-01',
      'day_shift_count': 3,
      'night_shift_count': 1,
      'total_teams': 4,
      'total_personnel': 12,
      'completed_tests': 25,
      'in_progress_tests': 5,
      'rejected_tests': 2,
      'total_test_length': 150.5,
      'total_reject_length': 8.0,
      'locations': ['Tuas Block A', 'Tuas Block B'],
    };

    test('fromJson parses all fields correctly', () {
      final model = DailyProjectSummary.fromJson(sampleJson);

      expect(model.projectId, 'p1000000-0000-0000-0000-000000000001');
      expect(model.projectName, 'Tuas Mega Port');
      expect(model.deploymentDate, DateTime(2026, 6, 1));
      expect(model.dayShiftCount, 3);
      expect(model.nightShiftCount, 1);
      expect(model.totalTeams, 4);
      expect(model.totalPersonnel, 12);
      expect(model.completedTests, 25);
      expect(model.inProgressTests, 5);
      expect(model.rejectedTests, 2);
      expect(model.totalTestLength, 150.5);
      expect(model.totalRejectLength, 8.0);
      expect(model.locations, ['Tuas Block A', 'Tuas Block B']);
    });

    test('totalShiftCount sums day and night shifts', () {
      final model = DailyProjectSummary.fromJson(sampleJson);
      expect(model.totalShiftCount, 4); // 3 + 1
    });

    test('fromJson defaults numeric fields to 0', () {
      final minimalJson = {
        'project_id': 'p-id',
        'project_name': 'Test',
        'deployment_date': '2026-06-01',
      };
      final model = DailyProjectSummary.fromJson(minimalJson);

      expect(model.dayShiftCount, 0);
      expect(model.nightShiftCount, 0);
      expect(model.totalTeams, 0);
      expect(model.totalPersonnel, 0);
      expect(model.completedTests, 0);
      expect(model.inProgressTests, 0);
      expect(model.rejectedTests, 0);
      expect(model.totalTestLength, 0.0);
      expect(model.totalRejectLength, 0.0);
      expect(model.locations, isEmpty);
    });

    test('fromJson handles null locations gracefully', () {
      final json = Map<String, dynamic>.from(sampleJson)..['locations'] = null;
      final model = DailyProjectSummary.fromJson(json);
      expect(model.locations, isEmpty);
    });

    test('toJson round-trip preserves all fields', () {
      final original = DailyProjectSummary.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = DailyProjectSummary.fromJson(json);
      expect(roundTripped, original);
    });

    test('equality works correctly', () {
      final a = DailyProjectSummary.fromJson(sampleJson);
      final b = DailyProjectSummary.fromJson(sampleJson);
      final c = DailyProjectSummary(
        projectId: 'different',
        projectName: 'Diff',
        deploymentDate: DateTime(2026, 6, 1),
      );

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('DailyCompanySummary', () {
    final sampleJson = {
      'company_id': 'c1000000-0000-0000-0000-000000000001',
      'company_name': 'NDT Solutions Pte Ltd',
      'deployment_date': '2026-06-01',
      'total_projects': 3,
      'day_shift_count': 5,
      'night_shift_count': 3,
      'total_teams': 8,
      'total_personnel': 24,
      'completed_tests': 50,
      'in_progress_tests': 10,
      'rejected_tests': 3,
      'not_started_tests': 2,
      'total_test_length': 320.5,
      'total_reject_length': 12.0,
      'avg_reject_rate': 3.75,
    };

    test('fromJson parses all fields correctly', () {
      final model = DailyCompanySummary.fromJson(sampleJson);

      expect(model.companyId, 'c1000000-0000-0000-0000-000000000001');
      expect(model.companyName, 'NDT Solutions Pte Ltd');
      expect(model.deploymentDate, DateTime(2026, 6, 1));
      expect(model.totalProjects, 3);
      expect(model.dayShiftCount, 5);
      expect(model.nightShiftCount, 3);
      expect(model.totalTeams, 8);
      expect(model.totalPersonnel, 24);
      expect(model.completedTests, 50);
      expect(model.inProgressTests, 10);
      expect(model.rejectedTests, 3);
      expect(model.notStartedTests, 2);
      expect(model.totalTestLength, 320.5);
      expect(model.totalRejectLength, 12.0);
      expect(model.avgRejectRate, 3.75);
    });

    test('fromJson defaults numeric fields to 0', () {
      final minimalJson = {
        'company_id': 'c-id',
        'company_name': 'Test Co',
        'deployment_date': '2026-06-01',
      };
      final model = DailyCompanySummary.fromJson(minimalJson);

      expect(model.totalProjects, 0);
      expect(model.dayShiftCount, 0);
      expect(model.nightShiftCount, 0);
      expect(model.totalTeams, 0);
      expect(model.totalPersonnel, 0);
      expect(model.completedTests, 0);
      expect(model.inProgressTests, 0);
      expect(model.rejectedTests, 0);
      expect(model.notStartedTests, 0);
      expect(model.totalTestLength, 0.0);
      expect(model.totalRejectLength, 0.0);
      expect(model.avgRejectRate, 0.0);
    });

    test('toJson round-trip preserves all fields', () {
      final original = DailyCompanySummary.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = DailyCompanySummary.fromJson(json);
      expect(roundTripped, original);
    });

    test('equality works correctly', () {
      final a = DailyCompanySummary.fromJson(sampleJson);
      final b = DailyCompanySummary.fromJson(sampleJson);
      final c = DailyCompanySummary(
        companyId: 'different',
        companyName: 'Diff',
        deploymentDate: DateTime(2026, 6, 1),
      );

      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('WeeklyTrend', () {
    final sampleJson = {
      'trend_date': '2026-06-01',
      'day_shift_count': 15,
      'night_shift_count': 10,
      'completed_tests': 45,
      'total_test_length': 280.0,
      'total_reject_length': 15.5,
    };

    test('fromJson parses all fields correctly', () {
      final model = WeeklyTrend.fromJson(sampleJson);

      expect(model.trendDate, DateTime(2026, 6, 1));
      expect(model.dayShiftCount, 15);
      expect(model.nightShiftCount, 10);
      expect(model.completedTests, 45);
      expect(model.totalTestLength, 280.0);
      expect(model.totalRejectLength, 15.5);
    });

    test('fromJson defaults numeric fields to 0', () {
      final minimalJson = {'trend_date': '2026-06-01'};
      final model = WeeklyTrend.fromJson(minimalJson);

      expect(model.dayShiftCount, 0);
      expect(model.nightShiftCount, 0);
      expect(model.completedTests, 0);
      expect(model.totalTestLength, 0.0);
      expect(model.totalRejectLength, 0.0);
    });

    test('toJson round-trip preserves all fields', () {
      final original = WeeklyTrend.fromJson(sampleJson);
      final json = original.toJson();
      final roundTripped = WeeklyTrend.fromJson(json);
      expect(roundTripped, original);
    });

    test('equality works correctly', () {
      final a = WeeklyTrend.fromJson(sampleJson);
      final b = WeeklyTrend.fromJson(sampleJson);
      final c = WeeklyTrend(trendDate: DateTime(2025, 1, 1));

      expect(a, b);
      expect(a, isNot(c));
    });
  });
}
