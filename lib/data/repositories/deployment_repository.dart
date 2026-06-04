import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deployment_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for NDT Team Deployment CRUD operations.
///
/// Supports shift filtering, date range queries, status updates,
/// and soft delete with the `deleted_at` column.
class DeploymentRepository {
  final SupabaseClient _client;

  DeploymentRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<DeploymentModel> create(DeploymentModel deployment) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblDeployments)
        .insert(deployment.toJson())
        .select()
        .single();

    return DeploymentModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  /// Get deployments within a date range, with optional filters.
  Future<List<DeploymentModel>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
    String? projectId,
    ShiftType? shift,
  }) async {
    var query = _client
        .from(SupabaseClientWrapper.tblDeployments)
        .select(
          '*, '
          'project_ndt_planning!inner('
          '  id, ndt_company_task, '
          '  projects:project_id(project_name, project_code)'
          '), '
          'ndt_companies:ndt_company_id(name)',
        )
        .gte('deployment_date', startDate.toIso8601String().split('T')[0])
        .lte('deployment_date', endDate.toIso8601String().split('T')[0]);

    if (companyId != null) {
      query = query.eq('ndt_company_id', companyId);
    }

    if (shift != null) {
      query = query.eq('shift', shift == ShiftType.day ? 'day' : 'night');
    }

    // Apply null filter and ordering (returns PostgrestTransformBuilder)
    final response = await query
        .filter('deleted_at', 'is', null)
        .order('deployment_date', ascending: false)
        .order('shift');

    final rawList = SupabaseClientWrapper.safeList(response);

    // Filter by project client-side — the project reference is nested inside
    // the `project_ndt_planning` join and PostgREST cannot filter across
    // nested foreign-table joins in a single query.
    if (projectId != null) {
      return rawList
          .where((json) {
            final planning =
                json['project_ndt_planning'] as Map<String, dynamic>?;
            return planning?['project_id'] == projectId;
          })
          .map((json) => DeploymentModel.fromJson(json))
          .toList();
    }
    return rawList
        .map((json) => DeploymentModel.fromJson(json))
        .toList();
  }

  /// Get today's deployments for a company.
  Future<List<DeploymentModel>> getTodayDeployments({
    String? companyId,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getByDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
      companyId: companyId,
    );
  }

  /// Get deployments for a specific planning entry.
  Future<List<DeploymentModel>> getByPlanningId(String planningId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblDeployments)
        .select()
        .eq('project_ndt_planning_id', planningId)
        .isFilter('deleted_at', null)
        .order('deployment_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => DeploymentModel.fromJson(json))
        .toList();
  }

  /// Get a single deployment by ID.
  Future<DeploymentModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblDeployments)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return DeploymentModel.fromJson(data);
  }

  // ── Update ─────────────────────────────────────────────────

  Future<DeploymentModel> update(DeploymentModel deployment) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblDeployments)
        .update(deployment.toJson())
        .eq('id', deployment.id)
        .select()
        .single();

    return DeploymentModel.fromJson(response);
  }

  /// Update the testing status of a deployment.
  Future<void> updateStatus({
    required String deploymentId,
    required DeploymentTestingStatus status,
    double? testLength,
    double? rejectLength,
  }) async {
    final updates = <String, dynamic>{
      'testing_status': status.name,
    };

    if (testLength != null) updates['test_length'] = testLength;
    if (rejectLength != null) updates['reject_length'] = rejectLength;

    await _client
        .from(SupabaseClientWrapper.tblDeployments)
        .update(updates)
        .eq('id', deploymentId);
  }

  // ── Soft Delete ───────────────────────────────────────────

  Future<void> softDelete(String deploymentId) async {
    await _client
        .from(SupabaseClientWrapper.tblDeployments)
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', deploymentId);
  }

  // ── Real-time Subscription ────────────────────────────────

  /// Stream real-time changes to the deployments table.
  ///
  /// Filters out soft-deleted records client-side. Optionally scoped to a
  /// specific company. The stream emits the full list of matching
  /// deployments on each change event.
  Stream<List<DeploymentModel>> subscribe({
    String? companyId,
  }) {
    final query = _client
        .from(SupabaseClientWrapper.tblDeployments)
        .stream(primaryKey: ['id']);

    final filtered = companyId != null
        ? query.eq('ndt_company_id', companyId)
        : query;

    return filtered.map((data) {
      final list = data as List;
      return list
          .map((json) =>
              DeploymentModel.fromJson(json as Map<String, dynamic>))
          .where((d) => d.deletedAt == null) // filter out soft-deleted
          .toList();
    });
  }
}
