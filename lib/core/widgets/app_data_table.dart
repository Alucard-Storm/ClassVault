import 'package:flutter/material.dart';
import 'empty_state.dart';
import '../theme/app_tokens.dart';

/// One row of data: desktop `cells` (one per column) plus the condensed
/// mobile-card fields. Both views are built from the same row, so mobile
/// and desktop are guaranteed to surface the same underlying data instead
/// of drifting (the original problem: e.g. a defaulters table showing
/// Roll/Name/Section/Attendance on desktop but different fields on mobile).
class AppDataRow {
  final List<Widget> cells;
  final String mobileTitle;
  final String? mobileSubtitle;
  final Widget? mobileTrailing;
  final IconData? mobileLeadingIcon;
  final String? mobileLeadingText;
  final VoidCallback? onTap;

  const AppDataRow({
    required this.cells,
    required this.mobileTitle,
    this.mobileSubtitle,
    this.mobileTrailing,
    this.mobileLeadingIcon,
    this.mobileLeadingText,
    this.onTap,
  });
}

/// One responsive table component: a real header+row table on desktop, a
/// card-list of the same rows on mobile. Replaces the 7 independent
/// hand-rolled `Table`/`TableRow` implementations across admin + reports
/// screens.
class AppDataTable extends StatelessWidget {
  final List<String> columns;
  final List<int>? columnFlex;
  final List<AppDataRow> rows;

  /// Whether to render the desktop table (true) or the mobile card list
  /// (false). Callers already compute this once per screen (the same
  /// `isDesktop` flag driving the rest of the layout) — passing it in here
  /// avoids a second, differently-thresholded breakpoint check nested
  /// inside content that's already narrower than the full window.
  final bool isDesktop;

  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptyMessage;

  const AppDataTable({
    super.key,
    required this.columns,
    this.columnFlex,
    required this.rows,
    required this.isDesktop,
    this.emptyIcon = Icons.inbox_rounded,
    required this.emptyTitle,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return EmptyState(icon: emptyIcon, title: emptyTitle, message: emptyMessage);
    }
    return isDesktop ? _buildTable(context) : _buildList(context);
  }

  List<int> get _flex => columnFlex ?? List.filled(columns.length, 1);

  Widget _buildTable(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              for (var i = 0; i < columns.length; i++)
                Expanded(
                  flex: _flex[i],
                  child: Text(
                    columns[i],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        for (final row in rows) ...[
          InkWell(
            onTap: row.onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              child: Row(
                children: [
                  for (var i = 0; i < row.cells.length; i++)
                    Expanded(flex: _flex[i], child: row.cells[i]),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ],
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            onTap: row.onTap,
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              foregroundColor: theme.colorScheme.primary,
              child: row.mobileLeadingIcon != null
                  ? Icon(row.mobileLeadingIcon, size: 20)
                  : Text(
                      (row.mobileLeadingText?.isNotEmpty ?? false)
                          ? row.mobileLeadingText![0].toUpperCase()
                          : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            title: Text(row.mobileTitle,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: row.mobileSubtitle != null
                ? Text(row.mobileSubtitle!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: row.mobileTrailing,
          ),
        );
      },
    );
  }
}
