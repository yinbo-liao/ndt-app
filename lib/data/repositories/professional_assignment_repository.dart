import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professional_assignment_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for Professional-to-RFI assignment CRUD operations.
///
/// Links NDT professionals to specific planning/RFI entries.
class ProfessionalAssignmentRepository {
  final SupabaseClient _client;

  ProfessionalAssignmentRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<ProfessionalAssignmentModel> create(
      ProfessionalAssignmentModel assignment) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .insert(assignment.toJson())
        .select()
        .single();

    return ProfessionalAssignmentModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  /// Get all assignments for a specific planning/RFI entry.
  Future<List<ProfessionalAssignmentModel>> getByPlanning(
      String planningId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .select()
        .eq('planning_id', planningId)
        .order('assigned_at', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) =>
            ProfessionalAssignmentModel.fromJson(json))
        .toList();
  }

  /// Get all assignments for a specific professional.
  Future<List<ProfessionalAssignmentModel>> getByProfessional(
      String professionalId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .select()
        .eq('professional_id', professionalId)
        .order('assigned_at', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) =>
            ProfessionalAssignmentModel.fromJson(json))
        .toList();
  }

  /// Get all professional assignments (admin only — no company filter).
  Future<List<ProfessionalAssignmentModel>> getAll() async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .select()
        .order('assigned_at', ascending: false)
        .limit(200);

    return SupabaseClientWrapper.safeList(response)
        .map((json) =>
            ProfessionalAssignmentModel.fromJson(json))
        .toList();
  }

  /// Get a single assignment by ID.
  Future<ProfessionalAssignmentModel?> getById(
      String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .select()
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return ProfessionalAssignmentModel.fromJson(data);
  }

  // ── Update ─────────────────────────────────────────────────

  Future<ProfessionalAssignmentModel> update(
      ProfessionalAssignmentModel assignment) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .update(assignment.toJson())
        .eq('id', assignment.id)
        .select()
        .single();

    return ProfessionalAssignmentModel.fromJson(response);
  }

  /// Update the status of an assignment.
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .update({'status': status})
        .eq('id', id);
  }

  // ── Delete ─────────────────────────────────────────────────

  Future<void> remove(String id) async {
    await _client
        .from(SupabaseClientWrapper.tblProfessionalAssignments)
        .delete()
        .eq('id', id);
  }
}
