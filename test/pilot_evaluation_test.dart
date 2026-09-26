import 'dart:convert';

import 'package:classvault/data/models/models.dart';
import 'package:classvault/features/pilot/engine/pilot_evaluation.dart';
import 'package:flutter_test/flutter_test.dart';

final predictedAt = DateTime(2026, 7, 1);

StudentAcademicHistory history(String id, String section, {double? sem4Sgpa}) => StudentAcademicHistory(
      student: Student(id: id, rollNumber: id, name: 'Student $id', sectionId: section),
      enrollments: [
        StudentEnrollment(id: '$id-e', studentId: id, sectionId: section, semesterNumber: 4, startedAt: DateTime(2026, 6)),
      ],
      schoolResults: const [],
      semesterResults: [
        SemesterResult(id: '$id-3', studentId: id, semesterNumber: 3, sgpa: 7.0),
        if (sem4Sgpa != null) SemesterResult(id: '$id-4', studentId: id, semesterNumber: 4, sgpa: sem4Sgpa),
      ],
      subjectResults: const [],
      attendanceSummaries: const [],
      assessments: const [],
    );

PredictionRecord risk(String student, String band, double p, {DateTime? at, bool synthetic = false, String id = ''}) =>
    PredictionRecord(
      id: id.isEmpty ? 'r-$student' : id,
      studentId: student,
      task: 'risk',
      modelId: synthetic ? 'test-model' : 'risk-model',
      featureVersion: 'fv1',
      targetSemester: 4,
      probability: p,
      band: band,
      featuresJson: jsonEncode({'prev_sgpa': 7.0}),
      contributionsJson: '[]',
      synthetic: synthetic,
      generatedAt: at ?? predictedAt,
    );

PredictionRecord forecast(String student, double value, {bool withPrev = true}) => PredictionRecord(
      id: 'f-$student',
      studentId: student,
      task: 'forecast',
      modelId: 'forecast-model',
      featureVersion: 'fv1',
      targetSemester: 4,
      value: value,
      lower: value - 0.5,
      upper: value + 0.5,
      featuresJson: jsonEncode({'prev_sgpa': withPrev ? 7.0 : null}),
      contributionsJson: '[]',
      synthetic: false,
      generatedAt: predictedAt,
    );

Intervention note(String student, DateTime at, {String type = 'meeting', String? predictionId, String? assessment,
        DateTime? followUp, String status = 'done'}) =>
    Intervention(
      id: '$type-$student-${at.day}', studentId: student, authorId: 'f', type: type, note: 'n', status: status,
      followUpOn: followUp, predictionId: predictionId, reviewAssessment: assessment, createdAt: at, updatedAt: at,
    );

/// 40 students, 20 per section. Students 0–19 had difficulty in semester 4
/// (SGPA 5.0), 20–39 did not (SGPA 7.5). The model rated 18 of the 20
/// "difficulty" students elevated (2 missed, both in section B) and 4 of the
/// others elevated (false alarms).
({List<PredictionRecord> predictions, Map<String, StudentAcademicHistory> histories}) scenario() {
  final histories = <String, StudentAcademicHistory>{};
  final predictions = <PredictionRecord>[];
  for (var i = 0; i < 40; i++) {
    final id = 's$i';
    final difficulty = i < 20;
    final section = i.isEven ? 'A' : 'B';
    histories[id] = history(id, section, sem4Sgpa: difficulty ? 5.0 : 7.5);
    final missed = i == 1 || i == 3; // section B
    final falseAlarm = i >= 20 && i < 24;
    final band = (difficulty && !missed) || falseAlarm ? 'elevated' : (difficulty ? 'moderate' : 'low');
    predictions.add(risk(id, band, band == 'elevated' ? 0.8 : (band == 'moderate' ? 0.4 : 0.1)));
  }
  return (predictions: predictions, histories: histories);
}

