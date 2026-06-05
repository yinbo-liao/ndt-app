import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/planning_model.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import 'planning_controller.dart';

/// Full detail view for an NDT RFI / Planning entry.
class PlanningDetailPage extends ConsumerWidget {
  final String planningId;

  const PlanningDetailPage({super.key, required this.planningId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We fetch via the by-project provider; for individual detail we'll
    // leverage PlanningRepository.getById directly.
    final detailAsync =
        ref.watch(planningDetailProvider(planningId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDT RFI Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit RFI',
            onPressed: () => context.push(
                '/planning/$planningId/edit?projectId=...'),
          ),
        ],
      ),
      body: detailAsync.when(
        data: (planning) {
          if (planning == null) {
            return const AppErrorWidget(
                message: 'RFI not found');
          }
          return _DetailContent(planning: planning);
        },
        loading: () =>
            const LoadingIndicator(message: 'Loading RFI details...'),
        error: (error, st) => AppErrorWidget(
          message: 'Failed to load: $error',
          onRetry: () => ref
              .invalidate(planningDetailProvider(planningId)),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final PlanningModel planning;

  const _DetailContent({required this.planning});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chip(planning.testingStatus, _testingColor()),
                      const SizedBox(width: 8),
                      _chip(planning.acceptStatus, _acceptColor()),
                      const SizedBox(width: 8),
                      _chip(planning.teamDeployStatus, _deployColor()),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (planning.discipline != null)
                    _chip(planning.discipline!.toUpperCase(),
                        Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              Expanded(
                child: StatCard(
                    label: 'Test Length',
                    value: '${planning.testLength} m',
                    icon: Icons.straighten,
                    iconColor: Colors.teal),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                    label: 'Reject Length',
                    value: '${planning.rejectLength} m',
                    icon: Icons.cancel,
                    iconColor: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // RFI Details
          if (planning.typeOfTesting != null ||
              planning.discipline != null ||
              planning.jobDescription != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RFI Details',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _row('Type of Testing', planning.typeOfTesting),
                    _row('Discipline', planning.discipline),
                    _row('Job Description', planning.jobDescription),
                    _row('Site Contact', planning.siteContact),
                    _row('Subcontractor', planning.subcontractor),
                    _row('Job Location', planning.jobLocation),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Task Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Task Information',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                  _row('Task', planning.ndtCompanyTask),
                  _row('Priority', planning.priority),
                  if (planning.ndtRfiDate != null)
                    _row('RFI Date',
                        planning.ndtRfiDate!.toIso8601String().split('T')[0]),
                  if (planning.plannedStartDate != null)
                    _row('Planned Start',
                        planning.plannedStartDate!.toIso8601String().split('T')[0]),
                  if (planning.plannedEndDate != null)
                    _row('Planned End',
                        planning.plannedEndDate!.toIso8601String().split('T')[0]),
                  _row('RFI Dispatched', planning.rfiSentToTeam ? 'Yes  Sent to team' : 'No  Not yet dispatched'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _row(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 110,
              child: Text(label,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Color _testingColor() {
    switch (planning.testingStatus) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _acceptColor() {
    switch (planning.acceptStatus) {
      case 'accept':
        return Colors.green;
      case 'reject':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _deployColor() {
    switch (planning.teamDeployStatus) {
      case 'deployed':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
