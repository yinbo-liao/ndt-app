import 'package:supabase_flutter/supabase_flutter.dart';

/// Typed wrapper around Supabase.instance.client.
///
/// Provides convenient accessors for common database operations
/// and ensures consistent table name references.
class SupabaseClientWrapper {
  SupabaseClientWrapper._();

  static SupabaseClient get instance => Supabase.instance.client;

  // ── Table Name Constants ──────────────────────────────────

  static const String tblCompanies = 'ndt_companies';
  static const String tblUsers = 'users';
  static const String tblContractorRegister = 'ndt_contractor_register';
  static const String tblProjects = 'projects';
  static const String tblPlanning = 'project_ndt_planning';
  static const String tblDeployments = 'ndt_team_deployments';
  static const String tblAssignments = 'ndt_team_assignments';
  static const String tblAuditLogs = 'audit_logs';
  static const String tblNotifications = 'notifications';
  static const String tblProfessionalRegister = 'ndt_professional_register';

  // ── RPC Function Name Constants ───────────────────────────

  static const String rpcDailyProjectSummary =
      'daily_deployment_summary_by_project';
  static const String rpcDailyCompanySummary =
      'daily_deployment_summary_by_company';
  static const String rpcWeeklyTrend = 'weekly_deployment_trend';
  static const String rpcContractorSummary = 'contractor_register_summary';
  static const String rpcProjectStatusSummary = 'project_ndt_status_summary';
  static const String rpcProfessionalSummary = 'professional_register_summary';

  // ── Convenience Methods ───────────────────────────────────

  /// Returns the current authenticated user's ID, or null.
  static String? get currentUserId =>
      instance.auth.currentUser?.id;

  /// Returns true if a user is currently signed in.
  static bool get isAuthenticated =>
      instance.auth.currentSession != null;

  /// Returns the current session, or null.
  static Session? get currentSession =>
      instance.auth.currentSession;

  /// Build a Supabase query builder for the given table.
  static SupabaseQueryBuilder from(String table) =>
      instance.from(table);

  // ── Safe Type Helpers ───────────────────────────────────────

  /// Safely cast a Supabase response to a list of maps.
  ///
  /// Returns an empty list if the response is not a [List], preventing
  /// runtime type-cast crashes when Supabase returns unexpected shapes.
  static List<Map<String, dynamic>> safeList(dynamic response) {
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return [];
  }

  /// Safely cast a Supabase single-row response to a map.
  ///
  /// Returns null if the response is not a [Map], preventing runtime
  /// type-cast crashes when Supabase returns unexpected shapes.
  static Map<String, dynamic>? safeSingle(dynamic response) {
    if (response is Map<String, dynamic>) return response;
    if (response is List && response.isNotEmpty && response.first is Map<String, dynamic>) {
      return response.first as Map<String, dynamic>;
    }
    return null;
  }
}
