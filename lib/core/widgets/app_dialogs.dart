import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../theme/app_tokens.dart';

/// Properly shaped/elevated dialog shell (continuous corners, consistent
/// padding, themed actions) wrapping a `Form`. Replaces the bare default
/// `AlertDialog` used for every add/edit form across the admin screens.
///
/// The caller owns the `Form`/`GlobalKey<FormState>` and field widgets;
/// this just gives every dialog the same chrome and Cancel/Confirm footer.
class AppFormDialog extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const AppFormDialog({
    super.key,
    required this.title,
    this.icon,
    required this.child,
    this.confirmLabel = 'Save',
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              child,
              const SizedBox(height: AppSpacing.xl),
              // Wrap so long labels drop to a new line on narrow screens.
              Wrap(
                alignment: WrapAlignment.end,
                runSpacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    // The theme makes filled buttons full-width (Size.fromHeight),
                    // which is infinite inside this Row; size to content here.
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(88, 44),
                      backgroundColor: isDestructive ? theme.appColors.danger : null,
                    ),
                    onPressed: onConfirm,
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Themed confirm/destructive-action dialog. Replaces bare `AlertDialog`
/// confirmations (e.g. "Promote students?", "Save attendance?").
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final bool isDestructive;
  final IconData? icon;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.isDestructive = false,
    this.icon,
  });

  /// Shows the dialog and resolves to `true` if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AppConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isDestructive ? theme.appColors.danger : theme.colorScheme.primary;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? (isDestructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded),
                  color: accent,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Text(message,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xl),
              // Wrap so long labels drop to a new line on narrow screens.
              Wrap(
                alignment: WrapAlignment.end,
                runSpacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    // The theme makes filled buttons full-width (Size.fromHeight),
                    // which is infinite inside this Row; size to content here.
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(88, 44),
                      backgroundColor: isDestructive ? theme.appColors.danger : null,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
