import 'package:flutter_test/flutter_test.dart';
import 'package:ndt_app/core/services/supabase_client.dart';

void main() {
  group('SupabaseClientWrapper.safeList', () {
    test('returns list of maps for valid response', () {
      final response = [
        {'id': '1', 'name': 'Test'},
        {'id': '2', 'name': 'Test 2'},
      ];
      final result = SupabaseClientWrapper.safeList(response);
      expect(result.length, 2);
      expect(result[0]['name'], 'Test');
    });

    test('returns empty list for null', () {
      final result = SupabaseClientWrapper.safeList(null);
      expect(result, isEmpty);
    });

    test('returns empty list for empty list', () {
      final result = SupabaseClientWrapper.safeList([]);
      expect(result, isEmpty);
    });

    test('filters out non-map items', () {
      final response = [
        {'id': '1'},
        'not a map',
        42,
        {'id': '2'},
      ];
      final result = SupabaseClientWrapper.safeList(response);
      expect(result.length, 2);
      expect(result[0]['id'], '1');
      expect(result[1]['id'], '2');
    });

    test('returns empty list for non-list response', () {
      expect(SupabaseClientWrapper.safeList('string'), isEmpty);
      expect(SupabaseClientWrapper.safeList(42), isEmpty);
      expect(SupabaseClientWrapper.safeList({'key': 'value'}), isEmpty);
    });
  });

  group('SupabaseClientWrapper.safeSingle', () {
    test('returns map for valid single response', () {
      final result = SupabaseClientWrapper.safeSingle(
        {'id': '1', 'name': 'Test'},
      );
      expect(result, isNotNull);
      expect(result!['name'], 'Test');
    });

    test('returns first element for list response', () {
      final result = SupabaseClientWrapper.safeSingle([
        {'id': '1', 'name': 'Test'},
        {'id': '2', 'name': 'Test 2'},
      ]);
      expect(result, isNotNull);
      expect(result!['id'], '1');
    });

    test('returns null for empty list', () {
      final result = SupabaseClientWrapper.safeSingle([]);
      expect(result, isNull);
    });

    test('returns null for null', () {
      final result = SupabaseClientWrapper.safeSingle(null);
      expect(result, isNull);
    });

    test('returns null for non-map/non-list response', () {
      expect(SupabaseClientWrapper.safeSingle('string'), isNull);
      expect(SupabaseClientWrapper.safeSingle(42), isNull);
    });

    test('returns null for list with non-map first element', () {
      final result = SupabaseClientWrapper.safeSingle(['string', 42]);
      expect(result, isNull);
    });
  });

  group('SupabaseClientWrapper table name constants', () {
    test('all table names are defined', () {
      expect(SupabaseClientWrapper.tblCompanies, 'ndt_companies');
      expect(SupabaseClientWrapper.tblUsers, 'users');
      expect(SupabaseClientWrapper.tblContractorRegister,
          'ndt_contractor_register');
      expect(SupabaseClientWrapper.tblProjects, 'projects');
      expect(SupabaseClientWrapper.tblPlanning, 'project_ndt_planning');
      expect(SupabaseClientWrapper.tblDeployments, 'ndt_team_deployments');
      expect(SupabaseClientWrapper.tblAssignments, 'ndt_team_assignments');
      expect(SupabaseClientWrapper.tblAuditLogs, 'audit_logs');
      expect(SupabaseClientWrapper.tblNotifications, 'notifications');
      expect(SupabaseClientWrapper.tblProfessionalRegister,
          'ndt_professional_register');
      expect(SupabaseClientWrapper.tblProfessionalAssignments,
          'ndt_professional_assignments');
    });
  });

  group('SupabaseClientWrapper RPC function names', () {
    test('all RPC function names are defined', () {
      expect(SupabaseClientWrapper.rpcDailyProjectSummary,
          'daily_deployment_summary_by_project');
      expect(SupabaseClientWrapper.rpcDailyCompanySummary,
          'daily_deployment_summary_by_company');
      expect(SupabaseClientWrapper.rpcWeeklyTrend, 'weekly_deployment_trend');
      expect(SupabaseClientWrapper.rpcContractorSummary,
          'contractor_register_summary');
      expect(SupabaseClientWrapper.rpcProjectStatusSummary,
          'project_ndt_status_summary');
      expect(SupabaseClientWrapper.rpcProfessionalSummary,
          'professional_register_summary');
    });
  });
}
