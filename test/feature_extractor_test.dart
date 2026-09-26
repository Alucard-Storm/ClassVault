import 'dart:convert';
import 'dart:io';

import 'package:classvault/data/models/models.dart';
import 'package:classvault/features/prediction/engine/feature_extractor.dart';
import 'package:classvault/features/prediction/engine/synthetic_history.dart';
import 'package:flutter_test/flutter_test.dart';

StudentAcademicHistory history({
  List<SemesterResult> semesters = const [],
  List<SubjectResult> subjects = const [],
  List<AttendanceSummary> attendance = const [],
}) =>
    StudentAcademicHistory(
      student: Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec'),
      enrollments: const [],
      schoolResults: [SchoolResult(id: 'x', studentId: 's1', level: '10th', percentage: 82)],
      semesterResults: semesters,
      subjectResults: subjects,
      attendanceSummaries: attendance,
      assessments: const [],
    );

SemesterResult sem(int n, double sgpa, {double? cgpa, int backlogs = 0}) =>
    SemesterResult(id: 'r$n', studentId: 's1', semesterNumber: n, sgpa: sgpa, cgpa: cgpa, backlogs: backlogs);

SubjectResult subj(int s, String name, {required bool passed, double total = 50, int attempt = 1}) =>
    SubjectResult(id: '$s$name$attempt', studentId: 's1', semesterNumber: s, subjectName: name,
        totalMarks: total, maxMarks: 100, passed: passed, attempt: attempt);

void main() {
  test('feature list matches ml/feature_spec.json', () {
    final spec = jsonDecode(File('ml/feature_spec.json').readAsStringSync()) as Map<String, dynamic>;
    expect(spec['featureVersion'], FeatureSpec.version);
    expect(spec['labelVersion'], FeatureSpec.labelVersion);
    expect([for (final f in spec['features'] as List) f['name']], FeatureSpec.names);
    expect([for (final f in spec['metaColumns'] as List) f['name']], FeatureSpec.metaColumns);
    expect([for (final f in spec['labels'] as List) f['name']], FeatureSpec.labelColumns);
  });

  test('features use only semesters before the target (no leakage)', () {
    final h = history(
      semesters: [sem(1, 7.0), sem(2, 7.4, cgpa: 7.2, backlogs: 1), sem(3, 3.0)],
      subjects: [
        subj(2, 'OS', passed: false, total: 30),
        subj(2, 'OS', passed: true, attempt: 2), // re-attempt: timing unknown, ignored
        subj(2, 'DB', passed: true, total: 70),
        subj(3, 'CN', passed: false),
      ],
      attendance: [
        AttendanceSummary(id: 'a', studentId: 's1', semesterNumber: 2, subjectName: 'OS', percentage: 80,
            classesHeld: 40, classesAttended: 32),
        AttendanceSummary(id: 'b', studentId: 's1', semesterNumber: 3, subjectName: 'OS', percentage: 20),
      ],
    );
    final f = FeatureExtractor.extract(h, 3);
    expect(f.keys.toList(), FeatureSpec.names);
    expect(f['target_semester'], 3);
    expect(f['n_prior_semesters'], 2);
    expect(f['prev_sgpa'], 7.4);
    expect(f['prev2_sgpa'], 7.0);
    expect(f['sgpa_mean_prior'], closeTo(7.2, 1e-9));
    expect(f['sgpa_slope_prior'], closeTo(0.4, 1e-9));
    expect(f['sgpa_volatility_prior'], isNull); // needs 3 semesters
    expect(f['cgpa_prior'], 7.2);
    expect(f['prev_attendance'], 80); // semester 3 attendance (20%) not used
    expect(f['backlogs_reported_prev'], 1);
    expect(f['failed_first_attempts_prior'], 1); // semester 3 failure not used
    expect(f['failed_first_attempts_prev'], 1);
    expect(f['prev_subject_score_mean'], 50);
    expect(f['prev_subject_score_min'], 30);
    expect(f['school_10th'], 82);
    expect(f['school_12th'], isNull);
  });

  group('labels-v1', () {
    test('first-attempt failure in T', () {
      final h = history(semesters: [sem(1, 8), sem(2, 8)], subjects: [subj(2, 'OS', passed: false)]);
      expect(FeatureExtractor.labels(h, 2).risk, 1);
    });
    test('SGPA below 6.0', () {
      expect(FeatureExtractor.labels(history(semesters: [sem(1, 6.5), sem(2, 5.9)]), 2).risk, 1);
    });
    test('drop of 1.0 or more', () {
      expect(FeatureExtractor.labels(history(semesters: [sem(1, 8.5), sem(2, 7.5)]), 2).risk, 1);
      expect(FeatureExtractor.labels(history(semesters: [sem(1, 8.5), sem(2, 7.6)]), 2).risk, 0);
    });
    test('no outcome data means no label', () {
      final labels = FeatureExtractor.labels(history(semesters: [sem(1, 8)]), 2);
      expect(labels.risk, isNull);
      expect(labels.sgpa, isNull);
    });
  });

  test('training rows need a prior semester and an outcome', () {
    final h = history(semesters: [sem(1, 7), sem(2, 7.2), sem(4, 7.5)]);
    expect(FeatureExtractor.trainingSemesters(h), [2, 4]);
  });

  test('export: header, pseudonymous keys, no names or roll numbers', () {
    final result = TrainingDatasetExporter.export([history(semesters: [sem(1, 7), sem(2, 7.2)])]);
    final lines = result.csv.trim().split('\n');
    expect(lines.first.split(','), TrainingDatasetExporter.header);
    expect(result.rows, 1);
    expect(result.csv, isNot(contains('CS001')));
    expect(result.csv, isNot(contains('s1,')));
    expect(lines[1].split(',').first, FeatureExtractor.studentKey('s1'));
  });

  test('synthetic export is deterministic and has both classes', () {
    final a = TrainingDatasetExporter.export(SyntheticHistoryGenerator(seed: 7).generate(students: 200),
        dataSource: 'synthetic');
    final b = TrainingDatasetExporter.export(SyntheticHistoryGenerator(seed: 7).generate(students: 200),
        dataSource: 'synthetic');
    expect(a.csv, b.csv);
    final risk = a.csv.trim().split('\n').skip(1).map((l) => l.split(',')[l.split(',').length - 2]).toSet();
    expect(risk, containsAll(['0', '1']));
  });

  // Writes the synthetic training set used by the Python pipeline's tests:
  //   CLASSVAULT_WRITE_SYNTHETIC=ml/tests/data/synthetic_fv1.csv flutter test test/feature_extractor_test.dart
  test('write synthetic dataset for ml/', () {
    final path = Platform.environment['CLASSVAULT_WRITE_SYNTHETIC']!;
    final result = TrainingDatasetExporter.export(SyntheticHistoryGenerator().generate(), dataSource: 'synthetic');
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(result.csv);
    // ignore: avoid_print
    print('Wrote ${result.rows} rows for ${result.students} students to $path');
  }, skip: Platform.environment['CLASSVAULT_WRITE_SYNTHETIC'] == null);
}
