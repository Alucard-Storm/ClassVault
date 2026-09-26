import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/console_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/app_snackbar.dart';
import '../auth/auth_provider.dart';
import '../prediction/engine/model_bundle.dart';
import '../prediction/prediction_service.dart';
import 'analytics_service.dart';
import 'analytics_widgets.dart';
import 'engine/student_analytics.dart';

/// Remembers the chosen section while navigating to a student and back.
final selectedAnalyticsSectionProvider = StateProvider<String?>((ref) => null);

enum _Filter { all, attention, monitor }

enum _Sort { roll, cgpa, trend, attendance, backlogs, risk }

class ClassAnalyticsScreen extends ConsumerStatefulWidget {
  const ClassAnalyticsScreen({super.key});

  @override
  ConsumerState<ClassAnalyticsScreen> createState() => _ClassAnalyticsScreenState();
}

class _ClassAnalyticsScreenState extends ConsumerState<ClassAnalyticsScreen> {
  static const _path = '/analytics';

  List<SectionOption>? _sections;
  List<StudentAnalytics>? _students;
  SectionOption? _current;
  List<StoredModel> _activeModels = const [];
  Map<String, PredictionView> _risk = const {};
  Map<String, PredictionView> _forecast = const {};
  bool _generating = false;
  Object? _error;
  _Filter _filter = _Filter.all;
  _Sort _sort = _Sort.roll;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) return;
      final sections = await ref.read(analyticsServiceProvider).visibleSections(user);
      if (!mounted) return;
      final remembered = ref.read(selectedAnalyticsSectionProvider);
      final initial = sections.where((s) => s.section.id == remembered).firstOrNull ?? sections.firstOrNull;
      setState(() => _sections = sections);
      if (initial != null) await _selectSection(initial);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _selectSection(SectionOption option) async {
    ref.read(selectedAnalyticsSectionProvider.notifier).state = option.section.id;
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final students = await ref.read(analyticsServiceProvider).forSection(option);
      final predictionService = ref.read(predictionServiceProvider);
      final active = await predictionService.activeModels();
      final latest = await predictionService.latestFor([for (final s in students) s.student.id]);
      if (mounted) {
        setState(() {
          _current = option;
          _students = students;
          _activeModels = active;
          _risk = latest.risk;
          _forecast = latest.forecast;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _generatePredictions() async {
    final user = ref.read(authStateProvider).valueOrNull;
    final section = _current;
    if (user == null || section == null) return;
    setState(() => _generating = true);
    try {
      final result = await ref.read(predictionServiceProvider).generateForSection(section, user);
      final latest = await ref.read(predictionServiceProvider).latestFor([for (final s in _students!) s.student.id]);
      if (!mounted) return;
      setState(() {
        _risk = latest.risk;
        _forecast = latest.forecast;
      });
      AppSnackBar.success(
        context,
        'Predictions generated for ${result.predicted} students'
        '${result.skippedNoHistory > 0 ? '; ${result.skippedNoHistory} skipped (no earlier semesters)' : ''}.',
      );
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Could not generate predictions: $e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String _predictionSummary(String studentId) {
    final risk = _risk[studentId];
    final forecast = _forecast[studentId]?.record;
    return [
      if (risk != null) 'Risk ${RiskChip.label(risk.record.band)}${risk.record.synthetic ? ' (test)' : ''}',
      if (forecast != null) 'SGPA ${forecast.lower!.toStringAsFixed(1)}–${forecast.upper!.toStringAsFixed(1)}',
    ].join(' · ');
  }

  List<StudentAnalytics> _visible() {
    final list = [
      for (final s in _students ?? const <StudentAnalytics>[])
        if (switch (_filter) {
          _Filter.all => true,
          _Filter.attention => s.highestSignal == SignalLevel.attention,
          _Filter.monitor => s.highestSignal == SignalLevel.monitor,
        })
          s,
    ];
    int nullsLast(double? a, double? b, {bool descending = false}) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return descending ? b.compareTo(a) : a.compareTo(b);
    }

    switch (_sort) {
      case _Sort.roll:
        break;
      case _Sort.cgpa:
        list.sort((a, b) => nullsLast(a.cgpa, b.cgpa, descending: true));
      case _Sort.trend:
        list.sort((a, b) => nullsLast(a.performanceTrend.slope, b.performanceTrend.slope));
      case _Sort.attendance:
        list.sort((a, b) => nullsLast(a.latestAttendance, b.latestAttendance));
      case _Sort.backlogs:
        list.sort((a, b) => b.backlogs.current.compareTo(a.backlogs.current));
      case _Sort.risk:
        list.sort((a, b) => nullsLast(
            _risk[a.student.id]?.record.probability, _risk[b.student.id]?.record.probability,
            descending: true));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedId = ref.watch(selectedAnalyticsSectionProvider);

    return ResponsiveScaffold(
      title: 'Academic Insights',
      currentPath: _path,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ConsoleHeader(
              title: 'Academic Insights',
              subtitle: 'Trends, consistency, attendance and backlogs from each student\'s academic history.',
            ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.05, curve: Curves.easeOut),
            const SizedBox(height: AppSpacing.xl),
            if (_error != null)
              EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load analytics',
                message: '$_error',
                actionLabel: 'Retry',
                onAction: _loadSections,
              )
            else if (_sections == null)
              const SkeletonCard(height: 300)
            else if (_sections!.isEmpty)
              const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No sections available',
                message: 'Admins see every section; faculty see the sections they are assigned to.',
              )
            else ...[
              SizedBox(
                width: 420,
                child: DropdownButtonFormField<String>(
                  initialValue: _sections!.any((s) => s.section.id == selectedId) ? selectedId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Section'),
                  items: [
                    for (final s in _sections!) DropdownMenuItem(value: s.section.id, child: Text(s.label)),
                  ],
                  onChanged: (id) => _selectSection(_sections!.firstWhere((s) => s.section.id == id)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_students == null) const SkeletonCard(height: 300) else ..._buildContent(theme),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildContent(ThemeData theme) {
    final students = _students!;
    if (students.isEmpty) {
      return const [
        EmptyState(icon: Icons.face_outlined, title: 'No students in this section'),
      ];
    }

    final summary = StudentAnalyticsEngine.summarize(students);
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final visible = _visible();

    return [
      Wrap(
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.lg,
        children: [
          for (final (label, value, icon, color) in [
            ('Students with history', '${summary.withHistory} / ${summary.studentCount}', Icons.groups_rounded,
                theme.colorScheme.primary),
            ('Attention signals', '${summary.attention}', Icons.priority_high_rounded, theme.appColors.danger),
            ('Monitor signals', '${summary.monitor}', Icons.visibility_outlined, theme.appColors.warning),
            ('Stable', '${summary.stable}', Icons.check_circle_outline_rounded, theme.appColors.success),
            ('Average CGPA', AnalyticsFormat.num2(summary.averageCgpa), Icons.school_outlined, theme.appColors.info),
            ('Avg. latest attendance', AnalyticsFormat.pct(summary.averageAttendance), Icons.event_available_rounded,
                theme.appColors.info),
          ])
            SizedBox(width: 200, child: StatCard(label: label, value: value, icon: icon, color: color)),
        ],
      ),
      if (summary.withHistory == 0) ...[
        const SizedBox(height: AppSpacing.lg),
        AnalyticsCard(
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'No academic history for this section yet. Import results, marks and attendance from '
                  'History Import (admin), or mark attendance in ClassVault.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      AnalyticsCard(
        title: 'Students',
        subtitle: 'Signals are observations to support faculty review, not labels. Tap a student for the reasons behind each one.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<_Filter>(
                  segments: [
                    ButtonSegment(value: _Filter.all, label: Text('All (${students.length})')),
                    ButtonSegment(value: _Filter.attention, label: Text('Attention (${summary.attention})')),
                    ButtonSegment(value: _Filter.monitor, label: Text('Monitor (${summary.monitor})')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) => setState(() => _filter = s.first),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<_Sort>(
                    initialValue: _sort,
                    isExpanded: true,
                    isDense: true,
                    decoration: const InputDecoration(labelText: 'Sort by', isDense: true),
                    items: const [
                      DropdownMenuItem(value: _Sort.roll, child: Text('Roll number')),
                      DropdownMenuItem(value: _Sort.cgpa, child: Text('CGPA (high first)')),
                      DropdownMenuItem(value: _Sort.trend, child: Text('Trend (declining first)')),
                      DropdownMenuItem(value: _Sort.attendance, child: Text('Attendance (low first)')),
                      DropdownMenuItem(value: _Sort.backlogs, child: Text('Backlogs (most first)')),
                      DropdownMenuItem(value: _Sort.risk, child: Text('Risk signal (highest first)')),
                    ],
                    onChanged: (s) => setState(() => _sort = s ?? _Sort.roll),
                  ),
                ),
              ],
            ),
            if (_activeModels.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _predictionControls(theme),
            ],
            const SizedBox(height: AppSpacing.md),
            AppDataTable(
              isDesktop: isDesktop,
              columns: const ['Roll No.', 'Name', 'CGPA', 'Latest', 'Trend', 'Consistency', 'Attendance', 'Backlogs', 'Signal', 'Prediction'],
              columnFlex: const [2, 3, 1, 1, 2, 2, 2, 1, 2, 2],
              emptyIcon: Icons.filter_alt_off_outlined,
              emptyTitle: 'No students match this filter',
              rows: [
                for (final s in visible)
                  AppDataRow(
                    onTap: () => context.go('/analytics/student/${s.student.id}'),
                    mobileTitle: s.student.name,
                    mobileSubtitle: 'CGPA ${AnalyticsFormat.num2(s.cgpa)} · '
                        'Attendance ${AnalyticsFormat.pct(s.latestAttendance)} · '
                        '${s.backlogs.current} backlogs'
                        '${_predictionSummary(s.student.id).isEmpty ? '' : '\n${_predictionSummary(s.student.id)}'}',
                    mobileLeadingText: s.student.rollNumber,
                    mobileTrailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TrendBadge(s.performanceTrend.direction, compact: true),
                        const SizedBox(width: AppSpacing.xs),
                        SignalChip(s.highestSignal, hasHistory: s.hasHistory),
                      ],
                    ),
                    cells: [
                      Text(s.student.rollNumber),
                      Text(s.student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${AnalyticsFormat.num2(s.cgpa)}${s.cgpaEstimated ? '*' : ''}'),
                      Text(AnalyticsFormat.performance(s, s.latestPerformance)),
                      TrendBadge(s.performanceTrend.direction),
                      Text(AnalyticsFormat.consistencyLabel(s.consistency)),
                      Text(
                        AnalyticsFormat.pct(s.latestAttendance),
                        style: TextStyle(
                          color: s.latestAttendance != null &&
                                  s.latestAttendance! < AnalyticsThresholds.attendanceThreshold
                              ? theme.appColors.danger
                              : null,
                        ),
                      ),
                      Text('${s.backlogs.current}'),
                      Align(alignment: Alignment.centerLeft, child: SignalChip(s.highestSignal, hasHistory: s.hasHistory)),
                      _predictionCell(s.student.id),
                    ],
                  ),
              ],
            ),
            if (students.any((s) => s.cgpaEstimated))
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text('* CGPA estimated as the mean of SGPAs (no reported CGPA; credits not weighted).',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _predictionCell(String studentId) {
    final risk = _risk[studentId];
    final forecast = _forecast[studentId]?.record;
    if (risk == null && forecast == null) return const Text('—');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (risk != null) RiskChip(risk.record.band, synthetic: risk.record.synthetic),
        if (forecast != null)
          Text('SGPA ${forecast.lower!.toStringAsFixed(1)}–${forecast.upper!.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _predictionControls(ThemeData theme) {
    final synthetic = _activeModels.any((m) => m.bundle.isSynthetic);
    final tasks = _activeModels.map((m) => m.bundle.task == ModelTask.risk ? 'risk' : 'SGPA forecast').join(' + ');
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: _generating ? null : _generatePredictions,
          icon: _generating
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_graph_rounded),
          label: const Text('Generate Predictions'),
        ),
        Text('For the current semester, using the $tasks model.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        if (synthetic)
          Text('Test model (synthetic data): not for real decisions.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.appColors.danger, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
