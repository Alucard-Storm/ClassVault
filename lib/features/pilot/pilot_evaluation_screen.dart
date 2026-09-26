import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/file_saver.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/stat_card.dart';
import '../analytics/analytics_widgets.dart';
import '../auth/auth_provider.dart';
import '../prediction/engine/explanation.dart';
import 'engine/pilot_evaluation.dart';
import 'engine/pilot_report_markdown.dart';
import 'pilot_service.dart';

final _includeTestModelsProvider = StateProvider<bool>((ref) => false);

final _pilotReportProvider = FutureProvider.autoDispose<PilotReport?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(pilotServiceProvider).evaluate(user, includeTestModels: ref.watch(_includeTestModelsProvider));
});

/// Phase 8: how the predictions performed against real outcomes, how
/// faculty used them, and whether the data behind them was sound.
class PilotEvaluationScreen extends ConsumerWidget {
  const PilotEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_pilotReportProvider);
    final includeTest = ref.watch(_includeTestModelsProvider);
    return ResponsiveScaffold(
      title: 'Pilot Evaluation',
      currentPath: '/admin/pilot',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConsoleHeader(
                  title: 'Pilot Evaluation',
                  subtitle: 'Predictions compared with what actually happened, how faculty used them, and data quality. '
                      'A model is only worth relying on if it holds up here, not just in training.',
                  actionLabel: 'Export Report',
                  actionIcon: Icons.download_rounded,
                  onAction: async.valueOrNull == null ? null : () => _export(context, async.valueOrNull!),
                ).animate().fadeIn(duration: 250.ms),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: includeTest,
                  onChanged: (v) => ref.read(_includeTestModelsProvider.notifier).state = v,
                  title: const Text('Include predictions from test (synthetic) models'),
                  subtitle: const Text('Off for real evaluation; on to try the pilot workflow with test models.'),
                ),
                const SizedBox(height: AppSpacing.md),
                async.when(
                  loading: () => const SkeletonCard(height: 300),
                  error: (e, _) => EmptyState(icon: Icons.error_outline_rounded, title: 'Could not evaluate', message: '$e'),
                  data: (r) => r == null ? const SizedBox.shrink() : _Report(r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, PilotReport report) async {
    try {
      final saved = await saveBytesAsFile(
        fileName: 'classvault_pilot_report_${DateFormat('yyyyMMdd').format(report.generatedAt)}.md',
        bytes: Uint8List.fromList(utf8.encode(PilotReportMarkdown.render(report))),
        allowedExtensions: const ['md'],
      );
      if (saved && context.mounted) AppSnackBar.success(context, 'Report saved.');
    } catch (e) {
      if (context.mounted) AppSnackBar.error(context, 'Could not save the report: $e');
    }
  }
}

class _Report extends StatelessWidget {
  final PilotReport r;
  const _Report(this.r);

