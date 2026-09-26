import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_data_table.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_scaffold.dart';
import '../../core/widgets/skeleton_loaders.dart';
import '../auth/auth_provider.dart';
import 'analytics_service.dart';
import 'analytics_widgets.dart';
import 'engine/student_analytics.dart';
import '../prediction/student_predictions_card.dart';

final _studentAnalyticsProvider = FutureProvider.autoDispose.family<StudentAnalytics?, String>((ref, id) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return ref.watch(analyticsServiceProvider).forStudent(id, user);
});

/// One student's academic trajectory, with the reasoning behind each metric
/// and signal shown alongside it.
class StudentInsightsScreen extends ConsumerWidget {
  final String studentId;
  const StudentInsightsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_studentAnalyticsProvider(studentId));
    return ResponsiveScaffold(
      title: 'Student Insights',
      currentPath: '/analytics',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back to class',
        onPressed: () => context.go('/analytics'),
      ),
      body: async.when(
        loading: () => const Padding(padding: EdgeInsets.all(AppSpacing.xl), child: SkeletonCard(height: 400)),
        error: (e, _) => EmptyState(icon: Icons.error_outline_rounded, title: 'Could not load insights', message: '$e'),
        data: (a) => a == null
            ? const EmptyState(
                icon: Icons.lock_outline_rounded,
                title: 'Student not available',
                message: 'The student does not exist or is not in one of your sections.',
              )
            : _StudentInsightsBody(a),
      ),
    );
  }
}

