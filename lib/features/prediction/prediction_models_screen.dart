import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/file_saver.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../data/repositories/prediction_repository.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../analytics/analytics_widgets.dart';
import '../auth/auth_provider.dart';
import 'engine/feature_extractor.dart';
import 'engine/model_bundle.dart';
import 'prediction_service.dart';

/// Admin workflow: export training data → train in `ml/` → import the model
/// files → review their evaluation → activate one model per task.
class PredictionModelsScreen extends ConsumerStatefulWidget {
  const PredictionModelsScreen({super.key});

  @override
  ConsumerState<PredictionModelsScreen> createState() => _PredictionModelsScreenState();
}

class _PredictionModelsScreenState extends ConsumerState<PredictionModelsScreen> {
  static const _trainCommand =
      'cd ml\npython -m classvault_ml train path/to/classvault_training.csv --out models';

  List<StoredModel>? _models;
  Map<String, int> _counts = const {};
  List<PredictionRun> _activity = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(predictionServiceProvider);
    final models = await service.models();
    final counts = await service.predictionCounts();
    final activity = await service.activity();
    if (mounted) {
      setState(() {
        _models = models;
        _counts = counts;
        _activity = activity;
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) AppSnackBar.error(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export({required bool synthetic}) => _run(() async {
        final service = ref.read(predictionServiceProvider);
        final export = synthetic ? service.exportSyntheticTrainingData() : await service.exportTrainingData();
        if (export.rows == 0) {
          if (mounted) {
            AppSnackBar.warning(context, 'No training rows yet: students need results for at least two semesters.');
          }
          return;
        }
        final date = DateFormat('yyyyMMdd').format(DateTime.now());
        final name = synthetic
            ? 'classvault_training_${FeatureSpec.version}_SYNTHETIC_$date.csv'
            : 'classvault_training_${FeatureSpec.version}_$date.csv';
        final saved = await saveBytesAsFile(
          fileName: name,
          bytes: Uint8List.fromList(utf8.encode(export.csv)),
          allowedExtensions: const ['csv'],
        );
        if (saved && mounted) {
          AppSnackBar.success(context, 'Exported ${export.rows} rows from ${export.students} students.');
        }
      });

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null) return;
    await _run(() async {
      final user = ref.read(authStateProvider).valueOrNull;
      final imported = <String>[];
      for (final file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;
        await ref.read(predictionServiceProvider).importModel(utf8.decode(bytes), importedBy: user?.uid);
        imported.add(file.name);
      }
      await _load();
      if (mounted && imported.isNotEmpty) {
        AppSnackBar.success(context, 'Imported ${imported.length} model file(s). Review and activate below.');
      }
    });
  }

  Future<void> _activate(StoredModel m) async {
    var acknowledge = false;
    if (m.warnings.isNotEmpty) {
      acknowledge = await AppConfirmDialog.show(
        context,
        title: 'Activate despite warnings?',
        message: '${m.warnings.map((w) => '• $w').join('\n')}\n\n'
            'Predictions from this model will be marked accordingly. Faculty remain responsible for any decision.',
        confirmLabel: 'Activate Anyway',
        isDestructive: true,
      );
      if (!acknowledge) return;
    }
    await _run(() async {
      await ref.read(predictionServiceProvider).activate(m, acknowledgeWarnings: acknowledge);
      await _load();
    });
  }

  Future<void> _delete(StoredModel m) async {
    final ok = await AppConfirmDialog.show(
      context,
      title: 'Remove model?',
      message: 'Removes "${m.record.id}". Predictions it already made stay in each student\'s history.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!ok) return;
    await _run(() async {
      await ref.read(predictionServiceProvider).delete(m);
      await _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ResponsiveScaffold(
      title: 'Prediction Models',
      currentPath: '/admin/models',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ConsoleHeader(
                  title: 'Prediction Models',
                  subtitle: 'Decision-support models trained on your academic history. Predictions are signals '
                      'for faculty review, never automatic decisions.',
                ).animate().fadeIn(duration: 250.ms),
                const SizedBox(height: AppSpacing.xl),
                if (_busy) const LinearProgressIndicator(),
                _steps(theme),
                const SizedBox(height: AppSpacing.xl),
                Text('Imported models', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                if (_models == null)
                  const SkeletonCard(height: 200)
                else if (_models!.isEmpty)
                  const EmptyState(
                    icon: Icons.model_training_rounded,
                    title: 'No models imported',
                    message: 'Train models with the ml/ pipeline, then import the .json files here.',
                  )
                else
                  for (final task in ModelTask.values) ..._taskSection(theme, task),
                const SizedBox(height: AppSpacing.xl),
                _activityLog(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _steps(ThemeData theme) {
    Widget step(int n, String title, String body, List<Widget> actions) => SizedBox(
          width: 340,
          child: AnalyticsCard(
            title: '$n. $title',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.md),
                Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: actions),
              ],
            ),
          ),
        );

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        step(1, 'Export training data',
            'One row per student per semester, features ${FeatureSpec.version}. Students appear only as one-way '
            'hashed keys: no names or roll numbers leave the app.', [
          FilledButton.icon(
            onPressed: _busy ? null : () => _export(synthetic: false),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export CSV'),
          ),
          TextButton(
            onPressed: _busy ? null : () => _export(synthetic: true),
            child: const Text('Synthetic sample (testing)'),
          ),
        ]),
        step(2, 'Train', 'Run the pipeline in the project\'s ml/ folder. It evaluates on held-out students and '
            'writes model files plus a report.', [
          SelectableText(_trainCommand, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          IconButton(
            tooltip: 'Copy command',
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _trainCommand));
              AppSnackBar.success(context, 'Command copied.');
            },
          ),
        ]),
        step(3, 'Import & activate', 'Import the risk and forecast .json files, review their evaluation and '
            'activate one model per task.', [
          FilledButton.icon(
            onPressed: _busy ? null : _import,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Import Model Files'),
          ),
        ]),
      ],
    );
  }

