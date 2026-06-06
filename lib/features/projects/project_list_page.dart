import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/project_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'project_controller.dart';

/// List page for projects.
class ProjectListPage extends ConsumerWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        leading: IconButton(
          icon: const Icon(Icons.dashboard),
          tooltip: 'Back to Dashboard',
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-project',
        onPressed: () => context.push('/projects/create'),
        child: const Icon(Icons.add),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const EmptyState(
              message: 'No projects found',
              icon: Icons.business_outlined,
              actionLabel: 'Add Project',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectListTile(project: project);
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading projects...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load projects: $error',
          onRetry: () => ref.invalidate(projectsProvider),
        ),
      ),
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  final ProjectModel project;

  const _ProjectListTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withAlpha(30),
          child: const Icon(Icons.business, color: Colors.blue),
        ),
        title: Text(project.projectName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.projectCode,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(project.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Edit project',
              onPressed: () => context.push('/projects/${project.id}/edit'),
            ),
            const SizedBox(width: 4),
            project.active
                ? const Chip(
                    label: Text('Active', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  )
                : const Chip(
                    label: Text('Inactive', style: TextStyle(fontSize: 11)),
                  ),
          ],
        ),
        onTap: () =>
            context.push('/projects/${project.id}'),
      ),
    );
  }
}
