import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/professional_model.dart';
import '../../data/models/professional_assignment_model.dart';
import '../../providers/auth_provider.dart';
import '../professional_register/professional_controller.dart';
import '../team_management/team_controller.dart';
import 'rfi_task_controller.dart';

/// Bottom sheet dialog for assigning NDT professionals to a planning RFI.
class AssignTechnicianDialog extends ConsumerStatefulWidget {
  final String planningId;
  final String rfiTaskName;

  const AssignTechnicianDialog({
    super.key,
    required this.planningId,
    required this.rfiTaskName,
  });

  @override
  ConsumerState<AssignTechnicianDialog> createState() =>
      _AssignTechnicianDialogState();
}

class _AssignTechnicianDialogState
    extends ConsumerState<AssignTechnicianDialog> {
  ProfessionalModel? _selectedProfessional;
  String _selectedRole = 'technician';
  bool _isSaving = false;

  Future<void> _assign() async {
    if (_selectedProfessional == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a professional')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(rfiTaskAssignmentRepoProvider);
      final currentUser = ref.read(currentUserProvider);

      final assignment = ProfessionalAssignmentModel(
        id: '',
        planningId: widget.planningId,
        professionalId: _selectedProfessional!.id,
        assignedRole: _selectedRole,
        status: 'assigned',
        createdBy: currentUser?.id,
      );

      await repo.create(assignment);

      if (mounted) {
        ref.invalidate(assignmentsByPlanningProvider(widget.planningId));
        ref.invalidate(allProfessionalAssignmentsProvider);
        setState(() {
          _selectedProfessional = null;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_selectedProfessional?.name ?? "Professional"} assigned as $_selectedRole'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign: $e')),
        );
      }
    }
  }

  Future<void> _remove(String assignmentId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: Text('Remove $name from this RFI?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final repo = ref.read(rfiTaskAssignmentRepoProvider);
      await repo.remove(assignmentId);

      if (mounted) {
        ref.invalidate(assignmentsByPlanningProvider(widget.planningId));
        ref.invalidate(allProfessionalAssignmentsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name removed from RFI')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final professionalsAsync = ref.watch(professionalsProvider);
    final assignmentsAsync =
        ref.watch(assignmentsByPlanningProvider(widget.planningId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text('Assign Technician',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(widget.rfiTaskName,
                  style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 20),

              // Assign form
              Text('Select Professional',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              professionalsAsync.when(
                data: (professionals) {
                  final active =
                      professionals.where((p) => p.certificateStatus == 'valid').toList();
                  if (active.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No active professionals available'),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedProfessional?.id,
                    decoration: const InputDecoration(
                      labelText: 'Professional',
                      prefixIcon: Icon(Icons.person_search),
                      border: OutlineInputBorder(),
                    ),
                    items: active
                        .map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                  '${p.name} (${p.typeOfCertificate})'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedProfessional =
                            active.firstWhere((p) => p.id == v));
                      }
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 12),

              // Role selector
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'technician', child: Text('Technician')),
                  DropdownMenuItem(value: 'inspector', child: Text('Inspector')),
                  DropdownMenuItem(value: 'helper', child: Text('Helper')),
                  DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedRole = v);
                },
              ),
              const SizedBox(height: 16),

              // Assign button
              FilledButton.icon(
                onPressed: _isSaving ? null : _assign,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.person_add),
                label: Text(_isSaving ? 'Assigning...' : 'Assign Technician'),
              ),
              const SizedBox(height: 24),

              // Current assignments
              Text('Currently Assigned',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              assignmentsAsync.when(
                data: (assignments) {
                  if (assignments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No technicians assigned yet',
                          style: TextStyle(color: Colors.grey[400])),
                    );
                  }
                  return Column(
                    children: assignments.map((a) {
                      final roleColor = _roleColor(a.assignedRole);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: roleColor.withAlpha(30),
                            child: Icon(Icons.person, color: roleColor, size: 20),
                          ),
                          title: Text('Professional: ${a.professionalId.length > 8 ? a.professionalId.substring(0, 8) : a.professionalId}'),
                          subtitle: Text('Status: ${a.status}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(a.assignedRole,
                                    style: const TextStyle(fontSize: 10)),
                                backgroundColor: roleColor.withAlpha(25),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                                tooltip: 'Remove',
                                onPressed: () => _remove(a.id,
                                    'Professional ${a.professionalId.substring(0, 8)}'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
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
}
