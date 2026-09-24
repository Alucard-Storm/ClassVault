import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../theme/app_tokens.dart';

/// Thin SnackBar wrapper that always sources its color from
/// [AppColorScheme] instead of raw hex, so success/error/warning feedback
/// stays consistent (and theme-correct in dark mode) everywhere it's shown.
class AppSnackBar {
  const AppSnackBar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, Theme.of(context).appColors.success, Icons.check_circle_rounded);

  static void error(BuildContext context, String message) =>
      _show(context, message, Theme.of(context).appColors.danger, Icons.error_rounded);

  static void warning(BuildContext context, String message) => _show(
      context, message, Theme.of(context).appColors.warning, Icons.warning_amber_rounded);

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
  }
}
