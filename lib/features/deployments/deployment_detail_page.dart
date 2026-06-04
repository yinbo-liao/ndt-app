import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/deployment_model.dart';
import '../../core/theme/color_palette.dart';
import '../../core/utils/extensions.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/cards/stat_card.dart';
import 'deployment_controller.dart';

/// Detail page for a single deployment.
class DeploymentDetailPage extends ConsumerWidget {
  final String deploymentId;

  const DeploymentDetailPage({super.key, required this.deploymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deploymentAsync =
        ref.watch(deploymentDetailProvider(deploymentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deployment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () =>
                context.push('/deployments/$deploymentId/edit'),
          ),
        ],
      ),
      body: deploymentAsync.when(
        data: (deployment) {
          if (deployment == null) {
            return AppErrorWidget(
              message: 'Deployment not found',
              onRetry: () => ref
                  .invalidate(deploymentDetailProvider(deploymentId)),
            );
          }

          final isDay = deployment.shift == ShiftType.day;
          final shiftColor = ColorPalette.forShift(isDay ? 'day' : 'night');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Shift banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: shiftColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: shiftColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDay ? Icons.wb_sunny : Icons.nights_stay,
                        color: shiftColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDay ? 'Day Shift' : 'Night Shift',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: shiftColor,
                            ),
                          ),
                          Text(
                            deployment.deploymentDate.toIsoDateString,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                StatCard(
                  label: 'Team',
                  value: deployment.teamDeployment,
                  icon: Icons.groups,
                ),
                StatCard(
                  label: 'Location',
                  value: deployment.jobLocation,
                  icon: Icons.location_on,
                ),
                StatCard(
                  label: 'Status',
                  value: deployment.testingStatus.name.snakeToTitleCase,
                  icon: Icons.info_outline,
                  iconColor: ColorPalette.forTestingStatus(
                      deployment.testingStatus.name),
                ),
                StatCard(
                  label: 'Test Length',
                  value: '${deployment.testLength.toStringAsFixed(1)}m',
                  icon: Icons.straighten,
                ),
                if (deployment.rejectLength > 0)
                  StatCard(
                    label: 'Reject Length',
                    value: '${deployment.rejectLength.toStringAsFixed(1)}m',
                    icon: Icons.cancel,
                    iconColor: Colors.red,
                  ),
                // Team Members List
                if (deployment.teamMembers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  size: 20,
                                  color: Color(0xFF1A56DB)),
                              const SizedBox(width: 8),
                              Text(
                                'Team Members '
                                '(${deployment.memberCount})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...deployment.teamMembers.map(
                            (member) => Padding(
                              padding: const EdgeInsets.only(
                                  top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                        member.name),
                                  ),
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors.blue
                                          .withAlpha(
                                              20),
                                      borderRadius:
                                          BorderRadius
                                              .circular(8),
                                    ),
                                    child: Text(
                                      member.role,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                        color: Color(
                                            0xFF1A56DB),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Status Workflow Buttons
                const SizedBox(height: 16),
                _buildStatusActions(
                    context, ref, deployment),

                if (deployment.dailyNotes != null &&
                    deployment.dailyNotes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Notes',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(deployment.dailyNotes!),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(
            message: 'Loading deployment...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load deployment: $error',
          onRetry: () =>
              ref.invalidate(deploymentDetailProvider(deploymentId)),
        ),
      ),
    );
  }
}

/// Builds the status workflow action buttons for a deployment.
Widget _buildStatusActions(
  BuildContext context,
  WidgetRef ref,
  DeploymentModel deployment,
) {
  final status = deployment.testingStatus;
  final repo = ref.read(deploymentRepositoryProvider);
  final deploymentId = deployment.id;

  Future<void> update(
      DeploymentTestingStatus newStatus) async {
    await repo.updateStatus(
      deploymentId: deploymentId,
      status: newStatus,
    );
    ref.invalidate(deploymentDetailProvider(deploymentId));
    ref.invalidate(deploymentsByDateRangeProvider);
    ref.invalidate(todayDeploymentsProvider);
  }

  switch (status) {
    case DeploymentTestingStatus.notStarted:
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: () =>
              update(DeploymentTestingStatus.inProgress),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Testing'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      );

    case DeploymentTestingStatus.inProgress:
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => update(
                  DeploymentTestingStatus.completed),
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => update(
                  DeploymentTestingStatus.rejected),
              icon: const Icon(Icons.cancel),
              label: const Text('Reject'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      );

    case DeploymentTestingStatus.completed:
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Testing Completed',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ],
        ),
      );

    case DeploymentTestingStatus.rejected:
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('Testing Rejected',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
          ],
        ),
      );
  }
}
