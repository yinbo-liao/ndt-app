import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'team_controller.dart';

/// List page for team members and assignments.
class TeamListPage extends ConsumerWidget {
  const TeamListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(teamMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Management'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add team member
        },
        child: const Icon(Icons.person_add),
      ),
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return const EmptyState(
              message: 'No team members found',
              icon: Icons.people_outline,
              actionLabel: 'Add Member',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withAlpha(30),
                    child: Text(
                      member.fullName.isNotEmpty
                          ? member.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  title: Text(member.fullName),
                  subtitle: Text(member.role.replaceAll('_', ' ').toUpperCase()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to member detail/assignment
                  },
                ),
              );
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading team...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load team: $error',
          onRetry: () => ref.invalidate(teamMembersProvider),
        ),
      ),
    );
  }
}
