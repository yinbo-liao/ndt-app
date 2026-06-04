import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_client.dart';

/// Repository for in-app notifications.
class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  /// Get notifications for the current user.
  Future<List<Map<String, dynamic>>> getForUser(String userId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblNotifications)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return SupabaseClientWrapper.safeList(response);
  }

  /// Mark a notification as read.
  Future<void> markRead(String id) async {
    await _client
        .from(SupabaseClientWrapper.tblNotifications)
        .update({'read': true})
        .eq('id', id);
  }
}
