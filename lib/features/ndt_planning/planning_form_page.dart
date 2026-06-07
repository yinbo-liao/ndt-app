import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/models/planning_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/joint_detail.dart';
import '../../data/repositories/project_repository.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../companies/company_controller.dart';
import 'planning_controller.dart';

/// Form page for creating/editing an NDT RFI entry.
///
/// Structured as a multi-section form matching standard structural NDT RFI format:
///   1. RFI Header — project, company, RFI number, date
///   2. Reference Information — drawings, ISO, system, material, specs
///   3. NDT Scope — method, coverage, surface condition
///   4. Joint Details — dynamic table of joints/welds
///   5. Schedule — dates, priority, dispatch flag
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

  // ── Header ──────────────────────────────────────────────
  String _rfiNumber = '';
  DateTime? _rfiDate;
  String? _selectedProjectId;
  String? _selectedCompanyId;

  // ── Reference ───────────────────────────────────────────
  String _drawingRef = '';
  String _isoLineNo = '';
  String _systemName = '';
  String _materialGrade = '';
  String _ndtSpecification = '';
  String _acceptanceStandard = '';

  // ── NDT Scope ───────────────────────────────────────────
  String _ndtMethod = '';
  String _ndtCoveragePct = '';
  String _surfaceCondition = '';
  String _jobLocation = '';

  // ── Joint Details ───────────────────────────────────────
  final List<JointDetail> _joints = [];

  // ── Schedule ────────────────────────────────────────────
  String _task = '';
  DateTime? _plannedStartDate;
  DateTime? _plannedEndDate;
  String _priority = 'normal';
  bool _rfiSentToTeam = false;

  // ── State ───────────────────────────────────────────────
  bool _isSaving = false;
  List<CompanyModel> _companies = [];
  List<ProjectModel> _projects = [];

  bool get _isEditing => widget.existing != null;
  bool get _needsProjectSelection =>
      widget.projectId.isEmpty && !_isEditing;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _rfiDate = e.ndtRfiDate;
      _selectedProjectId = e.projectId;
      _selectedCompanyId = e.ndtCompanyId;
      _drawingRef = e.drawingRef ?? '';
      _isoLineNo = e.isoLineNo ?? '';
      _systemName = e.systemName ?? '';
      _materialGrade = e.materialGrade ?? '';
      _ndtSpecification = e.ndtSpecification ?? '';
      _acceptanceStandard = e.acceptanceStandard ?? '';
      _ndtMethod = e.typeOfTesting ?? '';
      _ndtCoveragePct = e.ndtCoveragePct?.toString() ?? '';
      _surfaceCondition = e.surfaceCondition ?? '';
      _jobLocation = e.jobLocation ?? '';
      _task = e.ndtCompanyTask;
      _plannedStartDate = e.plannedStartDate;
      _plannedEndDate = e.plannedEndDate;
      _priority = e.priority;
      _rfiSentToTeam = e.rfiSentToTeam;
      if (e.jointDetails.isNotEmpty) {
        _joints.addAll(e.jointDetails.map((j) => j.copyWith()));
      }
    } else {
      _selectedProjectId =
          widget.projectId.isNotEmpty ? widget.projectId : null;
      _generateRfiNumber();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompanies();
      if (_needsProjectSelection) _loadProjects();
    });
  }

  void _generateRfiNumber() {
    final now = DateTime.now();
    _rfiNumber =
        'RFI-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecond.toString().padLeft(3, '0')}';
  }

  Future<void> _loadCompanies() async {
    if (_companies.isNotEmpty) return;
    try {
      final repo = ref.read(companyRepoProvider);
      final companies = await repo.getAll(activeOnly: false);
      if (mounted) setState(() => _companies = companies);
    } catch (_) {}
  }

  Future<void> _loadProjects() async {
    if (_projects.isNotEmpty) return;
    try {
      final repo = ProjectRepository();
      final projects = await repo.getAll();
      if (mounted) setState(() => _projects = projects);
    } catch (_) {}
  }

  // ── Joint management ────────────────────────────────────

  void _removeJoint(int index) {
    setState(() => _joints.removeAt(index));
  }

  void _showJointDialog({JointDetail? existing, int? index}) {
    final isNew = existing == null;
    final ctrl = _JointEditController.fromJoint(existing);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'Add Joint' : 'Edit Joint'),
        content: _JointEditForm(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final joint = ctrl.toJoint();
              if (joint == null) return;
              setState(() {
                if (isNew) {
                  _joints.add(joint);
                } else {
                  _joints[index!] = joint;
                }
              });
              Navigator.pop(ctx);
            },
            child: Text(isNew ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  // ── Save ────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedCompanyId == null) {
      _showSnack('Please select an NDT company');
      return;
    }
    final effectiveProjectId = _selectedProjectId ?? widget.projectId;
    if (effectiveProjectId.isEmpty) {
      _showSnack('Please select a project');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(planningRepositoryProvider);

      final planning = PlanningModel(
        id: _isEditing ? widget.existing!.id : '',
        projectId: effectiveProjectId,
        ndtCompanyId: _selectedCompanyId!,
        ndtRfiDate: _rfiDate,
        ndtCompanyTask: _task.isNotEmpty ? _task : 'Structural NDT Inspection',
        plannedStartDate: _plannedStartDate,
        plannedEndDate: _plannedEndDate,
        priority: _priority,
        typeOfTesting: _ndtMethod.isNotEmpty ? _ndtMethod : null,
        jobLocation: _jobLocation.isNotEmpty ? _jobLocation : null,
        rfiSentToTeam: _rfiSentToTeam,
        drawingRef: _drawingRef.isNotEmpty ? _drawingRef : null,
        isoLineNo: _isoLineNo.isNotEmpty ? _isoLineNo : null,
        systemName: _systemName.isNotEmpty ? _systemName : null,
        materialGrade: _materialGrade.isNotEmpty ? _materialGrade : null,
        ndtSpecification: _ndtSpecification.isNotEmpty ? _ndtSpecification : null,
        acceptanceStandard: _acceptanceStandard.isNotEmpty ? _acceptanceStandard : null,
        ndtCoveragePct: double.tryParse(_ndtCoveragePct),
        surfaceCondition: _surfaceCondition.isNotEmpty ? _surfaceCondition : null,
        jointDetails: List.from(_joints),
      );

      if (_isEditing) {
        await repository.update(planning);
      } else {
        await _createWithFallback(repository, planning);
      }

      if (mounted) {
        ref.invalidate(planningByProjectDtoProvider(effectiveProjectId));
        ref.invalidate(planningByProjectProvider(effectiveProjectId));
        ref.invalidate(planningByCompanyProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Failed to save NDT RFI. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Try to create the planning entry. If the DB doesn't have the new
  /// structural RFI columns yet (migration 007 not applied), retry without them.
  Future<void> _createWithFallback(
    dynamic repository,
    PlanningModel planning,
  ) async {
    final hasNewFields = planning.drawingRef != null ||
        planning.isoLineNo != null ||
        planning.systemName != null ||
        planning.materialGrade != null ||
        planning.ndtSpecification != null ||
        planning.acceptanceStandard != null ||
        planning.ndtCoveragePct != null ||
        planning.surfaceCondition != null ||
        planning.jointDetails.isNotEmpty;

    try {
      await repository.create(planning);
    } catch (firstError) {
      if (!hasNewFields) rethrow;

      // Check if the error looks like a missing-column issue.
      final errMsg = firstError.toString().toLowerCase();
      final isColumnError = errMsg.contains('column') ||
          errMsg.contains('does not exist') ||
          errMsg.contains('42703'); // PostgreSQL undefined_column
      if (!isColumnError) rethrow;

      try {
        final fallback = planning.copyWith(
          drawingRef: null,
          isoLineNo: null,
          systemName: null,
          materialGrade: null,
          ndtSpecification: null,
          acceptanceStandard: null,
          ndtCoveragePct: null,
          surfaceCondition: null,
          jointDetails: const [],
        );
        await repository.create(fallback);
      } catch (_) {
        rethrow;
      }
    }
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit NDT RFI' : 'New NDT RFI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildReferenceCard(),
              const SizedBox(height: 16),
              _buildScopeCard(),
              const SizedBox(height: 16),
              _buildJointDetailsCard(),
              const SizedBox(height: 16),
              _buildScheduleCard(),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditing ? 'Update RFI' : 'Create RFI'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Cards ───────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1A56DB)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF1A56DB),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('1. RFI Header', Icons.description),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'RFI Number',
                    initialValue: _rfiNumber,
                    onChanged: (v) => _rfiNumber = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    label: 'RFI Date',
                    value: _rfiDate,
                    onChanged: (d) => _rfiDate = d,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_needsProjectSelection) ...[
              DropdownField<String>(
                label: 'Project',
                value: _selectedProjectId,
                hintText: 'Select a project',
                items: _projects
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.projectName),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _selectedProjectId = v;
                },
              ),
              const SizedBox(height: 12),
            ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('2. Reference Information', Icons.folder),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'Drawing Reference',
                    initialValue: _drawingRef,
                    onChanged: (v) => _drawingRef = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextInputField(
                    label: 'ISO / Line No',
                    initialValue: _isoLineNo,
                    onChanged: (v) => _isoLineNo = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'System / Sub-system',
                    initialValue: _systemName,
                    onChanged: (v) => _systemName = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextInputField(
                    label: 'Material Grade',
                    initialValue: _materialGrade,
                    onChanged: (v) => _materialGrade = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'NDT Specification',
                    initialValue: _ndtSpecification,
                    onChanged: (v) => _ndtSpecification = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextInputField(
                    label: 'Acceptance Standard',
                    initialValue: _acceptanceStandard,
                    onChanged: (v) => _acceptanceStandard = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('3. NDT Scope', Icons.science),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'NDT Method (e.g. UT, MT, PT, RT, VT)',
                    initialValue: _ndtMethod,
                    onChanged: (v) => _ndtMethod = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextInputField(
                    label: 'Coverage %',
                    initialValue: _ndtCoveragePct,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _ndtCoveragePct = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextInputField(
                    label: 'Surface Condition',
                    initialValue: _surfaceCondition,
                    onChanged: (v) => _surfaceCondition = v,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextInputField(
                    label: 'Job Location',
                    initialValue: _jobLocation,
                    onChanged: (v) => _jobLocation = v,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJointDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('4. Joint / Weld Details', Icons.join_full),
            const Divider(),
            if (_joints.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No joints added yet. Tap + to add.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ...List.generate(_joints.length, (i) {
                final j = _joints[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  elevation: 1,
                  child: ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFF1A56DB).withAlpha(20),
                      radius: 18,
                      child: Text(j.jointNo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    title: Text(
                      '${j.jointTypeLabel} — ${j.size}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${j.ndtMethod} @ ${j.extent}${j.remarks.isNotEmpty ? ' · ${j.remarks}' : ''}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          tooltip: 'Edit joint',
                          onPressed: () => _showJointDialog(
                              existing: j, index: i),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              size: 18, color: Colors.red[400]),
                          tooltip: 'Remove joint',
                          onPressed: () => _removeJoint(i),
                        ),
                      ],
                    ),
                    onTap: () =>
                        _showJointDialog(existing: j, index: i),
                  ),
                );
              }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showJointDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Joint'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('5. Schedule', Icons.calendar_month),
            const Divider(),
            TextInputField(
              label: 'NDT Task Description',
              initialValue: _task,
              maxLines: 2,
              onChanged: (v) => _task = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DatePickerField(
                    label: 'Planned Start',
                    value: _plannedStartDate,
                    onChanged: (d) => _plannedStartDate = d,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    label: 'Planned End',
                    value: _plannedEndDate,
                    firstDate: _plannedStartDate,
                    onChanged: (d) => _plannedEndDate = d,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 4),
            CheckboxListTile(
              title: const Text('RFI dispatched to team'),
              subtitle: const Text(
                  'Mark when the NDT contractor has sent the RFI'),
              value: _rfiSentToTeam,
              onChanged: (v) =>
                  setState(() => _rfiSentToTeam = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Joint Edit Dialog Controller & Form
// ─────────────────────────────────────────────────────────────

class _JointEditController {
  String jointNo;
  String jointType;
  String size;
  String ndtMethod;
  String extent;
  String remarks;

  _JointEditController({
    this.jointNo = '',
    this.jointType = 'butt',
    this.size = '',
    this.ndtMethod = 'UT',
    this.extent = '100%',
    this.remarks = '',
  });

  factory _JointEditController.fromJoint(JointDetail? joint) {
    if (joint == null) return _JointEditController();
    return _JointEditController(
      jointNo: joint.jointNo,
      jointType: joint.jointType,
      size: joint.size,
      ndtMethod: joint.ndtMethod,
      extent: joint.extent,
      remarks: joint.remarks,
    );
  }

  JointDetail? toJoint() {
    if (jointNo.isEmpty || size.isEmpty) return null;
    return JointDetail(
      jointNo: jointNo,
      jointType: jointType,
      size: size,
      ndtMethod: ndtMethod,
      extent: extent,
      remarks: remarks,
    );
  }
}

class _JointEditForm extends StatefulWidget {
  final _JointEditController controller;
  const _JointEditForm({required this.controller});

  @override
  State<_JointEditForm> createState() => _JointEditFormState();
}

class _JointEditFormState extends State<_JointEditForm> {
  _JointEditController get c => widget.controller;

  static const _jointTypes = [
    'butt',
    'fillet',
    'lap',
    'corner',
    'edge',
    'tee',
    'other',
  ];
  static const _ndtMethods = ['UT', 'MT', 'PT', 'RT', 'VT'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextInputField(
                  label: 'Joint / Weld No',
                  initialValue: c.jointNo,
                  onChanged: (v) => c.jointNo = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownField<String>(
                  label: 'Type',
                  value: c.jointType,
                  items: _jointTypes
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t[0].toUpperCase() + t.substring(1)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) c.jointType = v;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextInputField(
            label: 'Size / Diameter',
            initialValue: c.size,
            onChanged: (v) => c.size = v,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownField<String>(
                  label: 'NDT Method',
                  value: c.ndtMethod,
                  items: _ndtMethods
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) c.ndtMethod = v;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextInputField(
                  label: 'Extent',
                  initialValue: c.extent,
                  onChanged: (v) => c.extent = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextInputField(
            label: 'Remarks / Location',
            initialValue: c.remarks,
            onChanged: (v) => c.remarks = v,
          ),
        ],
      ),
    );
  }
}
