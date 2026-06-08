import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/planning_model.dart';
import '../../core/theme/color_palette.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../ndt_planning/planning_controller.dart';
import 'assign_technician_dialog.dart';
import 'rfi_task_controller.dart';

/// RFI Task Assignment page — lists all NDT Planning RFIs and allows
/// NDT contractor supervisors to assign NDT technicians to each RFI.
class RfiTaskListPage extends ConsumerWidget {
  const RfiTaskListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planningAsync = ref.watch(planningByCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFI Task Assignment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(planningByCompanyProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-planning-rfi',
        onPressed: () => context.push('/planning/create'),
        icon: const Icon(Icons.add),
        label: const Text('New RFI'),
      ),
      body: planningAsync.when(
        data: (plannings) {
          if (plannings.isEmpty) {
            return const EmptyState(
              message: 'No NDT planning RFIs found',
              icon: Icons.assignment_outlined,
              actionLabel: 'Create RFI',
            );
          }

          // Group by project
          final grouped = _groupByProject(plannings);
          if (grouped.isEmpty) {
            return const EmptyState(
              message: 'No RFIs to display',
              icon: Icons.assignment_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: grouped.entries.length,
            itemBuilder: (context, index) {
              final entry = grouped.entries.elementAt(index);
              return _ProjectRfiGroup(
                projectName: entry.key,
                plannings: entry.value,
              );
            },
          );
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading RFIs...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load: $error',
          onRetry: () => ref.invalidate(planningByCompanyProvider),
        ),
      ),
    );
  }

  Map<String, List<PlanningModel>> _groupByProject(List<PlanningModel> plannings) {
    final map = <String, List<PlanningModel>>{};
    for (final p in plannings) {
      final key = p.projectId;
      map.putIfAbsent(key, () => []).add(p);
    }
    return map;
  }
}

/// Section header + list of RFIs for a single project.
class _ProjectRfiGroup extends StatelessWidget {
  final String projectName;
  final List<PlanningModel> plannings;

  const _ProjectRfiGroup({
    required this.projectName,
    required this.plannings,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.folder_outlined,
                  size: 18, color: Color(0xFF1A56DB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  projectName.isNotEmpty ? projectName : 'Project',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A56DB),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${plannings.length} RFI${plannings.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        ...plannings.map((p) => _RfiTaskTile(planning: p)),
      ],
    );
  }
}

/// Individual RFI tile showing task info and assignment controls.
class _RfiTaskTile extends ConsumerWidget {
  final PlanningModel planning;

  const _RfiTaskTile({required this.planning});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync =
        ref.watch(assignmentsByPlanningProvider(planning.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RFI header row
            Row(
              children: [
                // Status icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorPalette.forPlanningStatus(planning.testingStatus)
                        .withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: ColorPalette.forPlanningStatus(planning.testingStatus),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Task name + status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planning.ndtCompanyTask,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusChip(status: planning.testingStatus),
                          const SizedBox(width: 8),
                          if (planning.plannedStartDate != null)
                            Text(
                              planning.plannedStartDate!
                                  .toIso8601String()
                                  .substring(0, 10),
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Assign button
                FilledButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (_) => AssignTechnicianDialog(
                        planningId: planning.id,
                        rfiTaskName: planning.ndtCompanyTask,
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Assign', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),

            // Assigned technicians summary
            const SizedBox(height: 8),
            assignmentsAsync.when(
              data: (assignments) {
                if (assignments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 44),
                    child: Text(
                      'No technicians assigned',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: assignments.map((a) {
                      final color = _roleColor(a.assignedRole);
                      return Chip(
                        avatar: Icon(Icons.person, size: 14, color: color),
                        label: Text(
                          a.assignedRole,
                          style: TextStyle(fontSize: 10, color: color),
                        ),
                        backgroundColor: color.withAlpha(20),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(left: 44),
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status chip for planning testing status.
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = ColorPalette.forPlanningStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

Color _roleColor(String role) {
  switch (role) {
    case 'supervisor': return Colors.blue;
    case 'technician': return Colors.green;
    case 'inspector': return Colors.orange;
    case 'helper': return Colors.grey;
    default: return Colors.grey;
  }
}
