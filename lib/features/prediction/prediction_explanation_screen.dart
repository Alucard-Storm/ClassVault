import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../analytics/analytics_widgets.dart';
import '../auth/auth_provider.dart';
import 'engine/feature_extractor.dart';
import 'engine/model_bundle.dart';
import 'prediction_service.dart';

final _explanationProvider =
    FutureProvider.autoDispose.family<PredictionExplanation?, String>((ref, predictionId) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(predictionServiceProvider).explain(predictionId, user);
});

/// "Why this signal?": what the model estimated, how much each factor moved
/// it, the exact data it used, and which model made it, for review and
/// audit.
class PredictionExplanationScreen extends ConsumerWidget {
  final String studentId;
  final String predictionId;
  const PredictionExplanationScreen({super.key, required this.studentId, required this.predictionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_explanationProvider(predictionId));
    return ResponsiveScaffold(
      title: 'Why this signal?',
      currentPath: '/analytics',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back to student',
        onPressed: () => context.go('/analytics/student/$studentId'),
      ),
      body: async.when(
        loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: SkeletonCard(height: 400)),
        error: (e, _) => EmptyState(icon: Icons.error_outline_rounded, title: 'Could not load explanation', message: '$e'),
        data: (e) => e == null
            ? const EmptyState(
                icon: Icons.lock_outline_rounded,
                title: 'Prediction not available',
                message: 'It does not exist, or the student is not in one of your sections.',
              )
            : _Body(e),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final PredictionExplanation e;
  const _Body(this.e);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = e.prediction;
    final r = p.record;
    const gap = SizedBox(height: AppSpacing.lg);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    p.isRisk ? 'Academic risk signal' : 'SGPA forecast',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (p.isRisk) RiskChip(r.band, synthetic: r.synthetic),
                ],
              ),
              Text('${e.student.name} · Roll ${e.student.rollNumber} · Semester ${r.targetSemester}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              gap,
              if (r.synthetic)
                _banner(theme, theme.appColors.danger, Icons.science_outlined,
                    'Made by a test model trained on synthetic data. Do not use for real decisions.'),
              if (e.isStale)
                _banner(theme, theme.appColors.warning, Icons.update_rounded, _staleText()),
              AnalyticsCard(
                title: 'Summary',
                child: Text(e.summary, style: theme.textTheme.bodyLarge),
              ),
              gap,
              _contributions(theme),
              gap,
              if (e.suggestions.isNotEmpty) ...[_suggestions(theme), gap],
              _dataUsed(context, theme),
              gap,
              _modelCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  String _staleText() {
    final parts = <String>[];
    if (e.currentSemester != null && e.currentSemester != e.prediction.record.targetSemester) {
      parts.add('The student is now in semester ${e.currentSemester}; this prediction was for semester '
          '${e.prediction.record.targetSemester}.');
    }
    if (e.changes.isNotEmpty) {
      parts.add('${e.changes.length} input${e.changes.length == 1 ? ' has' : 's have'} changed since this prediction '
          '(see "Data used"). Generate predictions again for an up-to-date estimate.');
    }
    return parts.join(' ');
  }

  Widget _banner(ThemeData theme, Color color, IconData icon, String text) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
          ],
        ),
      );

  Widget _contributions(ThemeData theme) {
    final p = e.prediction;
    final items = p.contributions.where((c) => c.contribution.abs() > 1e-9).toList();
    final maxAbs = items.isEmpty ? 1.0 : items.map((c) => c.contribution.abs()).reduce((a, b) => a > b ? a : b);
    final raiseColor = p.isRisk ? theme.appColors.danger : theme.appColors.success;
    final lowerColor = p.isRisk ? theme.appColors.success : theme.appColors.danger;
    final unit = p.isRisk ? 'log-odds' : 'SGPA points';
    final method = p.method?.label ?? 'Recorded before explanation details were stored';

    return AnalyticsCard(
      title: 'How each factor moved this estimate',
      subtitle: 'Starting from a typical student in the training data, each bar shows how far this factor '
          'moved the estimate (${p.isRisk ? 'right raises risk' : 'right raises the expected SGPA'}). '
          'Units: $unit. Method: $method.',
      child: items.isEmpty
          ? const Text('No factor moved this estimate.')
          : Column(
              children: [
                for (final c in items)
                  _ContributionBar(
                    label: ExplanationText.label(c.feature),
                    value: ExplanationText.value(c.feature, c.value),
                    average: e.trainingAverage(c.feature),
                    feature: c.feature,
                    fraction: c.contribution / maxAbs,
                    amount: c.contribution,
                    color: c.contribution > 0 ? raiseColor : lowerColor,
                  ),
              ],
            ),
    );
  }

  Widget _suggestions(ThemeData theme) => AnalyticsCard(
        title: 'Possible next steps',
        subtitle: 'Suggestions based on the factors that raised this signal. Faculty decide whether and how to act.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in e.suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(s)),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _dataUsed(BuildContext context, ThemeData theme) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final then = e.prediction.features;
    final changed = {for (final c in e.changes) c.feature: c};
    return AnalyticsCard(
      title: 'Data used',
      subtitle: 'The exact inputs (feature set ${e.prediction.record.featureVersion}) the model saw, taken from '
          'semesters before semester ${e.prediction.record.targetSemester}. Missing values were filled with the '
          'training median and flagged to the model.',
      child: AppDataTable(
        isDesktop: isDesktop,
        columns: const ['Input', 'At prediction', 'Now', 'Training average'],
        columnFlex: const [4, 2, 2, 2],
        emptyIcon: Icons.dataset_outlined,
        emptyTitle: 'No inputs recorded',
        rows: [
          for (final f in FeatureSpec.names)
            AppDataRow(
              mobileTitle: ExplanationText.label(f),
              mobileSubtitle: 'At prediction: ${ExplanationText.value(f, then[f])}'
                  '${changed[f] == null ? '' : ' · now ${ExplanationText.value(f, changed[f]!.now)}'}',
              mobileTrailing: changed[f] == null
                  ? null
                  : Icon(Icons.update_rounded, size: 18, color: theme.appColors.warning),
              cells: [
                Text(ExplanationText.label(f)),
                Text(ExplanationText.value(f, then[f]),
                    style: TextStyle(color: then[f] == null ? theme.colorScheme.onSurfaceVariant : null)),
                Text(
                  changed[f] == null ? 'same' : ExplanationText.value(f, changed[f]!.now),
                  style: TextStyle(
                    color: changed[f] == null ? theme.colorScheme.onSurfaceVariant : theme.appColors.warning,
                    fontWeight: changed[f] == null ? null : FontWeight.bold,
                  ),
                ),
                Text(e.trainingAverage(f) == null ? '—' : ExplanationText.value(f, e.trainingAverage(f))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _modelCard(ThemeData theme) {
    final r = e.prediction.record;
    final m = e.model;
    final rows = <(String, String)>[
      ('Model', r.modelId),
      ('Generated', DateFormat('d MMM yyyy, h:mm a').format(r.generatedAt)),
      ('Generated by', e.generatedByName ?? r.generatedBy ?? 'unknown'),
      ('Feature set', r.featureVersion),
      if (m != null) ...[
        ('Model type', m.family),
        ('Explanation method', m.explanationMethod.label),
        ('Trained', '${DateFormat('d MMM yyyy').format(m.createdAt)} on ${m.trainingRows} rows (${m.trainingSource} data)'),
        ('Label definition', m.labelVersion),
        if (m.task == ModelTask.risk) ...[
          ('Test AUC', '${m.metrics['auc'] ?? '—'}'),
          ('Risk bands', 'Moderate from ${_pct(m.moderateThreshold)}, elevated from ${_pct(m.elevatedThreshold)}'),
        ] else ...[
          ('Test MAE', '${m.metrics['mae'] ?? '—'} SGPA'),
          ('Range', '${((m.intervalLevel ?? 0) * 100).round()}% of test outcomes expected inside ±${m.intervalHalfWidth?.toStringAsFixed(2)}'),
        ],
        ('Quality checks', m.checks.isEmpty
            ? 'none recorded'
            : '${m.checks.where((c) => c.passed).length} of ${m.checks.length} passed'),
      ] else
        ('Model file', 'No longer available'),
    ];
    return AnalyticsCard(
      title: 'Model and audit trail',
      child: Column(
        children: [
          for (final (k, v) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(k, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                  Expanded(child: SelectableText(v, style: theme.textTheme.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _pct(double? v) => v == null ? '—' : '${(v * 100).round()}%';
}

/// One factor: label and value on the left, a bar growing left (lowers) or
/// right (raises) from the centre line.
class _ContributionBar extends StatelessWidget {
  final String label;
  final String value;
  final double? average;
  final String feature;
  final double fraction; // -1..1
  final double amount;
  final Color color;

  const _ContributionBar({
    required this.label,
    required this.value,
    required this.average,
    required this.feature,
    required this.fraction,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(
          '$value${average == null ? '' : ' · avg ${ExplanationText.value(feature, average)}'}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
    final bar = LayoutBuilder(builder: (context, c) {
      final half = c.maxWidth / 2;
      final width = (fraction.abs() * half).clamp(2.0, half);
      return SizedBox(
        height: 18,
        child: Stack(
          children: [
            Positioned(
              left: half - 0.5,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: theme.dividerColor),
            ),
            Positioned(
              left: fraction >= 0 ? half : half - width,
              top: 3,
              bottom: 3,
              child: Container(
                width: width,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ],
        ),
      );
    });

    return Semantics(
      label: '$label, $value, ${amount > 0 ? 'raises' : 'lowers'} the estimate by ${amount.abs().toStringAsFixed(3)}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: LayoutBuilder(builder: (context, c) {
          final amountText = Text('${amount > 0 ? '+' : '−'}${amount.abs().toStringAsFixed(3)}',
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600));
          if (c.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [Expanded(child: info), amountText]),
                const SizedBox(height: 2),
                bar,
              ],
            );
          }
          return Row(
            children: [
              SizedBox(width: 260, child: info),
              Expanded(child: bar),
              SizedBox(width: 64, child: Align(alignment: Alignment.centerRight, child: amountText)),
            ],
          );
        }),
      ),
    );
  }
}
