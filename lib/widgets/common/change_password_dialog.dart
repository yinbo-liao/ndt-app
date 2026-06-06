import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_client.dart';

/// Dialog for changing the current user's password.
class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPw = TextEditingController();
  final _newPw = TextEditingController();
  final _confirmPw = TextEditingController();
  final bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentPw.dispose();
    _newPw.dispose();
    _confirmPw.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final client = SupabaseClientWrapper.instance;
      // Re-authenticate first, then update password
      final user = client.auth.currentUser;
      if (user?.email == null) throw Exception('No email found');

      await client.auth.signInWithPassword(
        email: user!.email!,
        password: _currentPw.text,
      );

      await client.auth.updateUser(
        UserAttributes(password: _newPw.text),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: Color(0xFF1A56DB)),
          SizedBox(width: 8),
          Text('Change Password'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPw,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPw,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_open),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPw,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_open),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != _newPw.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Change Password'),
        ),
      ],
    );
  }
}