  static String pct(double? v) => v == null ? '—' : '${(v * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    const gap = SizedBox(height: AppSpacing.lg);
    final verdictColor = switch (r.verdict) {
      PilotVerdict.continuePilot => theme.appColors.success,
      PilotVerdict.keepCollecting => theme.appColors.info,
      PilotVerdict.doNotRely => theme.appColors.danger,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: verdictColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
          child: Row(
            children: [
              Icon(Icons.fact_check_rounded, color: verdictColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(r.verdict.message,
                    style: theme.textTheme.titleMedium?.copyWith(color: verdictColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        gap,
        AnalyticsCard(
          title: 'Pilot criteria',
          subtitle: 'Proposed thresholds (PilotCriteria); agree them with faculty before the pilot starts.',
          child: Column(
            children: [
              for (final c in r.checks)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    switch (c.status) {
                      CheckStatus.pass => Icons.check_circle_rounded,
                      CheckStatus.fail => Icons.cancel_rounded,
                      CheckStatus.insufficient => Icons.hourglass_empty_rounded,
                    },
                    color: switch (c.status) {
                      CheckStatus.pass => theme.appColors.success,
                      CheckStatus.fail => theme.appColors.danger,
                      CheckStatus.insufficient => theme.colorScheme.onSurfaceVariant,
                    },
                  ),
                  title: Text(c.name),
                  subtitle: Text(c.detail),
                ),
            ],
          ),
        ),
        gap,
        _risk(context, theme, isDesktop),
        gap,
        _forecast(theme, isDesktop),
        gap,
        _faculty(theme),
        gap,
        _dataQuality(theme, isDesktop),
      ],
    );
  }

  Widget _stats(List<(String, String, IconData, Color)> items) => Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          for (final (label, value, icon, color) in items)
            SizedBox(width: 220, child: StatCard(label: label, value: value, icon: icon, color: color)),
        ],
      );

  Widget _risk(BuildContext context, ThemeData theme, bool isDesktop) {
    final risk = r.risk;
    if (risk == null) {
      return const AnalyticsCard(
        title: 'Academic risk',
        child: Text('No risk predictions have known outcomes yet. Outcomes appear once results for the predicted '
            'semester are imported.'),
      );
    }
    Widget studentList(String title, List<EvaluatedPrediction> rows) => ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text('$title (${rows.length})', style: theme.textTheme.titleSmall),
          children: [
            for (final e in rows)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(e.studentName),
                subtitle: Text('${e.group} · sem ${e.record.targetSemester} · predicted '
                    '${RiskChip.label(e.record.band)} (${pct(e.record.probability)})'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go('/analytics/student/${e.record.studentId}/prediction/${e.record.id}'),
              ),
          ],
        );

    return AnalyticsCard(
      title: 'Academic risk',
      subtitle: '"Elevated" is treated as the model flagging a student. Review the misses and false alarms with faculty.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stats([
            ('Outcomes known', '${risk.n} (${risk.positives} difficulty)', Icons.fact_check_outlined, theme.colorScheme.primary),
            ('Precision', pct(risk.precision), Icons.gps_fixed_rounded, theme.appColors.info),
            ('Recall', pct(risk.recall), Icons.radar_rounded, theme.appColors.info),
            ('Calibration error', pct(risk.calibrationError), Icons.tune_rounded, theme.appColors.warning),
          ]),
          const SizedBox(height: AppSpacing.lg),
          AppDataTable(
            isDesktop: isDesktop,
            columns: const ['Band', 'Students', 'Mean predicted', 'Observed difficulty'],
            columnFlex: const [2, 1, 2, 2],
            emptyIcon: Icons.bar_chart_rounded,
            emptyTitle: 'No bands',
            rows: [
              for (final b in risk.byBand)
                AppDataRow(
                  mobileTitle: '${RiskChip.label(b.range)}: ${b.n} students',
                  mobileSubtitle: 'Predicted ${pct(b.meanPredicted)} · observed ${pct(b.observed)}',
                  cells: [RiskChip(b.range), Text('${b.n}'), Text(pct(b.meanPredicted)), Text(pct(b.observed))],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('By section', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          AppDataTable(
            isDesktop: isDesktop,
            columns: const ['Section', 'Students', 'Had difficulty', 'Precision', 'Recall'],
            columnFlex: const [3, 1, 1, 1, 1],
            emptyIcon: Icons.groups_outlined,
            emptyTitle: 'No sections',
            rows: [
              for (final g in risk.groups)
                AppDataRow(
                  mobileTitle: g.group,
                  mobileSubtitle: '${g.n} students · ${g.positives} difficulty · precision ${pct(g.precision)} · recall ${pct(g.recall)}',
                  cells: [Text(g.group), Text('${g.n}'), Text('${g.positives}'), Text(pct(g.precision)), Text(pct(g.recall))],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          studentList('Missed (had difficulty, not rated elevated)', risk.falseNegatives),
          studentList('False alarms (rated elevated, no difficulty)', risk.falsePositives),
        ],
      ),
    );
  }

  Widget _forecast(ThemeData theme, bool isDesktop) {
    final f = r.forecast;
    if (f == null) {
      return const AnalyticsCard(title: 'SGPA forecast', child: Text('No forecasts have known outcomes yet.'));
    }
    return AnalyticsCard(
      title: 'SGPA forecast',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stats([
            ('Outcomes known', '${f.n}', Icons.fact_check_outlined, theme.colorScheme.primary),
            ('Average error', '${f.mae?.toStringAsFixed(2)} SGPA', Icons.straighten_rounded, theme.appColors.info),
            ('Baseline error', f.baselineMae == null ? '—' : '${f.baselineMae!.toStringAsFixed(2)} SGPA',
                Icons.history_rounded, theme.colorScheme.onSurfaceVariant),
            ('Inside range', '${pct(f.coverage)}${f.expectedCoverage == null ? '' : ' / ${pct(f.expectedCoverage)}'}',
                Icons.width_normal_rounded, theme.appColors.warning),
          ]),
          const SizedBox(height: AppSpacing.lg),
          AppDataTable(
            isDesktop: isDesktop,
            columns: const ['Section', 'Forecasts', 'Average error', 'Inside range'],
            columnFlex: const [3, 1, 1, 1],
            emptyIcon: Icons.groups_outlined,
            emptyTitle: 'No sections',
            rows: [
              for (final g in f.groups)
                AppDataRow(
                  mobileTitle: g.group,
                  mobileSubtitle: '${g.n} forecasts · error ${g.mae?.toStringAsFixed(2)} · inside ${pct(g.coverage)}',
                  cells: [Text(g.group), Text('${g.n}'), Text(g.mae?.toStringAsFixed(2) ?? '—'), Text(pct(g.coverage))],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _faculty(ThemeData theme) {
    final rev = r.reviews;
    final e = r.engagement;
    return AnalyticsCard(
      title: 'Faculty use',
      subtitle: 'Usefulness to faculty: whether they engaged with signals and whether their judgement matched outcomes.',
      child: _stats([
        ('Predictions reviewed', '${rev.reviewed}', Icons.rate_review_outlined, theme.colorScheme.primary),
        ('Disagreement rate', pct(rev.disagreementRate), Icons.thumb_down_alt_outlined, theme.appColors.warning),
        ('Reviews matching outcome', '${rev.facultyMatchedOutcome} / ${rev.reviewedWithOutcome}', Icons.verified_outlined,
            theme.appColors.success),
        ('Elevated followed up', '${e.elevatedWithTimelyNote} / ${e.elevatedSignals}', Icons.flag_outlined, theme.appColors.info),
        ('Notes recorded', '${e.notes}', Icons.notes_rounded, theme.colorScheme.primary),
        ('Follow-ups overdue', '${e.followUpsOverdue} of ${e.followUpsSet}', Icons.alarm_rounded, theme.appColors.danger),
      ]),
    );
  }

  Widget _dataQuality(ThemeData theme, bool isDesktop) {
    final q = r.dataQuality;
    final format = DateFormat('d MMM yyyy');
    return AnalyticsCard(
      title: 'Data quality',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stats([
            ('Students without history', '${q.studentsWithoutHistory} / ${q.studentsTotal}', Icons.person_off_outlined,
                theme.colorScheme.onSurfaceVariant),
            ('Rows rejected at import', '${q.rejectedRows} (${pct(q.rejectedRate)})', Icons.block_rounded, theme.appColors.danger),
            ('Import warnings', '${q.warnings}', Icons.warning_amber_rounded, theme.appColors.warning),
          ]),
          if (q.missingInputs.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Most often missing at prediction time: '
                '${q.missingInputs.take(5).map((m) => '${ExplanationText.label(m.feature)} ${pct(m.rate)}').join(' · ')}',
                style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.md),
          AppDataTable(
            isDesktop: isDesktop,
            columns: const ['Import', 'Date', 'Records', 'Rejected', 'Warnings'],
            columnFlex: const [3, 2, 1, 1, 1],
            emptyIcon: Icons.upload_file_outlined,
            emptyTitle: 'No imports yet',
            rows: [
              for (final b in q.imports)
                AppDataRow(
                  mobileTitle: b.fileName,
                  mobileSubtitle: '${format.format(b.importedAt)} · ${b.recordCount} records · '
                      '${b.rejectedRows ?? '—'} rejected · ${b.warningCount ?? '—'} warnings',
                  cells: [
                    Text(b.fileName),
                    Text(format.format(b.importedAt)),
                    Text('${b.recordCount}'),
                    Text(b.rejectedRows?.toString() ?? '—'),
                    Text(b.warningCount?.toString() ?? '—'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
