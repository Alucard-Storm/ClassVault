import 'dart:math' as math;

import '../../../data/models/models.dart';

/// Generates plausible-looking but entirely fictional academic histories, so
/// the ML pipeline can be exercised end to end before real data exists.
///
/// Every export built from this is tagged `data_source = synthetic`, and
/// models trained on it are flagged as test-only in the app.
class SyntheticHistoryGenerator {
  final math.Random _rng;

  SyntheticHistoryGenerator({int seed = 42}) : _rng = math.Random(seed);

  static const _subjects = ['Maths', 'Programming', 'Electronics', 'Physics', 'Communication'];

  List<StudentAcademicHistory> generate({int students = 600, int maxSemester = 8}) {
    return [for (var i = 0; i < students; i++) _student(i, maxSemester)];
  }

  StudentAcademicHistory _student(int index, int maxSemester) {
    final id = 'syn_$index';
    final student = Student(id: id, rollNumber: 'SYN${index.toString().padLeft(4, '0')}', name: 'Synthetic $index', sectionId: 'syn');

    // Latent traits: ability shifts the level, drift the direction over time.
    final ability = _normal();
    final drift = _normal() * 0.12;
    final attendanceBase = (82 + 7 * ability + _normal() * 5).clamp(40, 100).toDouble();
    final attendanceDrift = _normal() * 2.0;
    // Students are at different points in their programme.
    final semesters = 2 + _rng.nextInt(maxSemester - 1);

    final semesterResults = <SemesterResult>[];
    final subjectResults = <SubjectResult>[];
    final attendance = <AttendanceSummary>[];
    var outstanding = 0;
    var sgpaSum = 0.0;

    for (var sem = 1; sem <= semesters; sem++) {
      final att = (attendanceBase + attendanceDrift * (sem - 1) + _normal() * 3).clamp(30, 100).toDouble();
      final shock = _rng.nextDouble() < 0.07 ? -1.2 * _rng.nextDouble() - 0.4 : 0.0; // occasional bad semester
      final sgpa = (7.0 + 0.9 * ability + drift * (sem - 1) + 0.035 * (att - 80) + shock + _normal() * 0.35)
          .clamp(3.0, 10.0)
          .toDouble();

      var failed = 0;
      for (final subject in _subjects) {
        final score = (sgpa * 9 + _normal() * 8).clamp(5, 100).toDouble();
        final passed = score >= 40;
        if (!passed) failed++;
        subjectResults.add(SubjectResult(
          id: '$id-$sem-$subject', studentId: id, semesterNumber: sem, subjectName: subject,
          totalMarks: _round(score), maxMarks: 100, passed: passed,
        ));
        if (!passed && _rng.nextDouble() < 0.7) {
          subjectResults.add(SubjectResult(
            id: '$id-$sem-$subject-2', studentId: id, semesterNumber: sem, subjectName: subject,
            totalMarks: _round(40 + _rng.nextDouble() * 15), maxMarks: 100, passed: true, attempt: 2,
          ));
          failed--; // cleared later
        }
        final held = 40 + _rng.nextInt(10);
        final attended = (held * (att + _normal() * 4).clamp(0, 100) / 100).round().clamp(0, held);
        attendance.add(AttendanceSummary(
          id: '$id-$sem-$subject-att', studentId: id, semesterNumber: sem, subjectName: subject,
          classesHeld: held, classesAttended: attended, percentage: _round(attended / held * 100),
        ));
      }
      outstanding = math.max(0, outstanding + failed);
      sgpaSum += sgpa;

      semesterResults.add(SemesterResult(
        id: '$id-$sem', studentId: id, semesterNumber: sem,
        sgpa: _round(sgpa, 2),
        percentage: _round((sgpa * 9.5 + _normal() * 2).clamp(0, 100).toDouble()),
        cgpa: _round(sgpaSum / sem, 2),
        backlogs: outstanding,
      ));
    }

    return StudentAcademicHistory(
      student: student,
      enrollments: [
        StudentEnrollment(id: '$id-enr', studentId: id, sectionId: 'syn', semesterNumber: semesters + 1, startedAt: DateTime(2026)),
      ],
      schoolResults: [
        SchoolResult(id: '$id-10', studentId: id, level: '10th', percentage: _round((75 + 8 * ability + _normal() * 6).clamp(35, 100).toDouble())),
        if (_rng.nextDouble() < 0.9)
          SchoolResult(id: '$id-12', studentId: id, level: '12th', percentage: _round((72 + 8 * ability + _normal() * 6).clamp(35, 100).toDouble())),
      ],
      semesterResults: semesterResults,
      subjectResults: subjectResults,
      // Some students have no attendance history, to exercise missing data.
      attendanceSummaries: _rng.nextDouble() < 0.85 ? attendance : const [],
      assessments: const [],
    );
  }

  double _normal() {
    // Box–Muller.
    final u1 = 1 - _rng.nextDouble();
    final u2 = _rng.nextDouble();
    return math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2);
  }

  static double _round(double v, [int places = 1]) => double.parse(v.toStringAsFixed(places));
}
