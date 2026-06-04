import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/deployment_model.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/deployment_card.dart';
import 'deployment_controller.dart';

/// List page for NDT team deployments with date and shift filtering.
class DeploymentListPage extends ConsumerWidget {
  const DeploymentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDeploymentDateProvider);
    final selectedShift = ref.watch(selectedShiftFilterProvider);

    final filter = DeploymentFilterParams(
      startDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
      endDate: DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
              23, 59, 59),
      shift: selectedShift,
    );

    final deploymentsAsync =
        ref.watch(deploymentsByDateRangeProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deployments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                ref.read(selectedDeploymentDateProvider.notifier).state =
                    picked;
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-deployment',
        onPressed: () => context.push('/deployments/create'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Shift filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Shifts'),
                  selected: selectedShift == null,
                  onSelected: (_) {
                    ref.read(selectedShiftFilterProvider.notifier).state =
                        null;
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Day'),
                  avatar: const Icon(Icons.wb_sunny, size: 16),
                  selected: selectedShift == ShiftType.day,
                  onSelected: (_) {
                    ref.read(selectedShiftFilterProvider.notifier).state =
                        ShiftType.day;
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Night'),
                  avatar: const Icon(Icons.nights_stay, size: 16),
                  selected: selectedShift == ShiftType.night,
                  onSelected: (_) {
                    ref.read(selectedShiftFilterProvider.notifier).state =
                        ShiftType.night;
                  },
                ),
              ],
            ),
          ),

          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('EEEE, MMM dd, yyyy').format(selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),

          // List
          Expanded(
            child: deploymentsAsync.when(
              data: (deployments) {
                if (deployments.isEmpty) {
                  return const EmptyState(
                    message: 'No deployments for this date',
                    icon: Icons.calendar_today,
                    actionLabel: 'Add Deployment',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: deployments.length,
                  itemBuilder: (context, index) {
                    final deployment = deployments[index];
                    return DeploymentCard(
                      deployment: deployment,
                      onTap: () => context.push(
                          '/deployments/${deployment.id}'),
                      onStatusChanged: (status) async {
                        final repo = ref.read(
                            deploymentRepositoryProvider);
                        final ds = status == 'in_progress'
                            ? DeploymentTestingStatus
                                .inProgress
                            : status == 'completed'
                                ? DeploymentTestingStatus
                                    .completed
                                : DeploymentTestingStatus
                                    .rejected;
                        await repo.updateStatus(
                          deploymentId: deployment.id,
                          status: ds,
                        );
                        ref.invalidate(
                            deploymentsByDateRangeProvider);
                        ref.invalidate(
                            todayDeploymentsProvider);
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(
                  message: 'Loading deployments...'),
              error: (error, st) => AppErrorWidget(
                message: 'Failed to load deployments: $error',
                onRetry: () => ref.invalidate(
                    deploymentsByDateRangeProvider(filter)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
