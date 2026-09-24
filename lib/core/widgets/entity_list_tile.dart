import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// A single "entity row" (avatar/icon + title + subtitle + trailing) with
/// one visual treatment shared by mobile and desktop, instead of the
/// tinted-`Material` desktop row and `Card`+`ListTile` mobile row that used
/// to be reimplemented independently per screen.
class EntityListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? leadingText;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  const EntityListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingText,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(AppRadius.control),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.control),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            foregroundColor: theme.colorScheme.primary,
            child: leadingIcon != null
                ? Icon(leadingIcon, size: 20)
                : Text(
                    (leadingText?.isNotEmpty ?? false) ? leadingText![0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.w600),
          ),
          subtitle: subtitle != null
              ? Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: trailing,
        ),
      ),
    );
  }
}
