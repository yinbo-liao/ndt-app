import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/company_model.dart';
import '../../data/models/professional_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/dropdown_field.dart';
import '../companies/company_controller.dart';
import 'professional_controller.dart';

/// Form page for creating/editing an NDT Professional Register entry.
class ProfessionalFormPage extends ConsumerStatefulWidget {
  final ProfessionalModel? existing;

  const ProfessionalFormPage({super.key, this.existing});

  @override
  ConsumerState<ProfessionalFormPage> createState() =>
      _ProfessionalFormPageState();
}

class _ProfessionalFormPageState
    extends ConsumerState<ProfessionalFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _typeOfCertificate;
  String? _certifiedBy;
  DateTime? _issuedDate;
  DateTime? _expiryDate;
  String _workingSector = AppConstants.sectorIndustry;
  String? _selectedCompanyId;
  List<CompanyModel> _companies = [];
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = e?.name ?? '';
    _typeOfCertificate = e?.typeOfCertificate ?? AppConstants.testingUT;
    _certifiedBy = e?.certifiedBy;
    _issuedDate = e?.issuedDate;
    _expiryDate = e?.expiryDate;
    _workingSector = e?.workingSector ?? AppConstants.sectorIndustry;
    _selectedCompanyId = e?.ndtCompanyId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // For non-admin users creating a new entry, auto-set company from JWT.
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
      final repo = ref.read(companyRepoProvider);
      final companies = await repo.getAll(activeOnly: false);
      if (mounted) setState(() => _companies = companies);
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_issuedDate == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both issue and expiry dates'),
        ),
      );
      return;
    }

    if (_selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an NDT company'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(professionalRepoProvider);
      final currentUser = ref.read(currentUserProvider);

      final professional = ProfessionalModel(
        id: _isEditing ? widget.existing!.id : '',
        name: _name.trim(),
        typeOfCertificate: _typeOfCertificate,
        certifiedBy: _certifiedBy?.trim(),
        issuedDate: _issuedDate!,
        expiryDate: _expiryDate!,
        certificateStatus:
            _computeValidationStatus(_expiryDate!),
        workingSector: _workingSector,
        ndtCompanyId: _selectedCompanyId,
        createdBy: currentUser?.id,
      );

      if (_isEditing) {
        await repository.update(professional);
      } else {
        await repository.create(professional);
      }

      if (mounted) {
        ref.invalidate(professionalsProvider);
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save professional. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _computeValidationStatus(DateTime expiryDate) {
    final today = DateTime.now();
    final startOfToday =
        DateTime(today.year, today.month, today.day);
    final expireDay = DateTime(
        expiryDate.year, expiryDate.month, expiryDate.day);
    if (expireDay.isBefore(startOfToday)) return 'expired';
    return 'valid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? 'Edit Professional'
            : 'Add Professional'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextInputField(
                label: 'Full Name',
                initialValue: _name,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Name is required'
                    : null,
                onChanged: (v) => _name = v,
              ),
              const SizedBox(height: 16),

              // Type of Certificate
              DropdownField<String>(
                label: 'Type of Certificate',
                value: _typeOfCertificate,
                items: AppConstants.testingTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _typeOfCertificate = v;
                },
              ),
              const SizedBox(height: 16),

              // Certified By
              TextInputField(
                label: 'Certified By (optional)',
                initialValue: _certifiedBy,
                onChanged: (v) => _certifiedBy = v,
              ),
              const SizedBox(height: 16),

              // Issue Date
              DatePickerField(
                label: 'Issue Date',
                value: _issuedDate,
                onChanged: (d) => _issuedDate = d,
              ),
              const SizedBox(height: 16),

              // Expiry Date
              DatePickerField(
                label: 'Expiry Date',
                value: _expiryDate,
                firstDate: _issuedDate ?? DateTime.now(),
                onChanged: (d) => _expiryDate = d,
              ),
              const SizedBox(height: 16),

              // Working Sector
              DropdownField<String>(
                label: 'Working Sector',
                value: _workingSector,
                items: [
                  const DropdownMenuItem(
                    value: AppConstants.sectorMarine,
                    child: Text('Marine Section'),
                  ),
                  const DropdownMenuItem(
                    value: AppConstants.sectorIndustry,
                    child: Text('Industry Section'),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) _workingSector = v;
                },
              ),
              const SizedBox(height: 16),

              // NDT Company
              DropdownField<String>(
                label: 'NDT Company',
                value: _selectedCompanyId,
                hintText: 'Select company',
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
                    : Text(_isEditing ? 'Update' : 'Save Professional'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
