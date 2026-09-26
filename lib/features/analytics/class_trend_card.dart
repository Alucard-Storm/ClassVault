import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import 'analytics_widgets.dart';
import 'engine/student_analytics.dart';

/// Class trend view: average SGPA by semester and how many students are
/// improving, stable or declining.
class ClassTrendCard extends StatelessWidget {
  final List<StudentAnalytics> students;
  const ClassTrendCard({super.key, required this.students});

  /// Mean SGPA per semester across students with SGPA data, with counts.
  static List<({int semester, double mean, int students})> averageBySemester(List<StudentAnalytics> students) {
    final bySem = <int, List<double>>{};
    for (final s in students) {
      if (s.performanceMetric != 'SGPA') continue;
      for (final p in s.performanceSeries) {
        bySem.putIfAbsent(p.semester, () => []).add(p.value);
      }
    }
    final sems = bySem.keys.toList()..sort();
    return [
      for (final sem in sems)
        (semester: sem, mean: bySem[sem]!.reduce((a, b) => a + b) / bySem[sem]!.length, students: bySem[sem]!.length),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averages = averageBySemester(students);
    int count(TrendDirection d) => students.where((s) => s.performanceTrend.direction == d).length;
    if (averages.isEmpty) return const SizedBox.shrink();

    final style = TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant);
    return AnalyticsCard(
      title: 'Class trend',
      subtitle: 'Average SGPA by semester (students with SGPA data), and each student\'s own trend.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              for (final d in [TrendDirection.improving, TrendDirection.stable, TrendDirection.declining])
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TrendBadge(d),
                    const SizedBox(width: AppSpacing.xs),
                    Text('${count(d)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              Text('${count(TrendDirection.insufficientData)} without enough data',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                minX: averages.first.semester - 0.5,
                maxX: averages.last.semester + 0.5,
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (final a in averages) FlSpot(a.semester.toDouble(), a.mean)],
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: theme.colorScheme.primary.withValues(alpha: 0.08)),
                  ),
                ],
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => [
                      for (final s in spots)
                        LineTooltipItem(
                          'Sem ${s.x.toInt()}: ${s.y.toStringAsFixed(2)}\n'
                          '${averages.firstWhere((a) => a.semester == s.x.toInt()).students} students',
                          TextStyle(color: theme.colorScheme.onInverseSurface, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}', style: style),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) =>
                          v == v.roundToDouble() ? Text('S${v.toInt()}', style: style) : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Average SGPA: ${averages.map((a) => 'S${a.semester} ${a.mean.toStringAsFixed(2)}').join(' · ')}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          if (averages.length >= 2 && (averages.last.mean - averages[averages.length - 2].mean).abs() >= 0.3)
            Text(
              'Class average ${averages.last.mean > averages[averages.length - 2].mean ? 'rose' : 'fell'} '
              '${(averages.last.mean - averages[averages.length - 2].mean).abs().toStringAsFixed(2)} in the latest semester.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: averages.last.mean > averages[averages.length - 2].mean
                    ? theme.appColors.success
                    : theme.appColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
