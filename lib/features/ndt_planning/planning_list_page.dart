import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/planning_model.dart';
import '../../data/dto/planning_dto.dart';
import '../../core/theme/color_palette.dart';
import '../../core/utils/extensions.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import 'planning_controller.dart';

/// List page for NDT planning entries.
///
/// When [projectId] is empty, entries are grouped by project name.
/// When [projectId] is provided, a flat list is shown for that project.
class PlanningListPage extends ConsumerWidget {
  final String projectId;

  const PlanningListPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planningAsync =
        ref.watch(planningByProjectDtoProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT Planning'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(
          '/planning/create?projectId=$projectId',
        ),
        child: const Icon(Icons.add),
      ),
      body: planningAsync.when(
        data: (dtos) {
          if (dtos.isEmpty) {
            return const EmptyState(
              message: 'No NDT planning entries',
              icon: Icons.assignment_outlined,
              actionLabel: 'Add Planning',
            );
          }

          // Group by project when viewing across all projects.
          if (projectId.isEmpty) {
            return _buildGroupedList(dtos);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: dtos.length,
            itemBuilder: (context, index) {
              return _PlanningListTile(
                  planning: dtos[index].planning,
                  projectName: dtos[index].projectName);
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading planning...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load planning: $error',
          onRetry: () =>
              ref.invalidate(planningByProjectDtoProvider(projectId)),
        ),
      ),
    );
  }

  /// Build a list grouped by project name.
  Widget _buildGroupedList(List<PlanningDTO> dtos) {
    // Group entries by project name.
    final grouped = <String, List<PlanningDTO>>{};
    for (final dto in dtos) {
      final key = dto.projectLabel;
      grouped.putIfAbsent(key, () => []).add(dto);
    }

    final entries = grouped.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _ProjectGroup(
          projectName: entry.key,
          dtos: entry.value,
        );
      },
    );
  }
}

/// Section header + list for a single project's RFIs.
class _ProjectGroup extends StatelessWidget {
  final String projectName;
  final List<PlanningDTO> dtos;

  const _ProjectGroup({
    required this.projectName,
    required this.dtos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.folder_outlined,
                  size: 18, color: Color(0xFF1A56DB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  projectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A56DB),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${dtos.length}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Items for this project
        ...dtos.map((dto) => _PlanningListTile(
              planning: dto.planning,
              projectName: dto.projectName,
            )),
      ],
    );
  }
}

class _PlanningListTile extends StatelessWidget {
  final PlanningModel planning;
  final String? projectName;

  const _PlanningListTile({
    required this.planning,
    this.projectName,
  });

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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (projectName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  projectName!,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorPalette.forPlanningStatus(
                            planning.testingStatus)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    planning.testingStatus
                        .replaceAll('_', ' ')
                        .toUpperCase(),
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
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Edit RFI',
              onPressed: () => context.push(
                '/planning/${planning.id}/edit?projectId=${planning.projectId}',
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/planning/${planning.id}'),
      ),
    );
  }
}
