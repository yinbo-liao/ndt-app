import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/contractor_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/forms/date_picker_field.dart';
import '../../widgets/forms/text_input_field.dart';
import 'contractor_controller.dart';

/// Form page for creating/editing a contractor register entry.
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
  bool _isSaving = false;

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
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

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
      final companyId = ref.read(currentUserCompanyIdProvider);
      final currentUser = ref.read(currentUserProvider);

      final contractor = ContractorModel(
        id: _isEditing ? widget.existing!.id : '',
        ndtCompanyId: companyId ?? '',
        typeOfNdt: _typeOfNdt,
        typeOfNdtCertificate: _typeOfNdtCertificate,
        certificateNo: _certificateNo,
        certificateType: _certificateType,
        issueDate: _issueDate!,
        expireDate: _expireDate!,
        validationStatus: _computeValidationStatus(_expireDate!),
        reportMonth:
            DateTime(_expireDate!.year, _expireDate!.month, 1),
        createdBy: currentUser?.id,
      );

      if (_isEditing) {
        await repository.update(contractor);
      } else {
        await repository.create(contractor);
      }

      if (mounted) {
        ref.invalidate(contractorsProvider);
        ref.invalidate(contractorsByMonthProvider);
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

  /// Auto-compute validation status based on expire date.
  String _computeValidationStatus(DateTime expireDate) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final expireDay = DateTime(expireDate.year, expireDate.month, expireDate.day);
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
                label: 'Certificate Type (optional)',
                initialValue: _certificateType,
                onChanged: (v) => _certificateType = v,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
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
