import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/models.dart';
import '../../data/repositories/intervention_repository.dart';
import '../analytics/analytics_widgets.dart';
import '../analytics/engine/student_analytics.dart';
import '../auth/auth_provider.dart';
import 'attention_queue_screen.dart';
import 'engine/readiness.dart';
import 'intelligence_service.dart';

final interventionsProvider =
    FutureProvider.autoDispose.family<List<InterventionEntry>, String>((ref, studentId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const [];
  return ref.watch(intelligenceServiceProvider).interventionsFor(studentId, user);
});

const _typeLabels = {
  'note': 'Note',
  'meeting': 'Meeting',
  'referral': 'Referral',
  'mentoring': 'Mentoring',
  'prediction_review': 'Prediction review',
};

/// Rule-based project-readiness indicators with every criterion visible.
class ReadinessCard extends StatelessWidget {
  final StudentAnalytics analytics;
  const ReadinessCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ProjectReadiness.assess(analytics);
    final color = switch (r.level) {
      ReadinessLevel.strong => theme.appColors.success,
      ReadinessLevel.developing => theme.appColors.info,
      _ => theme.colorScheme.onSurfaceVariant,
    };
    return AnalyticsCard(
      title: 'Project-readiness indicators: ${r.level.label.toLowerCase()}',
      subtitle: 'Transparent criteria, not a prediction or a ranking. ${r.met} of ${r.evaluated} evaluable criteria met. '
          'Use alongside what you know of the student (e.g. previous project work, which is not recorded here).',
      child: Column(
        children: [
          for (final c in r.criteria)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                switch (c.result) {
                  CriterionResult.met => Icons.check_circle_rounded,
                  CriterionResult.notMet => Icons.radio_button_unchecked_rounded,
                  CriterionResult.noData => Icons.help_outline_rounded,
                },
                color: switch (c.result) {
                  CriterionResult.met => color == theme.colorScheme.onSurfaceVariant ? theme.appColors.success : color,
                  CriterionResult.notMet => theme.appColors.warning,
                  CriterionResult.noData => theme.colorScheme.onSurfaceVariant,
                },
              ),
              title: Text(c.name),
              subtitle: Text('${c.rule} · ${c.detail}'),
            ),
        ],
      ),
    );
  }
}

/// Faculty notes, meetings, referrals and follow-ups for a student.
class InterventionsCard extends ConsumerWidget {
  final String studentId;
  const InterventionsCard({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entries = ref.watch(interventionsProvider(studentId)).valueOrNull ?? const [];
    final format = DateFormat('d MMM yyyy');

    return AnalyticsCard(
      title: 'Notes & interventions',
      subtitle: 'Staff only. Record conversations, referrals and follow-ups so colleagues can see what has been done.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => _addNote(context, ref),
              icon: const Icon(Icons.add_comment_outlined),
              label: const Text('Add Note'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (entries.isEmpty)
            Text('Nothing recorded yet.', style: theme.textTheme.bodyMedium)
          else
            for (final e in entries)
              _EntryTile(entry: e, format: format, onToggle: () => _toggle(context, ref, e.intervention)),
        ],
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, Intervention i) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    try {
      await ref.read(intelligenceServiceProvider).setStatus(i.id, i.isOpen ? 'done' : 'open', user);
      ref.invalidate(interventionsProvider(studentId));
      ref.invalidate(attentionQueueProvider);
    } catch (e) {
      if (context.mounted) AppSnackBar.error(context, '$e');
    }
  }

  Future<void> _addNote(BuildContext context, WidgetRef ref) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => _AddNoteDialog(studentId: studentId));
    if (saved == true) {
      ref.invalidate(interventionsProvider(studentId));
      ref.invalidate(attentionQueueProvider);
    }
  }
}

class _EntryTile extends StatelessWidget {
  final InterventionEntry entry;
  final DateFormat format;
  final VoidCallback onToggle;
  const _EntryTile({required this.entry, required this.format, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i = entry.intervention;
    final review = i.isReview;
    final overdue = i.isOpen && i.followUpOn != null && i.followUpOn!.isBefore(DateTime.now());
    final heading = review
        ? 'Prediction review: ${i.reviewAssessment == 'disagree' ? 'disagreed' : 'agreed'}'
        : _typeLabels[i.type] ?? i.type;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(heading, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${format.format(i.createdAt)}${entry.authorName == null ? '' : ' · ${entry.authorName}'}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(i.note),
          if (!review && (i.followUpOn != null || i.isOpen)) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (i.followUpOn != null)
                  Text(
                    '${i.isOpen ? 'Follow up' : 'Followed up'} by ${format.format(i.followUpOn!)}${overdue ? ' (overdue)' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: overdue ? theme.appColors.danger : theme.colorScheme.onSurfaceVariant,
                      fontWeight: overdue ? FontWeight.bold : null,
                    ),
                  ),
                TextButton(onPressed: onToggle, child: Text(i.isOpen ? 'Mark done' : 'Reopen')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AddNoteDialog extends ConsumerStatefulWidget {
  final String studentId;
  const _AddNoteDialog({required this.studentId});

  @override
  ConsumerState<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<_AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  String _type = 'meeting';
  DateTime? _followUp;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(intelligenceServiceProvider).addNote(
            studentId: widget.studentId,
            type: _type,
            note: _note.text,
            followUpOn: _followUp,
            user: user,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) AppSnackBar.error(context, '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialog(
      title: 'Add note',
      icon: Icons.add_comment_outlined,
      confirmLabel: _saving ? 'Saving...' : 'Save',
      onConfirm: _save,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final t in Intervention.types)
                  if (t != 'prediction_review') DropdownMenuItem(value: t, child: Text(_typeLabels[t]!)),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'note'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _note,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'What happened / what was agreed'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Write a note' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _followUp ?? now.add(const Duration(days: 7)),
                      firstDate: now.subtract(const Duration(days: 1)),
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => _followUp = picked);
                  },
                  icon: const Icon(Icons.event_outlined, size: 18),
                  label: Text(_followUp == null ? 'Set follow-up date' : DateFormat('d MMM yyyy').format(_followUp!)),
                ),
                if (_followUp != null)
                  TextButton(onPressed: () => setState(() => _followUp = null), child: const Text('No follow-up')),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _followUp == null ? 'Saved as done.' : 'Stays open (in progress) until marked done.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
