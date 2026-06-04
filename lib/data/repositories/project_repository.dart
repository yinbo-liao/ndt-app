import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for Project CRUD operations.
class ProjectRepository {
  final SupabaseClient _client;

  ProjectRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<ProjectModel> create(ProjectModel project) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProjects)
        .insert(project.toJson())
        .select()
        .single();

    return ProjectModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  /// Get all active projects.
  Future<List<ProjectModel>> getAll({bool activeOnly = true}) async {
    var query = _client
        .from(SupabaseClientWrapper.tblProjects)
        .select();

    if (activeOnly) {
      query = query.eq('active', true);
    }

    final response = await query.order('project_name');
    return SupabaseClientWrapper.safeList(response)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  /// Get a single project by ID.
  Future<ProjectModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProjects)
        .select()
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return ProjectModel.fromJson(data);
  }

  /// Search projects by name or code.
  Future<List<ProjectModel>> search(String query) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProjects)
        .select()
        .or('project_name.ilike.%$query%,project_code.ilike.%$query%')
        .order('project_name')
        .limit(20);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ProjectModel.fromJson(json))
        .toList();
  }

  // ── Update ─────────────────────────────────────────────────

  Future<ProjectModel> update(ProjectModel project) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProjects)
        .update(project.toJson())
        .eq('id', project.id)
        .select()
        .single();

    return ProjectModel.fromJson(response);
  }

  /// Set project active/inactive status.
  Future<void> setActive(String id, bool active) async {
    await _client
        .from(SupabaseClientWrapper.tblProjects)
        .update({'active': active})
        .eq('id', id);
  }
}
