import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/contractor_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for NDT Contractor Register CRUD operations.
class ContractorRepository {
  final SupabaseClient _client;

  ContractorRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  // ── Create ─────────────────────────────────────────────────

  Future<ContractorModel> create(ContractorModel contractor) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .insert(contractor.toJson())
        .select()
        .single();

    return ContractorModel.fromJson(response);
  }

  // ── Read ───────────────────────────────────────────────────

  /// Get all non-deleted contractors for a company.
  Future<List<ContractorModel>> getByCompany(String companyId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .isFilter('deleted_at', null)
        .order('expire_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ContractorModel.fromJson(json))
        .toList();
  }

  /// Get contractors for a company and month.
  Future<List<ContractorModel>> getByCompanyAndMonth({
    required String companyId,
    required DateTime monthStart,
  }) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .eq('report_month', monthStart.toIso8601String().split('T')[0])
        .isFilter('deleted_at', null)
        .order('expire_date', ascending: false);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ContractorModel.fromJson(json))
        .toList();
  }

  /// Get expiring-soon certificates for a company.
  Future<List<ContractorModel>> getExpiringSoon(String companyId) async {
    final now = DateTime.now();
    final thirtyDaysLater = now.add(const Duration(days: 30));

    final response = await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .select()
        .eq('ndt_company_id', companyId)
        .eq('validation_status', 'valid')
        .gte('expire_date', now.toIso8601String().split('T')[0])
        .lte('expire_date', thirtyDaysLater.toIso8601String().split('T')[0])
        .isFilter('deleted_at', null)
        .order('expire_date');

    return SupabaseClientWrapper.safeList(response)
        .map((json) => ContractorModel.fromJson(json))
        .toList();
  }

  /// Get a single contractor by ID.
  Future<ContractorModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return ContractorModel.fromJson(data);
  }

  // ── Update ─────────────────────────────────────────────────

  Future<ContractorModel> update(ContractorModel contractor) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .update(contractor.toJson())
        .eq('id', contractor.id)
        .select()
        .single();

    return ContractorModel.fromJson(response);
  }

  // ── Soft Delete ───────────────────────────────────────────

  Future<void> softDelete(String id) async {
    await _client
        .from(SupabaseClientWrapper.tblContractorRegister)
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
