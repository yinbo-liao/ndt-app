import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audit_log_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for read-only audit log access.
class AuditRepository {
  final SupabaseClient _client;

  AuditRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  /// Get all audit logs, optionally filtered by table name.
  Future<List<AuditLogModel>> getAll({String? tableName}) async {
    var query = _client
        .from(SupabaseClientWrapper.tblAuditLogs)
        .select('*, users!changed_by(full_name, email)');

    if (tableName != null) {
      query = query.eq('table_name', tableName);
    }

    final response = await query
        .order('changed_at', ascending: false)
        .limit(100);
    return SupabaseClientWrapper.safeList(response)
        .map((json) => AuditLogModel.fromJson(json))
        .toList();
  }
}
