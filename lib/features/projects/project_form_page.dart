import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/project_model.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/date_picker_field.dart';
import 'project_controller.dart';

/// Form page for creating/editing a project.
class ProjectFormPage extends ConsumerStatefulWidget {
  final ProjectModel? existing;

  const ProjectFormPage({super.key, this.existing});

  @override
  ConsumerState<ProjectFormPage> createState() =>
      _ProjectFormPageState();
}

class _ProjectFormPageState extends ConsumerState<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _projectName;
  late String _projectCode;
  late String _location;
  String? _jobTrade;
  String? _clientName;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _active = true;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _projectName = e?.projectName ?? '';
    _projectCode = e?.projectCode ?? '';
    _location = e?.location ?? '';
    _jobTrade = e?.jobTrade;
    _clientName = e?.clientName;
    _startDate = e?.startDate;
    _endDate = e?.endDate;
    _active = e?.active ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(projectRepositoryProvider);

      final project = ProjectModel(
        id: _isEditing ? widget.existing!.id : '',
        projectName: _projectName,
        projectCode: _projectCode,
        location: _location,
        jobTrade: _jobTrade,
        clientName: _clientName,
        startDate: _startDate,
        endDate: _endDate,
        active: _active,
      );

      if (_isEditing) {
        await repository.update(project);
      } else {
        await repository.create(project);
      }

      if (mounted) {
        ref.invalidate(projectsProvider);
        ref.invalidate(projectDetailProvider);
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save project. Please try again.'),
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
        title: Text(_isEditing ? 'Edit Project' : 'New Project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextInputField(
                label: 'Project Name',
                initialValue: _projectName,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Project name is required'
                    : null,
                onChanged: (v) => _projectName = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Project Code',
                initialValue: _projectCode,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Project code is required'
                    : null,
                onChanged: (v) => _projectCode = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Location',
                initialValue: _location,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Location is required'
                    : null,
                onChanged: (v) => _location = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Job Trade (optional)',
                initialValue: _jobTrade,
                onChanged: (v) => _jobTrade = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Client Name (optional)',
                initialValue: _clientName,
                onChanged: (v) => _clientName = v,
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Start Date (optional)',
                value: _startDate,
                onChanged: (d) => _startDate = d,
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'End Date (optional)',
                value: _endDate,
                firstDate: _startDate,
                onChanged: (d) => _endDate = d,
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
                    : Text(_isEditing ? 'Update Project' : 'Create Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
