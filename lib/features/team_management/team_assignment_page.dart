import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assignment_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../../widgets/forms/date_picker_field.dart';
import 'team_controller.dart';

/// Page for assigning a team member to a project.
class TeamAssignmentPage extends ConsumerStatefulWidget {
  final String? assignmentId;
  final String? userId;
  final String? projectId;

  const TeamAssignmentPage({
    super.key,
    this.assignmentId,
    this.userId,
    this.projectId,
  });

  @override
  ConsumerState<TeamAssignmentPage> createState() =>
      _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends ConsumerState<TeamAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  AssignmentRole _role = AssignmentRole.technician;
  DateTime? _assignedFrom;
  DateTime? _assignedTo;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(assignmentRepoProvider);
      final companyId = ref.read(currentUserCompanyIdProvider);

      final assignment = AssignmentModel(
        id: widget.assignmentId ?? '',
        userId: widget.userId ?? '',
        projectId: widget.projectId ?? '',
        ndtCompanyId: companyId ?? '',
        assignedRole: _role,
        status: AssignmentStatus.active,
        assignedFrom: _assignedFrom,
        assignedTo: _assignedTo,
      );

      if (widget.assignmentId != null) {
        await repo.update(assignment);
      } else {
        await repo.create(assignment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.assignmentId != null
                ? 'Assignment updated'
                : 'Team member assigned'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignmentId != null
            ? 'Edit Assignment'
            : 'Assign Team Member'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownField<AssignmentRole>(
                label: 'Role',
                value: _role,
                items: const [
                  DropdownMenuItem(
                    value: AssignmentRole.supervisor,
                    child: Text('Supervisor'),
                  ),
                  DropdownMenuItem(
                    value: AssignmentRole.technician,
                    child: Text('Technician'),
                  ),
                  DropdownMenuItem(
                    value: AssignmentRole.inspector,
                    child: Text('Inspector'),
                  ),
                  DropdownMenuItem(
                    value: AssignmentRole.helper,
                    child: Text('Helper'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) _role = v;
                },
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Assigned From',
                value: _assignedFrom,
                onChanged: (d) => _assignedFrom = d,
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Assigned To (optional)',
                value: _assignedTo,
                firstDate: _assignedFrom,
                onChanged: (d) => _assignedTo = d,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Assign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
