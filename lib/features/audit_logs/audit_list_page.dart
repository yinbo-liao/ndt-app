import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'audit_controller.dart';

/// Read-only audit log viewer page.
class AuditListPage extends ConsumerWidget {
  const AuditListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(message: 'No audit logs found', icon: Icons.history);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(auditLogsProvider),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(const Color(0xFF1A56DB).withAlpha(15)),
                  columns: const [
                    DataColumn(label: Text('Table', style: _hdr)),
                    DataColumn(label: Text('Action', style: _hdr)),
                    DataColumn(label: Text('Changed By', style: _hdr)),
                    DataColumn(label: Text('Timestamp', style: _hdr)),
                  ],
                  rows: logs.map((log) {
                    final userName = log.changedByUserName ?? 'System';
                    final changedAt = log.changedAt?.toIso8601String() ?? '';
                    final displayTime = changedAt.length > 16 ? changedAt.substring(0, 16) : changedAt;
                    return DataRow(
                      color: log.action == 'DELETE'
                          ? const WidgetStatePropertyAll(Color(0xFFFFEBEE))
                          : log.action == 'INSERT'
                              ? const WidgetStatePropertyAll(Color(0xFFE8F5E9))
                              : null,
                      cells: [
                        DataCell(Text(log.tableName)),
                        DataCell(Chip(
                          label: Text(log.action, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          backgroundColor: log.action == 'DELETE' ? Colors.red.withAlpha(20) : log.action == 'INSERT' ? Colors.green.withAlpha(20) : Colors.orange.withAlpha(20),
                        )),
                        DataCell(Text(userName)),
                        DataCell(Text(displayTime)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading audit logs...'),
        error: (e, _) => AppErrorWidget(message: 'Failed to load: $e', onRetry: () => ref.invalidate(auditLogsProvider)),
      ),
    );
  }

  static const _hdr = TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1A56DB));
}
