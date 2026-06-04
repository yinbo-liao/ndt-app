import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/cards/stat_card.dart';
import '../../core/utils/extensions.dart';
import 'project_controller.dart';
import 'project_form_page.dart';

/// Detail page for a single project.
class ProjectDetailPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              final projectAsync =
                  ref.read(projectDetailProvider(projectId));
              final project = projectAsync.value;
              if (project != null) {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => ProjectFormPage(
                        existing: project),
                  ),
                )
                    .then((_) {
                  ref.invalidate(
                      projectDetailProvider(projectId));
                });
              }
            },
          ),
        ],
      ),
      body: projectAsync.when(
        data: (project) {
          if (project == null) {
            return AppErrorWidget(
              message: 'Project not found',
              onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  project.projectName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  project.projectCode,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 24),
                StatCard(
                  label: 'Location',
                  value: project.location,
                  icon: Icons.location_on,
                ),
                if (project.clientName != null)
                  StatCard(
                    label: 'Client',
                    value: project.clientName!,
                    icon: Icons.person,
                  ),
                if (project.jobTrade != null)
                  StatCard(
                    label: 'Job Trade',
                    value: project.jobTrade!,
                    icon: Icons.construction,
                  ),
                if (project.startDate != null)
                  StatCard(
                    label: 'Start Date',
                    value: project.startDate!.toIsoDateString,
                    icon: Icons.start,
                  ),
                if (project.endDate != null)
                  StatCard(
                    label: 'End Date',
                    value: project.endDate!.toIsoDateString,
                    icon: Icons.flag,
                  ),
                StatCard(
                  label: 'Status',
                  value: project.active ? 'Active' : 'Inactive',
                  icon: project.active ? Icons.check_circle : Icons.cancel,
                  iconColor: project.active ? Colors.green : Colors.grey,
                ),
              ],
            ),
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading project...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load project: $error',
          onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
        ),
      ),
    );
  }
}
