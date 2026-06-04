import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professional_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for NDT Professional Register CRUD operations.
///
/// Supports filtering by company, sector, certification status,
/// and soft delete with the `deleted_at` column.
class ProfessionalRepository {
  final SupabaseClient _client;

  ProfessionalRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<ProfessionalModel> create(ProfessionalModel professional) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .insert(professional.toJson())
        .select()
        .single();

    return ProfessionalModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  /// Get all non-deleted professionals for a company.
  Future<List<ProfessionalModel>> getByCompany(String companyId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .isFilter('deleted_at', null)
        .order('name');

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ProfessionalModel.fromJson(json))
        .toList();
  }

  /// Get professionals by company and working sector.
  Future<List<ProfessionalModel>> getByCompanyAndSector({
    required String companyId,
    required String workingSector,
  }) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .eq('working_sector', workingSector)
        .isFilter('deleted_at', null)
        .order('name');

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ProfessionalModel.fromJson(json))
        .toList();
  }

  /// Get professionals by certification status.
  Future<List<ProfessionalModel>> getByStatus({
    required String companyId,
    required String certificateStatus,
  }) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .eq('certificate_status', certificateStatus)
        .isFilter('deleted_at', null)
        .order('expiry_date');

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ProfessionalModel.fromJson(json))
        .toList();
  }

  /// Get expiring-soon certificates for a company (30-day window).
  Future<List<ProfessionalModel>> getExpiringSoon(String companyId) async {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .eq('certificate_status', 'valid')
        .gte('expiry_date', now.toIso8601String().split('T')[0])
        .lte('expiry_date', thirtyDaysLater.toIso8601String().split('T')[0])
        .isFilter('deleted_at', null)
        .order('expiry_date');

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ProfessionalModel.fromJson(json))
        .toList();
  }

  /// Get a single professional by ID.
  Future<ProfessionalModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return ProfessionalModel.fromJson(data);
  }

  // ── Update ─────────────────────────────────────────────────

  Future<ProfessionalModel> update(ProfessionalModel professional) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .update(professional.toJson())
        .eq('id', professional.id)
        .select()
        .single();

    return ProfessionalModel.fromJson(response);
  }

  // ── Soft Delete ───────────────────────────────────────────

  Future<void> softDelete(String id) async {
    await _client
        .from(SupabaseClientWrapper.tblProfessionalRegister)
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
