import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/company_model.dart';
import '../../data/repositories/company_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../widgets/forms/text_input_field.dart';
import '../../widgets/forms/dropdown_field.dart';
import 'user_controller.dart';

/// Form page for creating/editing users (admin only).
class UserFormPage extends ConsumerStatefulWidget {
  final String? userId; // null = create, non-null = edit

  const UserFormPage({super.key, this.userId});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  String _role = 'ndt_team';
  String? _selectedCompanyId;
  List<CompanyModel> _companies = [];
  bool _isSaving = false;

  bool get _isEditing => widget.userId != null;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    try {
      final repo = CompanyRepository();
      final companies = await repo.getAll();
      if (mounted) setState(() => _companies = companies);
    } catch (_) {}
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_role != 'admin' && _selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a company')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        final userRepo = ref.read(userRepoProvider);
        // Fetch existing and update role + company
        final existing =
            await userRepo.getById(widget.userId!);
        if (existing != null) {
          await userRepo.update(existing.copyWith(
            role: _role,
            ndtCompanyId: _selectedCompanyId,
            phone: _phoneController.text.trim().nullIfEmpty,
            employeeId:
                _employeeIdController.text.trim().nullIfEmpty,
          ));
        }
      } else {
        final authRepo = AuthRepository();
        await authRepo.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          role: _role,
          ndtCompanyId: _selectedCompanyId,
        );
      }

      if (mounted) {
        ref.invalidate(usersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'User updated'
                : 'User created — they can now sign in'),
          ),
        );
        if (context.canPop()) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        title: Text(_isEditing ? 'Edit User' : 'Create User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextInputField(
                label: 'Full Name',
                controller: _fullNameController,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Full name is required'
                        : null,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: _isEditing,
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Email is required'
                        : null,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: _isEditing
                    ? 'New Password (leave blank to keep)'
                    : 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: _isEditing
                    ? null
                    : (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Password is required'
                            : null,
              ),
              const SizedBox(height: 16),
              DropdownField<String>(
                label: 'Role',
                value: _role,
                items: const [
                  DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrator')),
                  DropdownMenuItem(
                      value: 'ndt_company',
                      child: Text('NDT Company')),
                  DropdownMenuItem(
                      value: 'ndt_team',
                      child: Text('NDT Team')),
                ],
                onChanged: (v) {
                  if (v != null) _role = v;
                },
              ),
              if (_role != 'admin') ...[
                const SizedBox(height: 16),
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
              ],
              const SizedBox(height: 16),
              TextInputField(
                label: 'Phone (optional)',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Employee ID (optional)',
                controller: _employeeIdController,
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
                        ? 'Update User'
                        : 'Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String? {
  String? get nullIfEmpty =>
      this == null || this!.trim().isEmpty ? null : this;
}
