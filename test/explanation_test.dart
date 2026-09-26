import 'dart:convert';

import 'package:classvault/data/models/models.dart';
import 'package:classvault/features/prediction/engine/explanation.dart';
import 'package:classvault/features/prediction/engine/model_bundle.dart';
import 'package:flutter_test/flutter_test.dart';

PredictionRecord record({
  String task = 'risk',
  String? band = 'elevated',
  required String contributionsJson,
  Map<String, double?> features = const {},
}) =>
    PredictionRecord(
      id: 'p1',
      studentId: 's1',
      task: task,
      modelId: 'm',
      featureVersion: 'fv1',
      targetSemester: 4,
      probability: task == 'risk' ? 0.62 : null,
      band: task == 'risk' ? band : null,
      value: task == 'forecast' ? 6.8 : null,
      lower: task == 'forecast' ? 6.1 : null,
      upper: task == 'forecast' ? 7.5 : null,
      featuresJson: jsonEncode(features),
      contributionsJson: contributionsJson,
      synthetic: false,
      generatedAt: DateTime(2026, 9, 26),
    );

ModelOutput output(List<FeatureContribution> contributions, {double bias = -1.0, double? baselineP = 0.27}) =>
    ModelOutput(
      raw: 0.5,
      bias: bias,
      contributions: contributions,
      inputContributions: const [],
      method: ExplanationMethod.treeShap,
      baselineProbability: baselineP,
    );

const factors = [
  FeatureContribution('failed_first_attempts_prev', 2, 0.9),
  FeatureContribution('prev_attendance', 64, 0.6),
  FeatureContribution('prev_sgpa', 5.9, 0.4),
  FeatureContribution('school_10th', 88, -0.3),
];

void main() {
  test('round-trips method, baseline and contributions', () {
    final v = PredictionView.of(record(contributionsJson: PredictionView.encode(output(factors))));
    expect(v.method, ExplanationMethod.treeShap);
    expect(v.baseline, -1.0);
    expect(v.baselineProbability, 0.27);
    expect(v.contributions.map((c) => c.feature), factors.map((c) => c.feature));
  });

  test('reads predictions stored in the earlier list-only format', () {
    final legacy = jsonEncode([for (final c in factors) c.toJson()]);
    final v = PredictionView.of(record(contributionsJson: legacy));
    expect(v.contributions, hasLength(4));
    expect(v.method, isNull);
    expect(v.baseline, isNull);
  });

  test('risk summary names the main factors and the typical-student baseline', () {
    final v = PredictionView.of(record(contributionsJson: PredictionView.encode(output(factors))));
    expect(
      ExplanationText.summary(v),
      'Estimated 62% chance of academic difficulty in semester 4, compared with about 27% for a typical student. '
      'Main reasons: subjects failed last semester (2) and previous semester attendance (64.0%) push it up; '
      '10th % (88.0%) pulls it down.',
    );
  });

  test('forecast summary gives the range and central estimate', () {
    final v = PredictionView.of(record(
      task: 'forecast',
      contributionsJson: PredictionView.encode(output(factors, bias: 7.1, baselineP: null)),
    ));
    expect(ExplanationText.summary(v), startsWith('Expected SGPA 6.1–7.5 in semester 4 (central estimate 6.80, '
        'compared with 7.10 for a typical student).'));
  });

  test('suggestions follow the raising factors, deduplicated, at most three', () {
    final v = PredictionView.of(record(contributionsJson: PredictionView.encode(output([
      ...factors,
      const FeatureContribution('attendance_mean_prior', 70, 0.2), // same suggestion as prev_attendance
      const FeatureContribution('prev_subject_score_min', 31, 0.1),
    ]))));
    final s = ExplanationText.suggestions(v);
    expect(s, hasLength(3));
    expect(s[0], contains('clearing subjects'));
    expect(s[1], contains('attendance'));
    expect(s[2], contains('recent academic performance'));
  });

  test('no suggestions for low risk or for forecasts', () {
    final low = PredictionView.of(record(band: 'low', contributionsJson: PredictionView.encode(output(factors))));
    final forecast = PredictionView.of(record(task: 'forecast', contributionsJson: PredictionView.encode(output(factors))));
    expect(ExplanationText.suggestions(low), isEmpty);
    expect(ExplanationText.suggestions(forecast), isEmpty);
  });

  test('detects changed inputs, including values becoming missing or available', () {
    final changes = ExplanationText.changes(
      {'prev_sgpa': 5.9, 'prev_attendance': null, 'school_10th': 88, 'cgpa_prior': 7.0},
      {'prev_sgpa': 6.4, 'prev_attendance': 81, 'school_10th': 88, 'cgpa_prior': 7.0000001},
    );
    expect(changes.map((c) => c.feature), ['prev_sgpa', 'prev_attendance']);
  });

  test('value formatting', () {
    expect(ExplanationText.value('prev_attendance', 64), '64.0%');
    expect(ExplanationText.value('sgpa_slope_prior', -0.25), '−0.25/sem');
    expect(ExplanationText.value('failed_first_attempts_prev', 2), '2');
    expect(ExplanationText.value('prev_sgpa', null), 'missing');
  });
}
