import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../data/models/models.dart';
import '../../analytics/engine/stats.dart';
import '../../analytics/engine/student_analytics.dart';

/// Mirrors `ml/feature_spec.json`. A test asserts the two stay identical;
/// change both (and bump [version]) together.
class FeatureSpec {
  const FeatureSpec._();

  static const version = 'fv1';
  static const labelVersion = 'labels-v1';

  static const names = [
    'target_semester',
    'n_prior_semesters',
    'prev_sgpa',
    'prev2_sgpa',
    'sgpa_mean_prior',
    'sgpa_slope_prior',
    'sgpa_volatility_prior',
    'cgpa_prior',
    'prev_percentage',
    'prev_attendance',
    'attendance_mean_prior',
    'attendance_slope_prior',
    'backlogs_reported_prev',
    'failed_first_attempts_prior',
    'failed_first_attempts_prev',
    'prev_subject_score_mean',
    'prev_subject_score_min',
    'school_10th',
    'school_12th',
  ];

  /// Plain-language names for explanations shown to faculty.
  static const labels = {
    'target_semester': 'Semester being predicted',
    'n_prior_semesters': 'Semesters of history',
    'prev_sgpa': 'Previous SGPA',
    'prev2_sgpa': 'SGPA two semesters ago',
    'sgpa_mean_prior': 'Average SGPA so far',
    'sgpa_slope_prior': 'SGPA trend',
    'sgpa_volatility_prior': 'SGPA variability',
    'cgpa_prior': 'CGPA',
    'prev_percentage': 'Previous semester %',
    'prev_attendance': 'Previous semester attendance',
    'attendance_mean_prior': 'Average attendance',
    'attendance_slope_prior': 'Attendance trend',
    'backlogs_reported_prev': 'Reported backlogs',
    'failed_first_attempts_prior': 'Subjects failed (first attempt)',
    'failed_first_attempts_prev': 'Subjects failed last semester',
    'prev_subject_score_mean': 'Average subject score last semester',
    'prev_subject_score_min': 'Lowest subject score last semester',
    'school_10th': '10th %',
    'school_12th': '12th %',
  };

  static const metaColumns = ['student_key', 'data_source'];
  static const labelColumns = ['label_risk', 'label_sgpa'];

  /// Label definition (see `labels-v1` in the spec).
  static const riskSgpaFloor = 6.0;
  static const riskSgpaDrop = 1.0;
}

class LabelValues {
  final double? risk; // 1.0 / 0.0 / null
  final double? sgpa;
  const LabelValues(this.risk, this.sgpa);
}

/// Computes model features for a student at a prediction point: the start
/// of [targetSemester]. Only data from semesters before it is used, so the
/// same code is leakage-safe for both training export and live prediction.
class FeatureExtractor {
  const FeatureExtractor._();

