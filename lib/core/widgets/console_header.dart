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
    return LayoutBuilder(builder: (context, constraints) {
      // On narrow screens the action button moves under the title so long
      // labels never squeeze the title or overflow.
      final narrow = constraints.maxWidth < 600 && onAction != null && actionLabel != null;
      if (!narrow) return _row(context, includeAction: true);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(context, includeAction: false),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.add_rounded, size: 18),
            label: Text(actionLabel!),
          ),
        ],
      );
    });
  }

  Widget _row(BuildContext context, {required bool includeAction}) {
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
        if (includeAction && onAction != null && actionLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton.icon(
            // The theme's full-width minimum size is infinite inside this Row.
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.add_rounded, size: 18),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}
