import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for User CRUD operations.
class UserRepository {
  final SupabaseClient _client;

  UserRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  /// Get all users with their company name.
  Future<List<UserModel>> getAll() async {
    final response = await _client
        .from(SupabaseClientWrapper.tblUsers)
        .select('*, ndt_companies:ndt_company_id(name)')
        .order('full_name');

    return SupabaseClientWrapper.safeList(response)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  /// Get a single user by ID.
  Future<UserModel?> getById(String id) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblUsers)
        .select()
        .eq('id', id)
        .maybeSingle();

    final data = SupabaseClientWrapper.safeSingle(response);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// Update a user's profile.
  Future<UserModel> update(UserModel user) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblUsers)
        .update(user.toJson())
        .eq('id', user.id)
        .select()
        .single();

    return UserModel.fromJson(response);
  }

  /// Set a user's active status.
  Future<void> setActive(String id, bool active) async {
    await _client
        .from(SupabaseClientWrapper.tblUsers)
        .update({'active': active})
        .eq('id', id);
  }
}
