import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/assignment_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'team_controller.dart';

/// Displays the current NDT team member's assigned projects.
///
/// Consumes [myAssignedProjectsProvider] from the team controller
/// and shows each assignment with project name, role, and status.
class MyAssignmentsPage extends ConsumerWidget {
  const MyAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(myAssignedProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Assignments')),
      body: assignmentsAsync.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const EmptyState(
              message: 'No active assignments',
              icon: Icons.assignment_outlined,
              actionLabel: null,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              return _AssignmentCard(assignment: assignments[index]);
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading assignments...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load assignments: $error',
          onRetry: () =>
              ref.invalidate(myAssignedProjectsProvider),
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(assignment.status).withAlpha(30),
          child: Icon(
            _statusIcon(assignment.status),
            color: _statusColor(assignment.status),
          ),
        ),
        title: Text(
          assignment.projectId, // shown via join data in practice
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Role: ${assignment.assignedRole.name} · Status: ${assignment.status.name}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to related deployments
          context.push('/deployments');
        },
      ),
    );
  }

  Color _statusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.active:
        return Colors.green;
      case AssignmentStatus.completed:
        return Colors.blue;
      case AssignmentStatus.onHold:
        return Colors.orange;
      case AssignmentStatus.removed:
        return Colors.red;
    }
  }

  IconData _statusIcon(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.active:
        return Icons.play_circle;
      case AssignmentStatus.completed:
        return Icons.check_circle;
      case AssignmentStatus.onHold:
        return Icons.pause_circle;
      case AssignmentStatus.removed:
        return Icons.cancel;
    }
  }
}
