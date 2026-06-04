import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/deployment_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/dropdown_field.dart';
import 'shift_selector.dart';
import 'deployment_controller.dart';

/// Form page for creating/editing a team deployment.
class DeploymentFormPage extends ConsumerStatefulWidget {
  final DeploymentModel? existing;
  final String? planningId;

  const DeploymentFormPage({
    super.key,
    this.existing,
    this.planningId,
  });

  @override
  ConsumerState<DeploymentFormPage> createState() =>
      _DeploymentFormPageState();
}

class _TeamMemberEntry {
  String name;
  String role;

  _TeamMemberEntry({this.name = '', this.role = 'technician'});
}

class _DeploymentFormPageState extends ConsumerState<DeploymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  ShiftType _shift = ShiftType.day;
  DateTime? _deploymentDate;
  String _teamDeployment = '';
  String _jobLocation = '';
  String? _dailyNotes;
  String? _weatherConditions;
  bool _isSaving = false;
  List<_TeamMemberEntry> _teamMembers = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _shift = e.shift;
      _deploymentDate = e.deploymentDate;
      _teamDeployment = e.teamDeployment;
      _jobLocation = e.jobLocation;
      _dailyNotes = e.dailyNotes;
      _weatherConditions = e.weatherConditions;
      _teamMembers = e.teamMembers
          .map((m) =>
              _TeamMemberEntry(name: m.name, role: m.role))
          .toList();
    }
  }

  void _addTeamMember() {
    setState(() => _teamMembers.add(_TeamMemberEntry()));
  }

  void _removeTeamMember(int index) {
    setState(() => _teamMembers.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_deploymentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a deployment date')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(deploymentRepositoryProvider);
      final companyId = ref.read(currentUserCompanyIdProvider);
      final currentUser = ref.read(currentUserProvider);

      final teamMembers = _teamMembers
          .where((m) => m.name.trim().isNotEmpty)
          .map((m) => TeamMember(
                userId: '', // populated later if linked to user
                name: m.name.trim(),
                role: m.role,
              ))
          .toList();

      final deployment = DeploymentModel(
        id: _isEditing ? widget.existing!.id : '',
        projectNdtPlanningId: widget.planningId ??
            widget.existing?.projectNdtPlanningId ??
            '',
        ndtCompanyId: companyId ?? '',
        ndtSupervisorId: currentUser?.id,
        shift: _shift,
        deploymentDate: _deploymentDate!,
        teamDeployment: _teamDeployment,
        teamMembers: teamMembers,
        jobLocation: _jobLocation,
        dailyNotes: _dailyNotes,
        weatherConditions: _weatherConditions,
        createdBy: currentUser?.id,
      );

      if (_isEditing) {
        await repository.update(deployment);
      } else {
        await repository.create(deployment);
      }

      if (mounted) {
        ref.invalidate(deploymentsByDateRangeProvider);
        ref.invalidate(todayDeploymentsProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save deployment. Please try again.'),
          ),
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
        title: Text(_isEditing ? 'Edit Deployment' : 'New Deployment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShiftSelectorWidget(
                selectedShift: _shift,
                onShiftChanged: (shift) =>
                    setState(() => _shift = shift),
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Deployment Date',
                value: _deploymentDate,
                onChanged: (d) => _deploymentDate = d,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Team Name/Identifier',
                initialValue: _teamDeployment,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Team name is required'
                        : null,
                onChanged: (v) => _teamDeployment = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Job Location',
                initialValue: _jobLocation,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Job location is required'
                        : null,
                onChanged: (v) => _jobLocation = v,
              ),
              const SizedBox(height: 16),

              // ── Team Members Section ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Team Members',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addTeamMember,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
              ..._teamMembers.asMap().entries.map((entry) {
                final idx = entry.key;
                final member = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextInputField(
                          label: 'Name',
                          initialValue: member.name,
                          onChanged: (v) => member.name = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: DropdownField<String>(
                          label: 'Role',
                          value: member.role,
                          items: const [
                            DropdownMenuItem(
                                value: 'technician',
                                child: Text('Tech')),
                            DropdownMenuItem(
                                value: 'supervisor',
                                child: Text('Sup.')),
                            DropdownMenuItem(
                                value: 'inspector',
                                child: Text('Insp.')),
                            DropdownMenuItem(
                                value: 'helper',
                                child: Text('Helper')),
                          ],
                          onChanged: (v) {
                            if (v != null) member.role = v;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 20),
                        onPressed: () => _removeTeamMember(idx),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextInputField(
                label: 'Daily Notes',
                initialValue: _dailyNotes,
                maxLines: 3,
                onChanged: (v) => _dailyNotes = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Weather Conditions',
                initialValue: _weatherConditions,
                onChanged: (v) => _weatherConditions = v,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2),
                      )
                    : Text(_isEditing
                        ? 'Update'
                        : 'Create Deployment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
