import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/assignment_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for Team-to-Project assignment CRUD operations.
///
/// This is the backbone of the `team_view_assigned_projects` RLS policy.
/// Without assignments data, `ndt_team` users see zero projects/planning.
class AssignmentRepository {
  final SupabaseClient _client;

  AssignmentRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<AssignmentModel> create(AssignmentModel assignment) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .insert(assignment.toJson())
        .select()
        .single();

    return AssignmentModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  /// Get all assignments for a specific company.
  Future<List<AssignmentModel>> getByCompany(String companyId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .select('*, users!user_id(full_name, email)')
        .eq('ndt_company_id', companyId)
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => AssignmentModel.fromJson(json))
        .toList();
  }

  /// Get all assignments for a specific user.
  Future<List<AssignmentModel>> getByUser(String userId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .select('*, projects!project_id(project_name, project_code)')
        .eq('user_id', userId)
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => AssignmentModel.fromJson(json))
        .toList();
  }

  /// Get all assignments for a specific project.
  Future<List<AssignmentModel>> getByProject(String projectId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .select('*, users!user_id(full_name, email)')
        .eq('project_id', projectId)
        .order('created_at', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => AssignmentModel.fromJson(json))
        .toList();
  }

  /// Get a single assignment by ID.
  Future<AssignmentModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .select()
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return AssignmentModel.fromJson(data);
  }

  // ── Update ─────────────────────────────────────────────────

  Future<AssignmentModel> update(AssignmentModel assignment) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .update(assignment.toJson())
        .eq('id', assignment.id)
        .select()
        .single();

    return AssignmentModel.fromJson(response);
  }

  /// Update the status of an assignment.
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .update({'status': status})
        .eq('id', id);
  }

  // ── Delete ─────────────────────────────────────────────────

  /// Hard-delete an assignment (this table has no soft delete).
  Future<void> remove(String id) async {
    await _client
        .from(SupabaseClientWrapper.tblAssignments)
        .delete()
        .eq('id', id);
  }
}
