import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/data/models/summary_model.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('SummaryRepository RPC result parsing', () {
    group('DailyProjectSummary', () {
      final sampleJson = {
        'project_id': 'p1000000-0000-0000-0000-000000000001',
        'project_name': 'Tuas Mega Port',
        'deployment_date': '2026-06-01',
        'day_shift_count': 3,
        'night_shift_count': 2,
        'total_teams': 5,
        'total_personnel': 12,
        'completed_tests': 8,
        'in_progress_tests': 3,
        'rejected_tests': 1,
        'total_test_length': 125.5,
        'total_reject_length': 12.3,
        'locations': ['Block A', 'Block B', 'Block C'],
      };

      test('fromJson parses daily project summary correctly', () {
        final model = DailyProjectSummary.fromJson(sampleJson);
        expect(model.projectId, 'p1000000-0000-0000-0000-000000000001');
        expect(model.projectName, 'Tuas Mega Port');
        expect(model.deploymentDate, DateTime(2026, 6, 1));
        expect(model.dayShiftCount, 3);
        expect(model.nightShiftCount, 2);
        expect(model.totalTeams, 5);
        expect(model.totalPersonnel, 12);
        expect(model.completedTests, 8);
        expect(model.inProgressTests, 3);
        expect(model.rejectedTests, 1);
        expect(model.totalTestLength, 125.5);
        expect(model.totalRejectLength, 12.3);
        expect(model.locations, ['Block A', 'Block B', 'Block C']);
      });

      test('totalShiftCount sums day and night', () {
        final model = DailyProjectSummary.fromJson(sampleJson);
        expect(model.totalShiftCount, 5); // 3 + 2
      });

      test('fromJson handles null numeric fields', () {
        final json = {
          'project_id': 'p1',
          'project_name': 'Test',
          'deployment_date': '2026-06-01',
        };
        final model = DailyProjectSummary.fromJson(json);
        expect(model.dayShiftCount, 0);
        expect(model.completedTests, 0);
        expect(model.totalTestLength, 0.0);
        expect(model.locations, isEmpty);
      });
    });

    group('DailyCompanySummary', () {
      final sampleJson = {
        'company_id': 'c1000000-0000-0000-0000-000000000001',
        'company_name': 'Alpha NDT Services',
        'deployment_date': '2026-06-01',
        'total_projects': 4,
        'day_shift_count': 5,
        'night_shift_count': 3,
        'total_teams': 8,
        'total_personnel': 20,
        'completed_tests': 15,
        'in_progress_tests': 4,
        'rejected_tests': 2,
        'not_started_tests': 1,
        'total_test_length': 250.0,
        'total_reject_length': 25.0,
        'avg_reject_rate': 10.0,
      };

      test('fromJson parses daily company summary correctly', () {
        final model = DailyCompanySummary.fromJson(sampleJson);
        expect(model.companyId, 'c1000000-0000-0000-0000-000000000001');
        expect(model.companyName, 'Alpha NDT Services');
        expect(model.deploymentDate, DateTime(2026, 6, 1));
        expect(model.totalProjects, 4);
        expect(model.completedTests, 15);
        expect(model.avgRejectRate, 10.0);
      });

      test('fromJson handles null values with defaults', () {
        final json = {
          'company_id': 'c1',
          'company_name': 'Test',
          'deployment_date': '2026-06-01',
        };
        final model = DailyCompanySummary.fromJson(json);
        expect(model.totalProjects, 0);
        expect(model.avgRejectRate, 0.0);
        expect(model.notStartedTests, 0);
      });
    });

    group('WeeklyTrend', () {
      final sampleJson = {
        'trend_date': '2026-06-01',
        'day_shift_count': 2,
        'night_shift_count': 1,
        'completed_tests': 5,
        'total_test_length': 45.0,
        'total_reject_length': 3.5,
      };

      test('fromJson parses weekly trend correctly', () {
        final model = WeeklyTrend.fromJson(sampleJson);
        expect(model.trendDate, DateTime(2026, 6, 1));
        expect(model.dayShiftCount, 2);
        expect(model.nightShiftCount, 1);
        expect(model.completedTests, 5);
        expect(model.totalTestLength, 45.0);
        expect(model.totalRejectLength, 3.5);
      });

      test('safeList parses multiple trend points', () {
        final jsonList = [
          sampleJson,
          {...sampleJson, 'trend_date': '2026-06-02', 'day_shift_count': 3},
        ];
        final safeList = SupabaseClientWrapper.safeList(jsonList);
        final models =
            safeList.map((json) => WeeklyTrend.fromJson(json)).toList();
        expect(models.length, 2);
        expect(models[0].trendDate, DateTime(2026, 6, 1));
        expect(models[1].trendDate, DateTime(2026, 6, 2));
      });
    });
  });
}
