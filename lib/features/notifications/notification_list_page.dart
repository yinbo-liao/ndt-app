import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'notification_controller.dart';

/// Read-only notifications list page.
class NotificationListPage extends ConsumerWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifsAsync.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return const EmptyState(message: 'No notifications', icon: Icons.notifications_none);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userNotificationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: notifs.length,
              itemBuilder: (_, i) {
                final n = notifs[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  color: n.read ? null : Colors.blue.withAlpha(12),
                  child: ListTile(
                    leading: Icon(
                      n.type == 'cert_expiry' ? Icons.warning_amber :
                      n.type == 'approval_needed' ? Icons.verified :
                      n.type == 'rfi_dispatched' ? Icons.send :
                      Icons.info_outline,
                      color: n.read ? Colors.grey : const Color(0xFF1A56DB),
                    ),
                    title: Text(n.title,
                        style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(n.body ?? '',
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: n.read ? null : Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: Color(0xFF1A56DB), shape: BoxShape.circle),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading notifications...'),
        error: (e, _) => AppErrorWidget(message: 'Failed to load: $e', onRetry: () => ref.invalidate(userNotificationsProvider)),
      ),
    );
  }
}
