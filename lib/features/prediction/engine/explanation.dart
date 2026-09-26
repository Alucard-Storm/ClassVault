import 'dart:convert';

import '../../../data/models/models.dart';
import 'feature_extractor.dart';
import 'model_bundle.dart';

/// A stored prediction with its explanation decoded.
class PredictionView {
  final PredictionRecord record;
  final List<FeatureContribution> contributions; // sorted by |contribution|

  /// Null for predictions stored before explanation metadata was recorded.
  final ExplanationMethod? method;

  /// Expected model output for a typical training student.
  final double? baseline;
  final double? baselineProbability;

  const PredictionView(this.record, this.contributions, this.method, this.baseline, this.baselineProbability);

  bool get isRisk => record.task == ModelTask.risk.name;

  RiskBand? get band => switch (record.band) {
        'elevated' => RiskBand.elevated,
        'moderate' => RiskBand.moderate,
        'low' => RiskBand.low,
        _ => null,
      };

  Map<String, double?> get features => (jsonDecode(record.featuresJson) as Map<String, dynamic>)
      .map((k, v) => MapEntry(k, (v as num?)?.toDouble()));

  /// Stored as {method, baseline, baselineProbability, items}; earlier
  /// predictions stored only the list of items.
  static String encode(ModelOutput out) => jsonEncode({
        'method': out.method.name,
        'baseline': out.bias,
        'baselineProbability': out.baselineProbability,
        'items': [for (final c in out.contributions) c.toJson()],
      });

  static PredictionView of(PredictionRecord r) {
    final decoded = jsonDecode(r.contributionsJson);
    final items = decoded is List ? decoded : (decoded as Map<String, dynamic>)['items'] as List;
    final meta = decoded is Map<String, dynamic> ? decoded : const <String, dynamic>{};
    return PredictionView(
      r,
      [for (final c in items.cast<Map<String, dynamic>>()) FeatureContribution.fromJson(c)],
      ExplanationMethod.values.where((m) => m.name == meta['method']).firstOrNull,
      (meta['baseline'] as num?)?.toDouble(),
      (meta['baselineProbability'] as num?)?.toDouble(),
    );
  }
}

/// A feature whose value differs now from when the prediction was made.
class FeatureChange {
  final String feature;
  final double? then;
  final double? now;
  const FeatureChange(this.feature, this.then, this.now);
}

/// Turns contributions into plain language, suggestions and change reports.
/// Wording follows the plan: observations and suggestions, never labels or
/// decisions.
class ExplanationText {
  const ExplanationText._();

  static String label(String feature) => FeatureSpec.labels[feature] ?? feature;

  static String value(String feature, double? v) {
    if (v == null) return 'missing';
    final isPercent = (feature.contains('attendance') && !feature.contains('slope')) ||
        feature.contains('score') ||
        feature.startsWith('school') ||
        feature == 'prev_percentage';
    if (isPercent) return '${v.toStringAsFixed(1)}%';
    if (feature.contains('slope')) return '${v >= 0 ? '+' : '−'}${v.abs().toStringAsFixed(2)}/sem';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  static String _factor(FeatureContribution c) => '${label(c.feature).toLowerCase()} (${value(c.feature, c.value)})';

  /// One-paragraph summary of what the model estimated and why.
  static String summary(PredictionView p) {
    final r = p.record;
    final up = p.contributions.where((c) => c.contribution > 1e-9).take(2).toList();
    final down = p.contributions.where((c) => c.contribution < -1e-9).take(1).toList();
    final reasons = [
      if (up.isNotEmpty) '${up.map(_factor).join(' and ')} ${up.length == 1 ? 'pushes' : 'push'} it up',
      if (down.isNotEmpty) '${down.map(_factor).join(' and ')} pulls it down',
    ].join('; ');

    if (p.isRisk) {
      final pct = ((r.probability ?? 0) * 100).round();
      final base = p.baselineProbability == null
          ? ''
          : ', compared with about ${(p.baselineProbability! * 100).round()}% for a typical student';
      return 'Estimated $pct% chance of academic difficulty in semester ${r.targetSemester}$base.'
          '${reasons.isEmpty ? '' : ' Main reasons: $reasons.'}';
    }
    final base = p.baseline == null ? '' : ', compared with ${p.baseline!.toStringAsFixed(2)} for a typical student';
    return 'Expected SGPA ${r.lower!.toStringAsFixed(1)}–${r.upper!.toStringAsFixed(1)} in semester '
        '${r.targetSemester} (central estimate ${r.value!.toStringAsFixed(2)}$base).'
        '${reasons.isEmpty ? '' : ' Main reasons: $reasons.'}';
  }

  static const _suggestionFor = {
    'prev_attendance': _attendance,
    'attendance_mean_prior': _attendance,
    'attendance_slope_prior': _attendance,
    'failed_first_attempts_prior': _backlogs,
    'failed_first_attempts_prev': _backlogs,
    'backlogs_reported_prev': _backlogs,
    'prev_sgpa': _performance,
    'prev2_sgpa': _performance,
    'sgpa_mean_prior': _performance,
    'cgpa_prior': _performance,
    'sgpa_slope_prior': _performance,
    'prev_percentage': _performance,
    'prev_subject_score_mean': _subjects,
    'prev_subject_score_min': _subjects,
    'sgpa_volatility_prior': _variability,
  };

  static const _attendance = 'Talk with the student about attendance and whether anything is making it hard to attend.';
  static const _backlogs = 'Review the plan and timeline for clearing subjects that were not passed.';
  static const _performance = 'Check in about recent academic performance and current workload.';
  static const _subjects = 'Consider subject-specific support (tutoring, office hours) for the weakest subjects.';
  static const _variability = 'Look at what changed in the semesters where performance dipped.';

  /// Up to three possible next steps from the factors that raised a
  /// moderate or elevated risk signal. Suggestions only: faculty decide.
  static List<String> suggestions(PredictionView p) {
    if (!p.isRisk || p.band == null || p.band == RiskBand.low) return const [];
    final out = <String>[];
    for (final c in p.contributions) {
      if (c.contribution <= 1e-9) continue;
      final s = _suggestionFor[c.feature];
      if (s != null && !out.contains(s)) out.add(s);
      if (out.length == 3) break;
    }
    return out;
  }

  /// Features whose values differ between the prediction and now.
  static List<FeatureChange> changes(Map<String, double?> then, Map<String, double?> now) {
    bool differs(double? a, double? b) => (a == null) != (b == null) || (a != null && (a - b!).abs() > 1e-6);
    return [
      for (final f in FeatureSpec.names)
        if (differs(then[f], now[f])) FeatureChange(f, then[f], now[f]),
    ];
  }
}