PilotReport run(
  List<PredictionRecord> predictions,
  Map<String, StudentAcademicHistory> histories, {
  Map<String, List<Intervention>> interventions = const {},
  List<ImportBatch> imports = const [],
  bool includeTestModels = false,
}) =>
    PilotEvaluator.evaluate(
      predictions: predictions,
      histories: histories,
      sectionLabels: const {'A': 'Section A', 'B': 'Section B'},
      interventions: interventions,
      imports: imports,
      studentsTotal: histories.length,
      studentsWithoutHistory: 0,
      intervalLevels: const {'forecast-model': 0.8},
      includeTestModels: includeTestModels,
      now: DateTime(2026, 9, 26),
    );

PilotCheck check(PilotReport r, String name) => r.checks.firstWhere((c) => c.name == name);

void main() {
  test('precision, recall, confusion counts and error lists', () {
    final s = scenario();
    final r = run(s.predictions, s.histories).risk!;
    expect((r.n, r.positives, r.tp, r.fp, r.fn, r.tn), (40, 20, 18, 4, 2, 16));
    expect(r.precision, closeTo(18 / 22, 1e-9));
    expect(r.recall, closeTo(0.9, 1e-9));
    expect(r.falseNegatives.map((e) => e.record.studentId), ['s1', 's3']);
    expect(r.falsePositives, hasLength(4));
  });

  test('calibration by probability and by band', () {
    final s = scenario();
    final r = run(s.predictions, s.histories).risk!;
    final bands = {for (final b in r.byBand) b.range: (b.n, b.observed)};
    expect(bands['low'], (16, 0.0));
    expect(bands['moderate'], (2, 1.0));
    expect(bands['elevated']!.$2, closeTo(18 / 22, 1e-9));
    // p=0.1 bin: 16 rows, observed 0 → |0.1-0|; p=0.4: 2 rows → |0.4-1|; p=0.8: 22 rows → |0.8-0.818|
    final expected = 16 / 40 * 0.1 + 2 / 40 * 0.6 + 22 / 40 * (0.8 - 18 / 22).abs();
    expect(r.calibrationError, closeTo(expected, 1e-9));
  });

  test('stability by section uses the section at the predicted semester', () {
    final s = scenario();
    final groups = {for (final g in run(s.predictions, s.histories).risk!.groups) g.group: g};
    expect(groups['Section A']!.recall, 1.0);
    expect(groups['Section B']!.recall, closeTo(8 / 10, 1e-9));
  });

  test('uses the latest prediction per student and semester; skips unknown outcomes and test models', () {
    final s = scenario();
    final older = risk('s0', 'low', 0.05, at: DateTime(2026, 6, 1), id: 'old');
    final unknown = history('new', 'A'); // no semester 4 result yet
    final r = run(
      [...s.predictions, older, risk('new', 'elevated', 0.9), risk('s5', 'low', 0.1, synthetic: true, id: 'syn')],
      {...s.histories, 'new': unknown},
    );
    expect(r.risk!.n, 40);
    expect(r.risk!.tp, 18); // s0 still counted with its latest (elevated) prediction
    expect(r.modelsEvaluated, {'risk-model': 41});

    final withTest = run([...s.predictions, risk('s5', 'low', 0.1, synthetic: true, id: 'syn', at: DateTime(2026, 8))],
        s.histories, includeTestModels: true);
    expect(withTest.risk!.fn, 3); // the later test-model prediction for s5 replaces its elevated one
  });

  test('faculty reviews are scored against outcomes', () {
    final s = scenario();
    final r = run(s.predictions, s.histories, interventions: {
      // Disagreed with a false alarm (right), disagreed with a true positive (wrong), agreed with a true positive.
      's20': [note('s20', DateTime(2026, 7, 3), type: 'prediction_review', predictionId: 'r-s20', assessment: 'disagree')],
      's0': [note('s0', DateTime(2026, 7, 3), type: 'prediction_review', predictionId: 'r-s0', assessment: 'disagree')],
      's2': [note('s2', DateTime(2026, 7, 3), type: 'prediction_review', predictionId: 'r-s2', assessment: 'agree')],
    });
    final rev = r.reviews;
    expect((rev.reviewed, rev.agreed, rev.disagreed), (3, 1, 2));
    expect((rev.reviewedWithOutcome, rev.facultyMatchedOutcome, rev.disagreedAndNoDifficulty), (3, 2, 1));
    expect(check(r, 'Faculty agree with signals').status, CheckStatus.insufficient); // fewer than 10 reviews
  });

  test('engagement: timely notes after elevated signals and follow-ups', () {
    final s = scenario();
    final r = run(s.predictions, s.histories, interventions: {
      's0': [note('s0', DateTime(2026, 7, 5))], // within 14 days
      's2': [note('s2', DateTime(2026, 8, 30))], // too late
      's4': [note('s4', DateTime(2026, 7, 2), followUp: DateTime(2026, 9, 1), status: 'open')], // overdue
      's6': [note('s6', DateTime(2026, 7, 2), followUp: DateTime(2026, 8, 1))],
    }).engagement;
    expect(r.elevatedSignals, 22);
    expect(r.elevatedWithTimelyNote, 3);
    expect((r.notes, r.followUpsSet, r.followUpsDone, r.followUpsOverdue), (4, 2, 1, 1));
  });

  test('forecast accuracy, coverage and baseline', () {
    final s = scenario();
    final r = run([
      forecast('s0', 5.3), // actual 5.0: error 0.3, inside ±0.5
      forecast('s20', 6.8), // actual 7.5: error 0.7, outside
      forecast('s21', 7.4, withPrev: false), // actual 7.5: error 0.1, inside
    ], s.histories).forecast!;
    expect(r.n, 3);
    expect(r.mae, closeTo((0.3 + 0.7 + 0.1) / 3, 1e-9));
    expect(r.coverage, closeTo(2 / 3, 1e-9));
    expect(r.baselineMae, closeTo((2.0 + 0.5) / 2, 1e-9)); // |7.0-5.0|, |7.0-7.5|
    expect(r.expectedCoverage, 0.8);
  });

  test('checks and verdict', () {
    final s = scenario();
    final report = run(s.predictions, s.histories, imports: [
      ImportBatch(id: 'b', fileName: 'x', importedAt: DateTime(2026, 6), recordCount: 190, rejectedRows: 10, warningCount: 3),
    ]);
    expect(check(report, 'Enough outcomes to judge').status, CheckStatus.pass);
    expect(check(report, 'Precision of "elevated"').status, CheckStatus.pass);
    expect(check(report, 'Recall of "elevated"').status, CheckStatus.pass);
    // Moderate has only 2 rows so it is ignored; low (0%) → elevated (82%) rises.
    expect(check(report, 'Bands are meaningful').status, CheckStatus.pass);
    expect(check(report, 'Stable across sections').status, CheckStatus.pass);
    expect(check(report, 'Data quality').status, CheckStatus.pass); // 5% rejected
    expect(report.verdict, PilotVerdict.keepCollecting); // reviews still insufficient
  });

  test('a poorly calibrated model fails and the verdict says not to rely on it', () {
    final s = scenario();
    final overconfident = [
      for (final p in s.predictions)
        risk(p.studentId, p.band!, p.band == 'elevated' ? 0.99 : 0.6),
    ];
    final report = run(overconfident, s.histories);
    expect(check(report, 'Calibration').status, CheckStatus.fail);
    expect(report.verdict, PilotVerdict.doNotRely);
  });

  test('too few outcomes is insufficient, not a failure', () {
    final s = scenario();
    final few = s.predictions.take(8).toList();
    final report = run(few, s.histories);
    expect(check(report, 'Enough outcomes to judge').status, CheckStatus.insufficient);
    expect(check(report, 'Precision of "elevated"').status, CheckStatus.insufficient);
    expect(report.verdict, PilotVerdict.keepCollecting);
  });
}