  static Map<String, double?> extract(StudentAcademicHistory h, int targetSemester) {
    final t = targetSemester;
    final prior = [
      for (final r in h.semesterResults)
        if (r.semesterNumber < t) r,
    ]..sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));
    SemesterResult? at(int sem) => prior.where((r) => r.semesterNumber == sem).firstOrNull;
    final prev = at(t - 1);
    final prev2 = at(t - 2);

    final sgpa = [for (final r in prior) if (r.sgpa != null) (r.semesterNumber.toDouble(), r.sgpa!)];
    final sgpaRecent = sgpa.length > AnalyticsThresholds.trendWindow
        ? sgpa.sublist(sgpa.length - AnalyticsThresholds.trendWindow)
        : sgpa;

    final attendance = StudentAnalyticsEngine.attendanceBySemester([
      for (final a in h.attendanceSummaries)
        if (a.semesterNumber < t)
          SubjectAttendance(
            semester: a.semesterNumber,
            subjectName: a.subjectName,
            percentage: a.percentage,
            held: a.classesHeld,
            attended: a.classesAttended,
          ),
    ]);
    final prevAttendance = attendance.where((p) => p.semester == t - 1).firstOrNull?.value;

    final firstAttempts = [
      for (final s in h.subjectResults)
        if (s.semesterNumber < t && s.attempt == 1) s,
    ];
    final prevScores = [
      for (final s in firstAttempts)
        if (s.semesterNumber == t - 1 && s.totalMarks != null && s.maxMarks != null && s.maxMarks! > 0)
          s.totalMarks! / s.maxMarks! * 100,
    ];

    double? school(String level) => h.schoolResults.where((s) => s.level == level).firstOrNull?.percentage;

    return {
      'target_semester': t.toDouble(),
      'n_prior_semesters': prior.length.toDouble(),
      'prev_sgpa': prev?.sgpa,
      'prev2_sgpa': prev2?.sgpa,
      'sgpa_mean_prior': sgpa.isEmpty ? null : Stats.mean([for (final p in sgpa) p.$2]),
      'sgpa_slope_prior': sgpaRecent.length < 2
          ? null
          : Stats.slope([for (final p in sgpaRecent) p.$1], [for (final p in sgpaRecent) p.$2]),
      'sgpa_volatility_prior': sgpa.length < AnalyticsThresholds.minPointsForConsistency
          ? null
          : Stats.residualStdDev([for (final p in sgpa) p.$1], [for (final p in sgpa) p.$2]),
      'cgpa_prior': prev?.cgpa ?? (sgpa.isEmpty ? null : Stats.mean([for (final p in sgpa) p.$2])),
      'prev_percentage': prev?.percentage,
      'prev_attendance': prevAttendance,
      'attendance_mean_prior': attendance.isEmpty ? null : Stats.mean([for (final p in attendance) p.value]),
      'attendance_slope_prior': attendance.length < 2
          ? null
          : Stats.slope([for (final p in attendance) p.semester.toDouble()], [for (final p in attendance) p.value]),
      'backlogs_reported_prev': prev?.backlogs.toDouble(),
      'failed_first_attempts_prior': firstAttempts.where((s) => s.passed == false).length.toDouble(),
      'failed_first_attempts_prev':
          firstAttempts.where((s) => s.semesterNumber == t - 1 && s.passed == false).length.toDouble(),
      'prev_subject_score_mean': prevScores.isEmpty ? null : Stats.mean(prevScores),
      'prev_subject_score_min': prevScores.isEmpty ? null : prevScores.reduce((a, b) => a < b ? a : b),
      'school_10th': school('10th'),
      'school_12th': school('12th'),
    };
  }

  /// Outcomes observed in [targetSemester] (training only).
  static LabelValues labels(StudentAcademicHistory h, int targetSemester) {
    final t = targetSemester;
    final current = h.semesterResults.where((r) => r.semesterNumber == t).firstOrNull;
    final previous = h.semesterResults.where((r) => r.semesterNumber == t - 1).firstOrNull;
    final firstAttempts = [
      for (final s in h.subjectResults)
        if (s.semesterNumber == t && s.attempt == 1 && s.passed != null) s,
    ];

    final sgpa = current?.sgpa;
    final hasEvidence = sgpa != null || firstAttempts.isNotEmpty;
    if (!hasEvidence) return LabelValues(null, sgpa);

    final failed = firstAttempts.any((s) => s.passed == false);
    final low = sgpa != null && sgpa < FeatureSpec.riskSgpaFloor;
    final drop = sgpa != null && previous?.sgpa != null && sgpa - previous!.sgpa! <= -FeatureSpec.riskSgpaDrop;
    return LabelValues(failed || low || drop ? 1 : 0, sgpa);
  }

  /// Semesters usable as training rows: the student has an outcome for T and
  /// at least one earlier semester result to predict from.
  static List<int> trainingSemesters(StudentAcademicHistory h) {
    final withResults = {for (final r in h.semesterResults) r.semesterNumber};
    final withSubjects = {for (final s in h.subjectResults) if (s.passed != null) s.semesterNumber};
    final candidates = {...withResults, ...withSubjects}.toList()..sort();
    return [
      for (final t in candidates)
        if (withResults.any((s) => s < t)) t,
    ];
  }

  /// Pseudonymous, stable key for exports (student ids are internal random
  /// ids; hashing keeps exports from being joined back without the app).
  static String studentKey(String studentId) =>
      sha256.convert(utf8.encode('classvault-student:$studentId')).toString().substring(0, 16);
}

/// Builds the training CSV consumed by the Python pipeline in `ml/`.
class TrainingDatasetExporter {
  const TrainingDatasetExporter._();

  static List<String> get header => [
        ...FeatureSpec.metaColumns,
        ...FeatureSpec.names,
        ...FeatureSpec.labelColumns,
      ];

  static ({String csv, int rows, int students}) export(
    List<StudentAcademicHistory> histories, {
    String dataSource = 'classvault',
  }) {
    final lines = <String>[header.join(',')];
    final students = <String>{};
    for (final h in histories) {
      for (final t in FeatureExtractor.trainingSemesters(h)) {
        final labels = FeatureExtractor.labels(h, t);
        if (labels.risk == null && labels.sgpa == null) continue;
        final features = FeatureExtractor.extract(h, t);
        students.add(h.student.id);
        lines.add([
          FeatureExtractor.studentKey(h.student.id),
          dataSource,
          for (final name in FeatureSpec.names) _fmt(features[name]),
          _fmt(labels.risk),
          _fmt(labels.sgpa),
        ].join(','));
      }
    }
    return (csv: '${lines.join('\n')}\n', rows: lines.length - 1, students: students.length);
  }

  static String _fmt(double? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return double.parse(v.toStringAsFixed(6)).toString();
  }
}
