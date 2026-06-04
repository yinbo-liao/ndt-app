import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for Company CRUD operations.
class CompanyRepository {
  final SupabaseClient _client;

  CompanyRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  /// Get all companies, optionally filtered to active only.
  Future<List<CompanyModel>> getAll({bool activeOnly = true}) async {
    var query = _client
        .from(SupabaseClientWrapper.tblCompanies)
        .select();

    if (activeOnly) {
      query = query.eq('active', true);
    }

    final response = await query.order('name');
    return SupabaseClientWrapper.safeList(response)
        .map((json) => CompanyModel.fromJson(json))
        .toList();
  }

  /// Create a new company.
  Future<CompanyModel> create(CompanyModel company) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblCompanies)
        .insert(company.toJson())
        .select()
        .single();
    return CompanyModel.fromJson(response);
  }

  /// Update an existing company.
  Future<CompanyModel> update(CompanyModel company) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblCompanies)
        .update(company.toJson())
        .eq('id', company.id)
        .select()
        .single();
    return CompanyModel.fromJson(response);
  }

  /// Get a single company by ID.
  Future<CompanyModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblCompanies)
        .select()
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return CompanyModel.fromJson(data);
  }
}
