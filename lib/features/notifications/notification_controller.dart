import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository.dart';
import '../../providers/auth_provider.dart';

/// Provides the [NotificationRepository] singleton.
final notificationRepoProvider =
    Provider<NotificationRepository>((ref) => NotificationRepository());

/// Fetch notifications for the current user.
final userNotificationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  final repo = ref.watch(notificationRepoProvider);
  return repo.getForUser(userId);
});
