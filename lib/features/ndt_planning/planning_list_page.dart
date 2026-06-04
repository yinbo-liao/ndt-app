import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/planning_model.dart';
import '../../core/theme/color_palette.dart';
import '../../core/utils/extensions.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'planning_controller.dart';

/// List page for NDT planning entries.
class PlanningListPage extends ConsumerWidget {
  final String projectId;

  const PlanningListPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planningAsync = ref.watch(planningByProjectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Planning'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create planning form
        },
        child: const Icon(Icons.add),
      ),
      body: planningAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              message: 'No NDT planning entries',
              icon: Icons.assignment_outlined,
              actionLabel: 'Add Planning',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _PlanningListTile(planning: entries[index]);
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading planning...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load planning: $error',
          onRetry: () =>
              ref.invalidate(planningByProjectProvider(projectId)),
        ),
      ),
    );
  }
}

class _PlanningListTile extends StatelessWidget {
  final PlanningModel planning;

  const _PlanningListTile({required this.planning});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ColorPalette.forPlanningStatus(
                  planning.testingStatus)
              .withAlpha(30),
          child: Icon(
            Icons.assignment,
            color: ColorPalette.forPlanningStatus(planning.testingStatus),
          ),
        ),
        title: Text(
          planning.ndtCompanyTask,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: ColorPalette.forPlanningStatus(
                        planning.testingStatus)
                    .withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                planning.testingStatus.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.forPlanningStatus(
                      planning.testingStatus),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (planning.plannedStartDate != null)
              Text(
                planning.plannedStartDate!.toIsoDateString,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to detail
        },
      ),
    );
  }
}
