import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/assignment_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'team_controller.dart';

/// List page for team assignments.
class AssignmentListPage extends ConsumerWidget {
  const AssignmentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(teamAssignmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Team Assignments')),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-assignment',
        onPressed: () => context.push('/assignments/create'),
        child: const Icon(Icons.add),
      ),
      body: assignmentsAsync.when(
        data: (assignments) {
          if (assignments.isEmpty) {
            return const EmptyState(
              message: 'No team assignments yet',
              icon: Icons.assignment_outlined,
              actionLabel: 'Add Assignment',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(teamAssignmentsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: assignments.length,
              itemBuilder: (_, i) => _AssignmentTile(assignment: assignments[i]),
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading assignments...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load: $e',
          onRetry: () => ref.invalidate(teamAssignmentsProvider),
        ),
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final AssignmentModel assignment;
  const _AssignmentTile({required this.assignment});

  Color _roleColor(String role) {
    switch (role) {
      case 'supervisor': return Colors.blue;
      case 'technician': return Colors.green;
      case 'inspector': return Colors.orange;
      case 'helper': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _roleColor(assignment.assignedRole.name).withAlpha(30),
          child: Icon(Icons.person, color: _roleColor(assignment.assignedRole.name)),
        ),
        title: Text('Role: ${assignment.assignedRole.name}',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Status: ${assignment.status.name}'),
        trailing: Chip(
          label: Text(assignment.assignedRole.name, style: const TextStyle(fontSize: 10)),
          backgroundColor: _roleColor(assignment.assignedRole.name).withAlpha(30),
        ),
      ),
    );
  }
}
