import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Title + subtitle + optional refresh + optional primary action, used at
/// the top of every admin "console" screen. Replaces the near-identical
/// header block each console screen used to hand-roll independently.
class ConsoleHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRefresh;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const ConsoleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onRefresh,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onRefresh != null) ...[
          const SizedBox(width: AppSpacing.sm),
          IconButton.filledTonal(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: onRefresh,
          ),
        ],
        if (onAction != null && actionLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.add_rounded, size: 18),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}
