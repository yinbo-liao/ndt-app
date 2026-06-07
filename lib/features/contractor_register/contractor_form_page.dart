import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/models/contractor_model.dart';
import '../../data/repositories/company_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/dropdown_field.dart';
import 'contractor_controller.dart';

/// Form page for creating/editing a contractor register entry.
///
/// Each entry links a technician (by name) to an NDT company and
/// their certificate details.
class ContractorFormPage extends ConsumerStatefulWidget {
  final ContractorModel? existing; // null = create, non-null = edit

  const ContractorFormPage({super.key, this.existing});

  @override
  ConsumerState<ContractorFormPage> createState() =>
      _ContractorFormPageState();
}

class _ContractorFormPageState extends ConsumerState<ContractorFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _typeOfNdt;
  late String _typeOfNdtCertificate;
  late String _certificateNo;
  String? _certificateType;
  DateTime? _issueDate;
  DateTime? _expireDate;
  String? _selectedCompanyId;
  String _technicianName = '';
  String _techId = '';
  bool _isSaving = false;
  List<CompanyModel> _companies = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _typeOfNdt = e?.typeOfNdt ?? '';
    _typeOfNdtCertificate = e?.typeOfNdtCertificate ?? '';
    _certificateNo = e?.certificateNo ?? '';
    _certificateType = e?.certificateType;
    _issueDate = e?.issueDate;
    _expireDate = e?.expireDate;
    _selectedCompanyId = e?.ndtCompanyId;
    _technicianName = e?.technicianName ?? '';
    _techId = e?.techId ?? '';

    // For non-admin users creating a new entry, auto-set company from JWT.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isEditing && _selectedCompanyId == null) {
        final isAdmin = ref.read(isAdminProvider);
        if (!isAdmin) {
          final jwtCompanyId = ref.read(currentUserCompanyIdProvider);
          if (jwtCompanyId != null) {
            setState(() => _selectedCompanyId = jwtCompanyId);
          }
        }
      }
      _loadCompanies();
    });
  }

  Future<void> _loadCompanies() async {
    if (_companies.isNotEmpty) return;
    try {
      final repo = CompanyRepository();
      final companies = await repo.getAll(activeOnly: false);
      if (mounted) setState(() => _companies = companies);
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Fall back to JWT company for non-admin users.
    final effectiveCompanyId = _selectedCompanyId ??
        ref.read(currentUserCompanyIdProvider);
    if (effectiveCompanyId == null || effectiveCompanyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an NDT company')),
      );
      return;
    }

    if (_issueDate == null || _expireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both issue and expiry dates'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(contractorRepositoryProvider);
      final currentUser = ref.read(currentUserProvider);

      final contractor = ContractorModel(
        id: _isEditing ? widget.existing!.id : '',
        ndtCompanyId: effectiveCompanyId,
        typeOfNdt: _typeOfNdt,
        typeOfNdtCertificate: _typeOfNdtCertificate,
        certificateNo: _certificateNo,
        certificateType: _certificateType,
        issueDate: _issueDate!,
        expireDate: _expireDate!,
        validationStatus: _computeValidationStatus(_expireDate!),
        reportMonth:
            DateTime(_expireDate!.year, _expireDate!.month, 1),
        technicianName: _technicianName.isNotEmpty ? _technicianName : null,
        techId: _techId.isNotEmpty ? _techId : null,
        createdBy: currentUser?.id,
      );

      if (_isEditing) {
        await repository.update(contractor);
      } else {
        await _createWithFallback(repository, contractor);
      }

      if (mounted) {
        ref.invalidate(contractorsProvider);
        ref.invalidate(contractorsByMonthProvider);
        ref.invalidate(contractorsByMonthDtoProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save contractor. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Try to create the contractor. If the DB doesn't have the new
  /// columns yet (migration not applied), retry without them.
  Future<void> _createWithFallback(
    dynamic repository,
    ContractorModel contractor,
  ) async {
    try {
      await repository.create(contractor);
    } catch (firstError) {
      // Only retry if we have new fields that the DB might not support yet.
      final hasNewFields = contractor.technicianName != null ||
          contractor.techId != null ||
          contractor.ndtProfessionalId != null;
      if (!hasNewFields) rethrow;

      // Check if the error looks like a missing-column issue.
      final errMsg = firstError.toString().toLowerCase();
      final isColumnError = errMsg.contains('column') ||
          errMsg.contains('does not exist') ||
          errMsg.contains('42703'); // PostgreSQL undefined_column
      if (!isColumnError) rethrow;

      try {
        final fallback = contractor.copyWith(
          technicianName: null,
          techId: null,
          ndtProfessionalId: null,
        );
        await repository.create(fallback);
      } catch (_) {
        rethrow; // both attempts failed, throw original error
      }
    }
  }

  /// Auto-compute validation status based on expire date.
  String _computeValidationStatus(DateTime expireDate) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final expireDay =
        DateTime(expireDate.year, expireDate.month, expireDate.day);
    if (expireDay.isBefore(startOfToday)) {
      return 'expired';
    }
    return 'valid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Contractor' : 'Add Contractor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── NDT Company ──────────────────────────────
              Consumer(
                builder: (context, ref, _) {
                  final isAdmin = ref.watch(isAdminProvider);
                  if (isAdmin) {
                    return DropdownField<String>(
                      label: 'NDT Company',
                      value: _selectedCompanyId,
                      hintText: 'Select NDT company',
                      items: _companies
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _selectedCompanyId = v;
                      },
                    );
                  }
                  // Non-admin: show auto-assigned company
                  final companyName = _companies
                      .where((c) => c.id == _selectedCompanyId)
                      .map((c) => c.name)
                      .firstOrNull;
                  return TextFormField(
                    initialValue: companyName ?? 'Your Company',
                    readOnly: true,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'NDT Company',
                      prefixIcon:
                          Icon(Icons.business, color: Colors.grey),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    style: TextStyle(color: Colors.grey[700]),
                  );
                },
              ),
              const SizedBox(height: 16),

              // ── Technician Name ──────────────────────────
              TextInputField(
                label: 'Technician Name',
                initialValue: _technicianName,
                onChanged: (v) => _technicianName = v,
              ),
              const SizedBox(height: 16),

              TextInputField(
                label: 'Type of NDT',
                initialValue: _typeOfNdt,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Type of NDT is required'
                    : null,
                onChanged: (v) => _typeOfNdt = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Type of NDT Certificate',
                initialValue: _typeOfNdtCertificate,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Type of certificate is required'
                    : null,
                onChanged: (v) => _typeOfNdtCertificate = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Certificate Number',
                initialValue: _certificateNo,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Certificate number is required'
                    : null,
                onChanged: (v) => _certificateNo = v,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Certificate issued by',
                initialValue: _certificateType,
                onChanged: (v) => _certificateType = v,
              ),
              const SizedBox(height: 16),

              // ── Tech ID (4-digit) ────────────────────────
              TextInputField(
                label: 'Technician ID (4-character)',
                initialValue: _techId,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length != 4) {
                    return 'Technician ID must be exactly 4 characters';
                  }
                  return null;
                },
                onChanged: (v) => _techId = v,
              ),
              const SizedBox(height: 16),

              DatePickerField(
                label: 'Issue Date',
                value: _issueDate,
                onChanged: (d) => _issueDate = d,
              ),
              const SizedBox(height: 16),
              DatePickerField(
                label: 'Expiry Date',
                value: _expireDate,
                firstDate: _issueDate ?? DateTime.now(),
                onChanged: (d) => _expireDate = d,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
