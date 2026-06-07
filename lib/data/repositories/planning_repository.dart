import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/planning_model.dart';
import '../dto/planning_dto.dart';
import '../../core/services/supabase_client.dart';

/// Repository for Project NDT Planning CRUD operations.
class PlanningRepository {
  final SupabaseClient _client;

  PlanningRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<PlanningModel> create(PlanningModel planning) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .insert(planning.toJson())
        .select()
        .single();

    return PlanningModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  final _joinedSelect = '*, projects:project_id(project_name, project_code), ndt_companies:ndt_company_id(name)';

  /// Get all planning entries across all projects (admin).
  Future<List<PlanningModel>> getAll() async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningModel.fromJson(json))
        .toList();
  }

  /// Get planning entries for a project.
  Future<List<PlanningModel>> getByProject(String projectId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .eq('project_id', projectId)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningModel.fromJson(json))
        .toList();
  }

  /// Get planning entries for a company across all projects.
  Future<List<PlanningModel>> getByCompany(String companyId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .eq('ndt_company_id', companyId)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningModel.fromJson(json))
        .toList();
  }

  /// Get planning entries by testing status.
  Future<List<PlanningModel>> getByStatus({
    required String companyId,
    required String status,
  }) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select()
        .eq('ndt_company_id', companyId)
        .eq('testing_status', status)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningModel.fromJson(json))
        .toList();
  }

  /// Get a single planning entry by ID (as DTO with joined names).
  Future<PlanningDTO?> getByIdAsDto(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return PlanningDTO.fromJson(data);
  }

  /// Get a single planning entry by ID (model only).
  Future<PlanningModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select()
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return PlanningModel.fromJson(data);
  }

  /// Get planning entries as DTOs for a project.
  Future<List<PlanningDTO>> getByProjectAsDto(String projectId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .eq('project_id', projectId)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningDTO.fromJson(json))
        .toList();
  }

  /// Get planning entries as DTOs for a company.
  Future<List<PlanningDTO>> getByCompanyAsDto(String companyId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .eq('ndt_company_id', companyId)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningDTO.fromJson(json))
        .toList();
  }

  /// Get all planning entries as DTOs (admin).
  Future<List<PlanningDTO>> getAllAsDto() async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .select(_joinedSelect)
        .order('planned_start_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => PlanningDTO.fromJson(json))
        .toList();
  }

  // ── Update ─────────────────────────────────────────────────

  Future<PlanningModel> update(PlanningModel planning) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .update(planning.toJson())
        .eq('id', planning.id)
        .select()
        .single();

    return PlanningModel.fromJson(response);
  }

  /// Update only the testing status.
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    await _client
        .from(SupabaseClientWrapper.tblPlanning)
        .update({'testing_status': status})
        .eq('id', id);
  }
}
