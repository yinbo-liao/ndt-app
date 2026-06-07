import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../../core/services/supabase_client.dart';

/// Repository for in-app notifications.
class NotificationRepository {
  final SupabaseClient _client;

  NotificationRepository({SupabaseClient? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  /// Get notifications for the current user.
  Future<List<NotificationModel>> getForUser(String userId) async {
    final response = await _client
        .from(SupabaseClientWrapper.tblNotifications)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  /// Get all notifications (admin only — no user filter).
  Future<List<NotificationModel>> getAll() async {
    final response = await _client
        .from(SupabaseClientWrapper.tblNotifications)
        .select()
        .order('created_at', ascending: false)
        .limit(200);

    return SupabaseClientWrapper.safeList(response)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  /// Mark a notification as read.
  Future<void> markRead(String id) async {
    await _client
        .from(SupabaseClientWrapper.tblNotifications)
        .update({'read': true})
        .eq('id', id);
  }
}
