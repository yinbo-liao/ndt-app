import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'team_controller.dart';

/// Read-only list page for professional-to-RFI assignments.
class ProfessionalAssignmentListPage extends ConsumerWidget {
  const ProfessionalAssignmentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(allProfessionalAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Professional Assignments')),
      body: assignmentsAsync.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const EmptyState(
              message: 'No professional assignments found',
              icon: Icons.link_off,
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(allProfessionalAssignmentsProvider),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                      const Color(0xFF1A56DB).withAlpha(15)),
                  columns: const [
                    DataColumn(label: Text('Professional', style: _hdr)),
                    DataColumn(label: Text('Planning (RFI)', style: _hdr)),
                    DataColumn(label: Text('Role', style: _hdr)),
                    DataColumn(label: Text('Status', style: _hdr)),
                    DataColumn(label: Text('Assigned At', style: _hdr)),
                  ],
                  rows: assignments.map((a) {
                    final assignedAt = a.assignedAt?.toIso8601String() ?? '';
                    final displayTime = assignedAt.length > 16
                        ? assignedAt.substring(0, 16)
                        : assignedAt;
                    return DataRow(
                      color: _statusColor(a.status),
                      cells: [
                        DataCell(Text(a.professionalId.length > 8
                            ? a.professionalId.substring(0, 8)
                            : a.professionalId)),
                        DataCell(Text(a.planningId.length > 8
                            ? a.planningId.substring(0, 8)
                            : a.planningId)),
                        DataCell(Chip(
                          label: Text(a.assignedRole,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                          backgroundColor:
                              _roleColor(a.assignedRole).withAlpha(20),
                        )),
                        DataCell(Chip(
                          label: Text(a.status,
                              style: const TextStyle(fontSize: 10)),
                          backgroundColor:
                              _statusColor(a.status)?.resolve(<WidgetState>{}) ??
                                  Colors.grey.withAlpha(20),
                        )),
                        DataCell(Text(displayTime)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading assignments...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load: $e',
          onRetry: () =>
              ref.invalidate(allProfessionalAssignmentsProvider),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'supervisor':
        return Colors.blue;
      case 'inspector':
        return Colors.orange;
      case 'technician':
        return Colors.green;
      case 'helper':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  WidgetStateProperty<Color?>? _statusColor(String status) {
    switch (status) {
      case 'active':
        return const WidgetStatePropertyAll(Color(0xFFE8F5E9));
      case 'completed':
        return const WidgetStatePropertyAll(Color(0xFFE3F2FD));
      case 'removed':
        return const WidgetStatePropertyAll(Color(0xFFFFEBEE));
      default:
        return null;
    }
  }

  static const _hdr = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: Color(0xFF1A56DB));
}