  List<Widget> _taskSection(ThemeData theme, ModelTask task) {
    final models = _models!.where((m) => m.bundle.task == task).toList();
    if (models.isEmpty) return const [];
    return [
      Text(task == ModelTask.risk ? 'Academic risk' : 'SGPA forecast',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: AppSpacing.sm),
      for (final m in models) ...[_modelCard(theme, m), const SizedBox(height: AppSpacing.md)],
      const SizedBox(height: AppSpacing.md),
    ];
  }

  Widget _modelCard(ThemeData theme, StoredModel m) {
    final b = m.bundle;
    final metrics = b.metrics;
    String fmt(Object? v) => v is num ? v.toStringAsFixed(3) : '—';
    final keyMetrics = b.task == ModelTask.risk
        ? [
            ('AUC', fmt(metrics['auc'])),
            ('Brier', fmt(metrics['brier'])),
            ('Precision', fmt((metrics['atElevatedThreshold'] as Map?)?['precision'])),
            ('Recall', fmt((metrics['atElevatedThreshold'] as Map?)?['recall'])),
          ]
        : [
            ('MAE', fmt(metrics['mae'])),
            ('Baseline MAE', fmt((metrics['baselines'] as Map?)?['previousSgpaMae'])),
            ('Range', '±${fmt(b.intervalHalfWidth)}'),
            ('Coverage', metrics['intervalCoverage'] is num ? '${((metrics['intervalCoverage'] as num) * 100).round()}%' : '—'),
          ];

    return AnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(b.modelId, style: const TextStyle(fontWeight: FontWeight.bold)),
              _pill(theme, b.family, theme.colorScheme.primary),
              if (m.record.active) _pill(theme, 'ACTIVE', theme.appColors.success),
              if (b.isSynthetic) _pill(theme, 'SYNTHETIC: TEST ONLY', theme.appColors.danger),
              if (!b.isSynthetic && b.recommended) _pill(theme, 'Recommended', theme.appColors.success),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Trained ${DateFormat('d MMM yyyy').format(b.createdAt)} on ${b.trainingRows} rows · '
            'features ${b.featureVersion} · labels ${b.labelVersion}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (label, value) in keyMetrics)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          if (b.selectionReason.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(b.selectionReason, style: theme.textTheme.bodySmall),
          ],
          if (b.checks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final c in b.checks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(c.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 16, color: c.passed ? theme.appColors.success : theme.appColors.danger),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text('${c.name}: ${c.detail}', style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            children: [
              if ((_counts[m.record.id] ?? 0) == 0)
                TextButton.icon(
                  onPressed: _busy ? null : () => _delete(m),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Remove'),
                )
              else
                Tooltip(
                  message: 'Kept so its predictions stay auditable.',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('${_counts[m.record.id]} predictions · kept for audit',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ),
                ),
              if (m.record.active)
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _run(() async {
                            await ref.read(predictionServiceProvider).deactivate(m);
                            await _load();
                          }),
                  child: const Text('Deactivate'),
                )
              else
                FilledButton(onPressed: _busy ? null : () => _activate(m), child: const Text('Activate')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activityLog(ThemeData theme) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final format = DateFormat('d MMM yyyy, h:mm a');
    return AnalyticsCard(
      title: 'Prediction activity',
      subtitle: 'Every time predictions were generated: when, by whom and with which model.',
      child: AppDataTable(
        isDesktop: isDesktop,
        columns: const ['When', 'By', 'Model', 'Predictions'],
        columnFlex: const [2, 2, 4, 1],
        emptyIcon: Icons.history_rounded,
        emptyTitle: 'No predictions generated yet',
        rows: [
          for (final r in _activity)
            AppDataRow(
              mobileTitle: '${r.count} ${r.task} predictions${r.synthetic ? ' (test model)' : ''}',
              mobileSubtitle: '${format.format(r.generatedAt)} · ${r.generatedByName ?? 'unknown'}\n${r.modelId}',
              mobileLeadingIcon: Icons.auto_graph_rounded,
              cells: [
                Text(format.format(r.generatedAt)),
                Text(r.generatedByName ?? 'unknown'),
                Text('${r.modelId}${r.synthetic ? ' (test)' : ''}'),
                Text('${r.count}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _pill(ThemeData theme, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      );
}
