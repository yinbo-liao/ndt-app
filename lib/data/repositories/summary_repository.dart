import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/summary_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for summary RPC function calls.
///
/// Calls the 5 PostgreSQL functions defined in the Supabase database.
/// Errors are propagated (not swallowed) so the UI can show error states.
class SummaryRepository {
  final SupabaseClient _client;

  SummaryRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Daily Deployment Summary per Project ──────────────────

  Future<DailyProjectSummary?> getDailyProjectSummary({
    required String projectId,
    required DateTime date,
  }) async {
    final response = await _client.rpc(
      SupabaseClientWrapper.rpcDailyProjectSummary,
      params: {
        'p_project_id': projectId,
        'p_date': date.toIso8601String().split('T')[0],
      },
    );

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return DailyProjectSummary.fromJson(data);
  }

  // ── Daily Deployment Summary per Company ──────────────────

  Future<DailyCompanySummary?> getDailyCompanySummary({
    required String companyId,
    required DateTime date,
  }) async {
    final response = await _client.rpc(
      SupabaseClientWrapper.rpcDailyCompanySummary,
      params: {
        'p_company_id': companyId,
        'p_date': date.toIso8601String().split('T')[0],
      },
    );

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return DailyCompanySummary.fromJson(data);
  }

  // ── Weekly Deployment Trend ───────────────────────────────

  Future<List<WeeklyTrend>> getWeeklyTrend({
    required String projectId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _client.rpc(
      SupabaseClientWrapper.rpcWeeklyTrend,
      params: {
        'p_project_id': projectId,
        'p_start_date': startDate.toIso8601String().split('T')[0],
        'p_end_date': endDate.toIso8601String().split('T')[0],
      },
    );

    return SupabaseClientWrapper.safeList(response)
        .map((json) => WeeklyTrend.fromJson(json))
        .toList();
  }

  // ── Contractor Register Summary ───────────────────────────

  Future<Map<String, dynamic>?> getContractorSummary({
    required String companyId,
    required DateTime monthStart,
  }) async {
    final response = await _client.rpc(
      SupabaseClientWrapper.rpcContractorSummary,
      params: {
        'p_company_id': companyId,
        'p_month_start': monthStart.toIso8601String().split('T')[0],
      },
    );

    return SupabaseClientWrapper.safeSingle(response);
  }

  // ── Professional Register Summary ──────────────────────────

  Future<Map<String, dynamic>?> getProfessionalSummary({
    required String companyId,
  }) async {
    final response = await _client.rpc(
      SupabaseClientWrapper.rpcProfessionalSummary,
      params: {'p_company_id': companyId},
    );

    return SupabaseClientWrapper.safeSingle(response);
  }

  // ── Project NDT Status Summary ────────────────────────────

  Future<List<Map<String, dynamic>>> getProjectStatusSummary({
    required String companyId,
  }) async {
    final response = await _client.rpc(
      SupabaseClientWrapper.rpcProjectStatusSummary,
      params: {'p_company_id': companyId},
    );

    return SupabaseClientWrapper.safeList(response);
  }
}
