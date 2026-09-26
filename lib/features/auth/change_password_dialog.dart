import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/providers.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/utils/validators.dart';

/// Opens the change-password form for the signed-in user.
Future<void> showChangePasswordDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _ChangePasswordDialog(),
  );
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.success(context, 'Password changed successfully.');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Change Password',
      icon: Icons.key_rounded,
      confirmLabel: _saving ? 'Saving...' : 'Change Password',
      onConfirm: _save,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentController,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
              validator: (v) => Validators.required(v, label: 'Current password'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'New password is required';
                if (v.length < 8) return 'Use at least 8 characters';
                if (v == _currentController.text) return 'Must differ from the current password';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              validator: (v) => v != _newController.text ? 'Passwords do not match' : null,
              onFieldSubmitted: (_) => _save(),
            ),
          ],
        ),
      ),
    );
  }
}
