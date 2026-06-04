import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/assignment_model.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../../widgets/forms/date_picker_field.dart';

/// Page for assigning a team member to a project.
class TeamAssignmentPage extends ConsumerStatefulWidget {
  final String? assignmentId;

  const TeamAssignmentPage({super.key, this.assignmentId});

  @override
  ConsumerState<TeamAssignmentPage> createState() =>
      _TeamAssignmentPageState();
}

class _TeamAssignmentPageState extends ConsumerState<TeamAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  AssignmentRole _role = AssignmentRole.technician;
  DateTime? _assignedFrom;
  DateTime? _assignedTo;
  final bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Team Member'),
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
                onPressed: _isSaving ? null : () {},
                child: const Text('Assign'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
