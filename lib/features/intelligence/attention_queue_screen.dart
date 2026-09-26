import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/stat_card.dart';
import '../auth/auth_provider.dart';
import 'engine/attention_queue.dart';
import 'engine/readiness.dart';
import 'intelligence_service.dart';

final attentionQueueProvider = FutureProvider.autoDispose<List<QueueItem>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const [];
  return ref.watch(intelligenceServiceProvider).attentionQueue(user);
});

/// One prioritised list of students who may benefit from a faculty check-in,
/// across every section the user can see.
class AttentionQueueScreen extends ConsumerStatefulWidget {
  const AttentionQueueScreen({super.key});

  @override
  ConsumerState<AttentionQueueScreen> createState() => _AttentionQueueScreenState();
}

class _AttentionQueueScreenState extends ConsumerState<AttentionQueueScreen> {
  QueueStatus? _status = QueueStatus.needsReview;
  String? _section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(attentionQueueProvider);
    return ResponsiveScaffold(
      title: 'Attention Queue',
      currentPath: '/analytics/attention',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConsoleHeader(
              title: 'Attention Queue',
              subtitle: 'Students where additional support may be beneficial, most pressing first. '
                  'Signals are prompts for a conversation, not labels.',
              onRefresh: () => ref.invalidate(attentionQueueProvider),
            ).animate().fadeIn(duration: 250.ms),
            const SizedBox(height: AppSpacing.xl),
            async.when(
              loading: () => const SkeletonCard(height: 300),
              error: (e, _) => EmptyState(icon: Icons.error_outline_rounded, title: 'Could not load the queue', message: '$e'),
              data: (items) => _content(theme, items),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(ThemeData theme, List<QueueItem> items) {
    int count(QueueStatus s) => items.where((i) => i.status == s).length;
    final sections = {for (final i in items) i.input.sectionLabel}.toList()..sort();
    final visible = [
      for (final i in items)
        if ((_status == null || i.status == _status) && (_section == null || i.input.sectionLabel == _section)) i,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.lg,
          children: [
            for (final (label, value, icon, color) in [
              ('Needs review', count(QueueStatus.needsReview), Icons.flag_outlined, theme.appColors.danger),
              ('In progress', count(QueueStatus.inProgress), Icons.pending_actions_rounded, theme.appColors.warning),
              ('Recently reviewed', count(QueueStatus.recentlyReviewed), Icons.task_alt_rounded, theme.appColors.success),
              ('Overdue follow-ups', items.where((i) => i.overdueFollowUp != null).length, Icons.alarm_rounded,
                  theme.appColors.danger),
            ])
              SizedBox(width: 220, child: StatCard(label: label, value: '$value', icon: icon, color: color)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final s in [null, ...QueueStatus.values])
              ChoiceChip(
                label: Text(s?.label ?? 'All (${items.length})'),
                selected: _status == s,
                onSelected: (_) => setState(() => _status = s),
              ),
            if (sections.length > 1)
              SizedBox(
                width: 280,
                child: DropdownButtonFormField<String?>(
                  initialValue: _section,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(labelText: 'Section', isDense: true),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All sections')),
                    for (final s in sections) DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (v) => setState(() => _section = v),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (visible.isEmpty)
          EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: items.isEmpty ? 'Nobody needs attention right now' : 'No students match this filter',
            message: items.isEmpty ? 'Students appear here when their data raises a signal.' : null,
          )
        else
          for (final item in visible) ...[_QueueCard(item: item), const SizedBox(height: AppSpacing.md)],
        const SizedBox(height: AppSpacing.md),
        Text(
          'Order: attention signals ×${QueueWeights.attentionSignal}, monitor ×${QueueWeights.monitorSignal}, '
          'elevated risk +${QueueWeights.elevatedRisk}, moderate +${QueueWeights.moderateRisk}, overdue follow-up '
          '+${QueueWeights.overdueFollowUp}. Risk signals a faculty member disagreed with are not counted.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  final QueueItem item;
  const _QueueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = switch (item.status) {
      QueueStatus.needsReview => theme.appColors.danger,
      QueueStatus.inProgress => theme.appColors.warning,
      QueueStatus.recentlyReviewed => theme.appColors.success,
    };
    final last = item.input.interventions.firstOrNull;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => context.go('/analytics/student/${item.student.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(item.student.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${item.student.rollNumber} · ${item.input.sectionLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  _Pill(item.status.label, statusColor),
                  if (item.riskOverridden) _Pill('Risk overridden by faculty', theme.colorScheme.primary),
                  if (item.readiness.level == ReadinessLevel.strong)
                    _Pill('Project-readiness indicators: strong', theme.appColors.success),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final r in item.reasons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(r, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              if (item.overdueFollowUp != null || last != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  [
                    if (item.overdueFollowUp != null)
                      'Follow-up was due ${DateFormat('d MMM').format(item.overdueFollowUp!)}',
                    if (last != null)
                      'Last note ${DateFormat('d MMM yyyy').format(last.intervention.createdAt)}'
                          '${last.authorName == null ? '' : ' by ${last.authorName}'}',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: item.overdueFollowUp != null ? theme.appColors.danger : theme.colorScheme.onSurfaceVariant,
                    fontWeight: item.overdueFollowUp != null ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}
