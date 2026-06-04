import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'user_controller.dart';

/// List page for user management (admin only).
class UserListPage extends ConsumerWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Update'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-user',
        onPressed: () => context.push('/users/create'),
        child: const Icon(Icons.person_add),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyState(
              message: 'No users found',
              icon: Icons.people_outline,
              actionLabel: 'Add User',
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(usersProvider),
            child: ListView.builder(
              padding:
                  const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserListTile(user: user);
              },
            ),
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading users...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load users: $error',
          onRetry: () => ref.invalidate(usersProvider),
        ),
      ),
    );
  }
}

class _UserListTile extends ConsumerWidget {
  final UserModel user;

  const _UserListTile({required this.user});

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.blue;
      case 'ndt_company':
        return Colors.green;
      case 'ndt_team':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'ndt_company':
        return 'NDT Company';
      case 'ndt_team':
        return 'NDT Team';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = _roleColor(user.role);

    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: roleColor.withAlpha(30),
          child: Text(
            user.fullName.isNotEmpty
                ? user.fullName[0].toUpperCase()
                : '?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: roleColor),
          ),
        ),
        title: Text(user.fullName,
            style:
                const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(user.email,
            style: TextStyle(
                fontSize: 13, color: Colors.grey[600])),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: roleColor),
              ),
              child: Text(
                _roleLabel(user.role),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
            if (!user.active) ...[
              const SizedBox(height: 2),
              Text(
                'Inactive',
                style: TextStyle(
                    fontSize: 10, color: Colors.red[400]),
              ),
            ],
          ],
        ),
        onTap: () {
          context.push('/users/${user.id}/edit');
        },
      ),
    );
  }
}