class _StudentInsightsBody extends StatelessWidget {
  final StudentAnalytics a;
  const _StudentInsightsBody(this.a);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = SizedBox(height: AppSpacing.lg);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(theme).animate().fadeIn(duration: 250.ms),
          gap,
          if (!a.hasHistory)
            const EmptyState(
              icon: Icons.history_toggle_off_rounded,
              title: 'No academic history yet',
              message: 'Import this student\'s results, marks and attendance from History Import.',
            )
          else ...[
            _signals(theme),
            gap,
            StudentPredictionsCard(studentId: a.student.id),
            _metrics(theme),
            gap,
            if (a.performanceSeries.isNotEmpty) ...[_performanceChart(theme), gap],
            if (a.attendanceSeries.isNotEmpty) ...[_attendanceChart(theme), gap],
            if (a.subjects.isNotEmpty) ...[_subjects(context, theme), gap],
            if (a.backlogs.everFailed > 0 || a.backlogs.current > 0) ...[_backlogs(theme), gap],
            if (a.assessmentTrends.isNotEmpty) ...[_assessmentTrends(theme), gap],
            if (a.attendance.isNotEmpty) ...[_attendanceTable(context, theme), gap],
          ],
          if (a.currentEnrollment != null) _footnote(theme),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: theme.colorScheme.primary,
          child: Text(a.student.name.isEmpty ? '?' : a.student.name[0].toUpperCase(),
              style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(a.student.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              'Roll ${a.student.rollNumber}'
              '${a.currentEnrollment == null ? '' : ' · Semester ${a.currentEnrollment!.semesterNumber}'}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        for (final e in a.schoolResults.entries)
          Chip(label: Text('${e.key == 'diploma' ? 'Diploma' : e.key}: ${AnalyticsFormat.pct(e.value)}')),
      ],
    );
  }

  Widget _signals(ThemeData theme) {
    return AnalyticsCard(
      title: 'Signals',
      subtitle: 'Observations for faculty review. Faculty decide what, if anything, to do.',
      child: a.signals.isEmpty
          ? Text('No signals: performance and attendance are within normal ranges.',
              style: theme.textTheme.bodyMedium)
          : Column(
              children: [
                for (final s in a.signals)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(AnalyticsFormat.signalIcon(s.level), color: AnalyticsFormat.signalColor(theme, s.level)),
                    title: Text(s.message),
                    trailing: SignalChip(s.level),
                  ),
              ],
            ),
    );
  }

  Widget _metrics(ThemeData theme) {
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.lg,
      children: [
        MetricTile(
          label: a.cgpaEstimated ? 'CGPA (estimated)' : 'CGPA',
          value: Text(AnalyticsFormat.num2(a.cgpa)),
          explanation: a.cgpaEstimated
              ? 'Mean of SGPAs; credits not weighted.'
              : a.cgpaSeries.isEmpty
                  ? null
                  : 'As reported for semester ${a.cgpaSeries.last.semester}.',
        ),
        MetricTile(
          label: 'Latest ${a.performanceMetric}',
          value: Text(AnalyticsFormat.performance(a, a.latestPerformance)),
          explanation: a.recentWeightedAverage == null
              ? null
              : 'Recent weighted average ${AnalyticsFormat.performance(a, a.recentWeightedAverage)} '
                  '(last 3 semesters, most recent counts most).',
        ),
        MetricTile(
          label: '${a.performanceMetric} trend',
          value: TrendBadge(a.performanceTrend.direction),
          explanation: a.performanceTrend.explanation,
        ),
        MetricTile(
          label: 'Consistency',
          value: Text(AnalyticsFormat.consistencyLabel(a.consistency)),
          explanation: a.volatility == null
              ? 'Needs at least ${AnalyticsThresholds.minPointsForConsistency} semesters.'
              : '±${a.volatility!.toStringAsFixed(2)} around the trend line.',
        ),
        MetricTile(
          label: 'Attendance (latest semester)',
          value: Text(AnalyticsFormat.pct(a.latestAttendance)),
          explanation: a.overallAttendance == null
              ? null
              : 'Overall ${AnalyticsFormat.pct(a.overallAttendance)} · ${AnalyticsFormat.trendLabel(a.attendanceTrend.direction).toLowerCase()} trend.',
        ),
        MetricTile(
          label: 'Outstanding backlogs',
          value: Text('${a.backlogs.current}'),
          explanation: a.backlogs.derivedFromSubjects
              ? 'From subject results (latest attempt failed).'
              : a.backlogs.reportedCount == null
                  ? 'No backlog data.'
                  : 'As reported in the latest semester result.',
        ),
      ],
    );
  }

  Widget _performanceChart(ThemeData theme) {
    final isSgpa = a.performanceMetric == 'SGPA';
    final maxY = isSgpa ? 10.0 : 100.0;
    LineChartBarData line(List<SemesterPoint> points, Color color, {bool dashed = false}) => LineChartBarData(
          spots: [for (final p in points) FlSpot(p.semester.toDouble(), p.value)],
          color: color,
          barWidth: 3,
          isCurved: false,
          dashArray: dashed ? const [6, 4] : null,
          dotData: const FlDotData(show: true),
        );

    return AnalyticsCard(
      title: '${a.performanceMetric} by semester',
      subtitle: a.cgpaSeries.isNotEmpty && isSgpa ? 'Solid: SGPA · Dashed: reported CGPA' : null,
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            minX: (a.performanceSeries.first.semester - 0.5).clamp(0, 12).toDouble(),
            maxX: a.performanceSeries.last.semester + 0.5,
            lineBarsData: [
              line(a.performanceSeries, theme.colorScheme.primary),
              if (isSgpa && a.cgpaSeries.isNotEmpty) line(a.cgpaSeries, theme.appColors.info, dashed: true),
            ],
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: isSgpa ? 2 : 20,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: _titles(theme, leftInterval: isSgpa ? 2 : 20),
          ),
        ),
      ),
    );
  }

  Widget _attendanceChart(ThemeData theme) {
    final threshold = AnalyticsThresholds.attendanceThreshold;
    return AnalyticsCard(
      title: 'Attendance by semester',
      subtitle: a.attendanceTrend.explanation,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: 100,
            barGroups: [
              for (final p in a.attendanceSeries)
                BarChartGroupData(x: p.semester, barRods: [
                  BarChartRodData(
                    toY: p.value,
                    width: 18,
                    borderRadius: BorderRadius.circular(AppRadius.control / 2),
                    color: p.value >= threshold ? theme.appColors.success : theme.appColors.danger,
                  ),
                ]),
            ],
            gridData: FlGridData(
              drawVerticalLine: false,
              horizontalInterval: 20,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: _titles(theme, leftInterval: 20, percent: true),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: threshold,
                color: theme.appColors.warning,
                strokeWidth: 1.5,
                dashArray: const [6, 4],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  FlTitlesData _titles(ThemeData theme, {required double leftInterval, bool percent = false}) {
    final style = TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant);
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 34,
          interval: leftInterval,
          getTitlesWidget: (v, _) => Text('${v.toInt()}${percent ? '%' : ''}', style: style),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 24,
          getTitlesWidget: (v, _) =>
              v == v.roundToDouble() ? Text('S${v.toInt()}', style: style) : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _subjects(BuildContext context, ThemeData theme) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    String standing(SubjectStanding s) => switch (s) {
          SubjectStanding.strength => 'Relative strength',
          SubjectStanding.weakness => 'Below own average',
          SubjectStanding.typical => 'Typical',
          SubjectStanding.unknown => '—',
        };
    Color? standingColor(SubjectStanding s) => switch (s) {
          SubjectStanding.strength => theme.appColors.success,
          SubjectStanding.weakness => theme.appColors.warning,
          _ => null,
        };
    String result(bool? passed) => passed == null ? '—' : (passed ? 'Pass' : 'Fail');

    return AnalyticsCard(
      title: 'Subject performance',
      subtitle: 'Latest attempt per subject. Standing compares each score with this student\'s own average '
          '(±${AnalyticsThresholds.subjectRelativeBand.toInt()} points).',
      child: AppDataTable(
        isDesktop: isDesktop,
        columns: const ['Sem', 'Subject', 'Score', 'Grade', 'Result', 'Attempts', 'Standing'],
        columnFlex: const [1, 3, 1, 1, 1, 1, 2],
        emptyIcon: Icons.menu_book_outlined,
        emptyTitle: 'No subject results',
        rows: [
          for (final s in a.subjects)
            AppDataRow(
              mobileTitle: s.subjectName,
              mobileSubtitle: 'Sem ${s.semester} · ${AnalyticsFormat.pct(s.scorePercent)} · ${result(s.passed)}'
                  '${s.attempts > 1 ? ' · ${s.attempts} attempts' : ''}',
              mobileLeadingText: 'S${s.semester}',
              mobileTrailing: Text(standing(s.standing),
                  style: TextStyle(color: standingColor(s.standing), fontSize: 12, fontWeight: FontWeight.w600)),
              cells: [
                Text('${s.semester}'),
                Text(s.subjectName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(AnalyticsFormat.pct(s.scorePercent)),
                Text(s.grade ?? '—'),
                Text(result(s.passed),
                    style: TextStyle(color: s.passed == false ? theme.appColors.danger : null)),
                Text('${s.attempts}'),
                Text(standing(s.standing), style: TextStyle(color: standingColor(s.standing))),
              ],
            ),
        ],
      ),
    );
  }

  Widget _backlogs(ThemeData theme) {
    Widget group(String title, List<SubjectPerformance> items, Color color) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final s in items) Chip(label: Text('${s.subjectName} (sem ${s.semester}, ${s.attempts} attempts)')),
              ],
            ),
          ],
        ),
      );
    }

    final b = a.backlogs;
    return AnalyticsCard(
      title: 'Backlogs',
      subtitle: b.derivedFromSubjects && b.reportedCount != null && b.reportedCount != b.current
          ? 'Subject results show ${b.current} outstanding; the latest semester result reports ${b.reportedCount}.'
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          group('Outstanding', b.outstanding, theme.appColors.danger),
          group('Cleared', b.cleared, theme.appColors.success),
          group('Failed more than once', b.repeated, theme.appColors.warning),
          if (!b.derivedFromSubjects) Text('${b.current} backlog(s) reported; no subject-level results imported.'),
        ],
      ),
    );
  }

  Widget _assessmentTrends(ThemeData theme) {
    return AnalyticsCard(
      title: 'Assessment trends within subjects',
      subtitle: 'Subjects with at least ${AnalyticsThresholds.minAssessmentsForTrend} assessments, in date order.',
      child: Column(
        children: [
          for (final t in a.assessmentTrends)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: TrendBadge(t.trend.direction, compact: true),
              title: Text('${t.subjectName} · sem ${t.semester}'),
              subtitle: Text('${t.scores.map((p) => '${p.value.toStringAsFixed(0)}%').join(' → ')}\n${t.trend.explanation}'),
              isThreeLine: true,
            ),
        ],
      ),
    );
  }

  Widget _attendanceTable(BuildContext context, ThemeData theme) {
    final isDesktop = MediaQuery.of(context).size.width > AppBreakpoints.desktop;
    final rows = [...a.attendance]..sort((x, y) => y.semester.compareTo(x.semester));
    return AnalyticsCard(
      title: 'Attendance by subject',
      subtitle: 'Imported figures, plus sessions marked in ClassVault for the current semester.',
      child: AppDataTable(
        isDesktop: isDesktop,
        columns: const ['Sem', 'Subject', 'Attendance', 'Classes', 'Source'],
        columnFlex: const [1, 3, 2, 2, 2],
        emptyIcon: Icons.event_busy_outlined,
        emptyTitle: 'No attendance',
        rows: [
          for (final r in rows)
            AppDataRow(
              mobileTitle: r.subjectName,
              mobileSubtitle: 'Sem ${r.semester}${r.held == null ? '' : ' · ${r.attended}/${r.held} classes'}',
              mobileLeadingText: 'S${r.semester}',
              mobileTrailing: Text(AnalyticsFormat.pct(r.percentage),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: r.percentage < AnalyticsThresholds.attendanceThreshold ? theme.appColors.danger : null)),
              cells: [
                Text('${r.semester}'),
                Text(r.subjectName),
                Text(AnalyticsFormat.pct(r.percentage),
                    style: TextStyle(
                        color: r.percentage < AnalyticsThresholds.attendanceThreshold ? theme.appColors.danger : null)),
                Text(r.held == null ? '—' : '${r.attended}/${r.held}'),
                Text(r.fromSessions ? 'Marked in app' : 'Imported'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _footnote(ThemeData theme) {
    final since = DateFormat('d MMM yyyy').format(a.currentEnrollment!.startedAt);
    return Text(
      'Current enrollment: semester ${a.currentEnrollment!.semesterNumber} since $since.',
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
