import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/professional_assignment_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../ndt_planning/planning_controller.dart';
import '../professional_register/professional_controller.dart';
import 'team_controller.dart';

/// Form page for creating a Professional-to-RFI assignment.
class ProfessionalAssignmentFormPage extends ConsumerStatefulWidget {
  const ProfessionalAssignmentFormPage({super.key});

  @override
  ConsumerState<ProfessionalAssignmentFormPage> createState() =>
      _ProfessionalAssignmentFormPageState();
}

class _ProfessionalAssignmentFormPageState
    extends ConsumerState<ProfessionalAssignmentFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPlanningId;
  String? _selectedProfessionalId;
  String _assignedRole = 'technician';
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPlanningId == null || _selectedProfessionalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a planning entry and a professional')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(professionalAssignmentRepoProvider);
      final userId = ref.read(currentUserProvider)?.id;

      final assignment = ProfessionalAssignmentModel(
        id: '',
        planningId: _selectedPlanningId!,
        professionalId: _selectedProfessionalId!,
        assignedRole: _assignedRole,
        status: 'assigned',
        assignedAt: DateTime.now(),
        createdBy: userId,
      );

      await repo.create(assignment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Professional assigned to RFI')),
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
    final planningAsync = ref.watch(planningByCompanyProvider);
    final professionalsAsync = ref.watch(professionalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Professional to RFI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Planning (RFI) selector ──
              planningAsync.when(
                data: (plannings) {
                  if (plannings.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No planning entries available',
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  return DropdownField<String>(
                    label: 'Planning (RFI) Entry',
                    value: _selectedPlanningId,
                    hintText: 'Select RFI / planning entry',
                    items: plannings.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          p.ndtCompanyTask.length > 40
                              ? '${p.ndtCompanyTask.substring(0, 40)}...'
                              : p.ndtCompanyTask,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedPlanningId = v),
                    validator: (v) =>
                        v == null ? 'Please select a planning entry' : null,
                  );
                },
                loading: () => const LoadingIndicator(message: 'Loading planning entries...'),
                error: (e, _) => AppErrorWidget(message: 'Failed to load planning entries: $e'),
              ),
              const SizedBox(height: 16),

              // ── Professional selector ──
              professionalsAsync.when(
                data: (professionals) {
                  if (professionals.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No professionals available',
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  return DropdownField<String>(
                    label: 'Professional',
                    value: _selectedProfessionalId,
                    hintText: 'Select NDT professional',
                    items: professionals.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          '${p.name} (${p.typeOfCertificate})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedProfessionalId = v),
                    validator: (v) =>
                        v == null ? 'Please select a professional' : null,
                  );
                },
                loading: () => const LoadingIndicator(message: 'Loading professionals...'),
                error: (e, _) => AppErrorWidget(message: 'Failed to load professionals: $e'),
              ),
              const SizedBox(height: 16),

              // ── Assigned Role ──
              DropdownField<String>(
                label: 'Assigned Role',
                value: _assignedRole,
                items: const [
                  DropdownMenuItem(value: 'technician', child: Text('Technician')),
                  DropdownMenuItem(value: 'inspector', child: Text('Inspector')),
                  DropdownMenuItem(value: 'helper', child: Text('Helper')),
                  DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
                ],
                onChanged: (v) {
                  if (v != null) _assignedRole = v;
                },
              ),
              const SizedBox(height: 32),

              // ── Save ──
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Assign Professional'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
