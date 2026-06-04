import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/company_model.dart';
import '../../widgets/forms/text_input_field.dart';
import 'company_controller.dart';

/// Form page for creating/editing an NDT Company.
class CompanyFormPage extends ConsumerStatefulWidget {
  final CompanyModel? existing;
  const CompanyFormPage({super.key, this.existing});

  @override
  ConsumerState<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends ConsumerState<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _registrationNo;
  String? _contactEmail;
  String? _contactPhone;
  String? _address;
  String? _supervisor;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = e?.name ?? '';
    _registrationNo = e?.registrationNo;
    _contactEmail = e?.contactEmail;
    _contactPhone = e?.contactPhone;
    _address = e?.address;
    _supervisor = e?.supervisor;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(companyRepoProvider);
      final company = CompanyModel(
        id: _isEditing ? widget.existing!.id : '',
        name: _name,
        registrationNo: _registrationNo,
        contactEmail: _contactEmail,
        contactPhone: _contactPhone,
        address: _address?.trim(),
        supervisor: _supervisor?.trim(),
      );

      if (_isEditing) {
        await repo.update(company);
      } else {
        await repo.create(company);
      }

      if (mounted) {
        ref.invalidate(allCompaniesProvider);
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Company' : 'Add Company')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextInputField(
                label: 'Company Name',
                initialValue: _name,
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                onChanged: (v) => _name = v,
              ),
              const SizedBox(height: 16),
              TextInputField(label: 'Registration No (optional)', initialValue: _registrationNo, onChanged: (v) => _registrationNo = v),
              const SizedBox(height: 16),
              TextInputField(label: 'Contact Email (optional)', initialValue: _contactEmail, keyboardType: TextInputType.emailAddress, onChanged: (v) => _contactEmail = v),
              const SizedBox(height: 16),
              TextInputField(label: 'Contact Phone (optional)', initialValue: _contactPhone, keyboardType: TextInputType.phone, onChanged: (v) => _contactPhone = v),
              const SizedBox(height: 16),
              TextInputField(label: 'Address (optional)', initialValue: _address, maxLines: 2, onChanged: (v) => _address = v),
              const SizedBox(height: 16),
              TextInputField(label: 'Supervisor (optional)', initialValue: _supervisor, onChanged: (v) => _supervisor = v),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isEditing ? 'Update' : 'Create Company'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
