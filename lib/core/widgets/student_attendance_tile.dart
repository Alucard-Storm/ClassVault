import 'package:flutter/material.dart';
import '../theme/app_color_scheme.dart';
import '../theme/app_tokens.dart';

/// A single present/absent roster row. One interaction model (tap anywhere
/// on the row, or the checkbox, both toggle the same state) used on both
/// mobile and desktop — previously `mark_attendance_screen` used a
/// `Checkbox` on mobile but a tap-only icon toggle on desktop, a real UX
/// inconsistency for the same action on the same screen.
class StudentAttendanceTile extends StatelessWidget {
  final String name;
  final String rollNumber;
  final bool isPresent;
  final ValueChanged<bool> onChanged;

  const StudentAttendanceTile({
    super.key,
    required this.name,
    required this.rollNumber,
    required this.isPresent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isPresent ? theme.appColors.success : theme.appColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isPresent
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.appColors.dangerContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: () => onChanged(!isPresent),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withValues(alpha: 0.15),
                foregroundColor: statusColor,
                child: Text(
                  rollNumber.isNotEmpty ? rollNumber[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isPresent
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Roll No: $rollNumber',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: isPresent,
                activeColor: theme.appColors.success,
                onChanged: (value) => onChanged(value ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
