import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/models/planning_model.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../companies/company_controller.dart';
import 'planning_controller.dart';

/// Form page for creating/editing an NDT planning (RFI) entry.
class PlanningFormPage extends ConsumerStatefulWidget {
  final PlanningModel? existing;
  final String projectId;

  const PlanningFormPage({
    super.key,
    this.existing,
    required this.projectId,
  });

  @override
  ConsumerState<PlanningFormPage> createState() =>
      _PlanningFormPageState();
}

class _PlanningFormPageState extends ConsumerState<PlanningFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _task = '';
  DateTime? _plannedStartDate;
  DateTime? _plannedEndDate;
  String _priority = 'normal';
  String? _selectedCompanyId;
  DateTime? _rfiDate;
  bool _isSaving = false;
  List<CompanyModel> _companies = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _task = e.ndtCompanyTask;
      _plannedStartDate = e.plannedStartDate;
      _plannedEndDate = e.plannedEndDate;
      _priority = e.priority;
      _selectedCompanyId = e.ndtCompanyId;
      _rfiDate = e.ndtRfiDate;
    }
    // Load companies after first frame to avoid build-during-init issues.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanies();
    });
  }

  void _loadCompanies() {
    if (_companies.isNotEmpty) return;
    final companiesAsync = ref.read(allCompaniesProvider);
    companiesAsync.whenData((companies) {
      if (mounted) {
        setState(() => _companies = companies);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an NDT company')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(planningRepositoryProvider);

      final planning = PlanningModel(
        id: _isEditing ? widget.existing!.id : '',
        projectId: widget.projectId,
        ndtCompanyId: _selectedCompanyId!,
        ndtRfiDate: _rfiDate,
        ndtCompanyTask: _task,
        plannedStartDate: _plannedStartDate,
        plannedEndDate: _plannedEndDate,
        priority: _priority,
      );

      if (_isEditing) {
        await repository.update(planning);
      } else {
        await repository.create(planning);
      }

      if (mounted) {
        ref.invalidate(planningByProjectProvider(widget.projectId));
        ref.invalidate(planningByCompanyProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save NDT RFI. Please try again.'),
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
        title: Text(_isEditing ? 'Edit NDT RFI' : 'Add NDT RFI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── NDT Company ──────────────────────────────
              DropdownField<String>(
                label: 'NDT Company',
                value: _selectedCompanyId,
                hintText: 'Select a company',
                items: _companies
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _selectedCompanyId = v;
                },
              ),
              const SizedBox(height: 16),

              // ── NDT Task ─────────────────────────────────
              TextInputField(
                label: 'NDT Task Description',
                initialValue: _task,
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Task description is required'
                        : null,
                onChanged: (v) => _task = v,
              ),
              const SizedBox(height: 16),

              // ── RFI Date ─────────────────────────────────
              DatePickerField(
                label: 'NDT RFI Date',
                value: _rfiDate,
                onChanged: (d) => _rfiDate = d,
              ),
              const SizedBox(height: 16),

              // ── Dates ────────────────────────────────────
              DatePickerField(
                label: 'Planned Start Date',
                value: _plannedStartDate,
                onChanged: (d) => _plannedStartDate = d,
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Planned End Date',
                value: _plannedEndDate,
                firstDate: _plannedStartDate,
                onChanged: (d) => _plannedEndDate = d,
              ),
              const SizedBox(height: 16),

              // ── Priority ─────────────────────────────────
              DropdownField<String>(
                label: 'Priority',
                value: _priority,
                items: const [
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                ],
                onChanged: (v) {
                  if (v != null) _priority = v;
                },
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
                    : Text(_isEditing ? 'Update RFI' : 'Create RFI'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
