import 'package:flutter/material.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_tokens.dart';
import 'engine/student_analytics.dart';

/// Shared presentation for analytics values, so wording and colours stay
/// consistent (and neutral) across the class and student views.
class AnalyticsFormat {
  const AnalyticsFormat._();

  static String trendLabel(TrendDirection d) => switch (d) {
        TrendDirection.improving => 'Improving',
        TrendDirection.stable => 'Stable',
        TrendDirection.declining => 'Declining',
        TrendDirection.insufficientData => 'Not enough data',
      };

  static IconData trendIcon(TrendDirection d) => switch (d) {
        TrendDirection.improving => Icons.trending_up_rounded,
        TrendDirection.stable => Icons.trending_flat_rounded,
        TrendDirection.declining => Icons.trending_down_rounded,
        TrendDirection.insufficientData => Icons.more_horiz_rounded,
      };

  static Color trendColor(ThemeData theme, TrendDirection d) => switch (d) {
        TrendDirection.improving => theme.appColors.success,
        TrendDirection.stable => theme.colorScheme.primary,
        TrendDirection.declining => theme.appColors.danger,
        TrendDirection.insufficientData => theme.colorScheme.onSurfaceVariant,
      };

  static String consistencyLabel(Consistency c) => switch (c) {
        Consistency.consistent => 'Consistent',
        Consistency.moderate => 'Moderate',
        Consistency.variable => 'Variable',
        Consistency.insufficientData => 'Not enough data',
      };

  static String signalLabel(SignalLevel? level) => switch (level) {
        SignalLevel.attention => 'Attention',
        SignalLevel.monitor => 'Monitor',
        SignalLevel.positive => 'Positive',
        null => 'Stable',
      };

  static Color signalColor(ThemeData theme, SignalLevel? level) => switch (level) {
        SignalLevel.attention => theme.appColors.danger,
        SignalLevel.monitor => theme.appColors.warning,
        SignalLevel.positive => theme.appColors.success,
        null => theme.colorScheme.primary,
      };

  static IconData signalIcon(SignalLevel level) => switch (level) {
        SignalLevel.attention => Icons.priority_high_rounded,
        SignalLevel.monitor => Icons.visibility_outlined,
        SignalLevel.positive => Icons.thumb_up_alt_outlined,
      };

  static String num1(double? v) => v == null ? '—' : v.toStringAsFixed(1);
  static String num2(double? v) => v == null ? '—' : v.toStringAsFixed(2);
  static String pct(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)}%';

  static String performance(StudentAnalytics a, double? v) =>
      a.performanceMetric == 'SGPA' ? num2(v) : pct(v);
}

/// Icon + label for a trend, coloured by direction.
class TrendBadge extends StatelessWidget {
  final TrendDirection direction;
  final bool compact;
  const TrendBadge(this.direction, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AnalyticsFormat.trendColor(theme, direction);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(AnalyticsFormat.trendIcon(direction), size: 18, color: color),
        if (!compact) ...[
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(AnalyticsFormat.trendLabel(direction),
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ],
    );
  }
}

/// Pill showing a student's highest signal level.
class SignalChip extends StatelessWidget {
  final SignalLevel? level;
  final bool hasHistory;
  const SignalChip(this.level, {super.key, this.hasHistory = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasHistory ? AnalyticsFormat.signalColor(theme, level) : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        hasHistory ? AnalyticsFormat.signalLabel(level) : 'No history',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Bordered card used across analytics screens.
class AnalyticsCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  const AnalyticsCard({super.key, this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Text(title!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
            if (title != null || subtitle != null) const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

/// Small metric tile with an explanation line underneath.
class MetricTile extends StatelessWidget {
  final String label;
  final Widget value;
  final String? explanation;
  const MetricTile({super.key, required this.label, required this.value, this.explanation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 220,
      child: AnalyticsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xs),
            DefaultTextStyle.merge(
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              child: value,
            ),
            if (explanation != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(explanation!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Risk band pill using the plan's neutral wording.
class RiskChip extends StatelessWidget {
  final String? band; // 'low' | 'moderate' | 'elevated'
  final bool synthetic;
  const RiskChip(this.band, {super.key, this.synthetic = false});

  static String label(String? band) => switch (band) {
        'elevated' => 'Elevated',
        'moderate' => 'Moderate',
        'low' => 'Low',
        _ => '—',
      };

  static Color color(ThemeData theme, String? band) => switch (band) {
        'elevated' => theme.appColors.danger,
        'moderate' => theme.appColors.warning,
        'low' => theme.appColors.success,
        _ => theme.colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color(theme, band);
    return Tooltip(
      message: synthetic ? 'From a test model trained on synthetic data' : 'Academic risk signal',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: synthetic ? Border.all(color: c.withValues(alpha: 0.6), style: BorderStyle.solid) : null,
        ),
        child: Text('${label(band)}${synthetic ? ' (test)' : ''}',
            style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
