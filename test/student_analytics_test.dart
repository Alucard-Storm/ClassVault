import 'package:classvault/data/models/models.dart';
import 'package:classvault/features/analytics/engine/student_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

final student = Student(id: 's1', rollNumber: 'CS001', name: 'Asha', sectionId: 'sec');

StudentAcademicHistory history({
  List<SemesterResult> semesters = const [],
  List<SubjectResult> subjects = const [],
  List<AttendanceSummary> attendance = const [],
  List<Assessment> assessments = const [],
}) =>
    StudentAcademicHistory(
      student: student,
      enrollments: [StudentEnrollment(id: 'e', studentId: 's1', sectionId: 'sec', semesterNumber: 5, startedAt: DateTime(2026))],
      schoolResults: [SchoolResult(id: 'x', studentId: 's1', level: '10th', percentage: 82)],
      semesterResults: semesters,
      subjectResults: subjects,
      attendanceSummaries: attendance,
      assessments: assessments,
    );

SemesterResult sem(int n, {double? sgpa, double? pct, double? cgpa, int backlogs = 0}) =>
    SemesterResult(id: 'r$n', studentId: 's1', semesterNumber: n, sgpa: sgpa, percentage: pct, cgpa: cgpa, backlogs: backlogs);

AttendanceSummary att(int s, String subject, double pct, {int? held, int? attended}) => AttendanceSummary(
    id: 'a$s$subject', studentId: 's1', semesterNumber: s, subjectName: subject, percentage: pct,
    classesHeld: held, classesAttended: attended);

SubjectResult subj(int s, String name, {double? total, double? max = 100, bool? passed, int attempt = 1}) =>
    SubjectResult(id: '$s$name$attempt', studentId: 's1', semesterNumber: s, subjectName: name,
        totalMarks: total, maxMarks: max, passed: passed, attempt: attempt);

void main() {
  group('performance', () {
    test('improving SGPA trend (the plan example: 7.1 → 7.4 → 7.8 → 8.1)', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [
        sem(1, sgpa: 7.1), sem(2, sgpa: 7.4), sem(3, sgpa: 7.8), sem(4, sgpa: 8.1),
      ]));
      expect(a.performanceMetric, 'SGPA');
      expect(a.performanceTrend.direction, TrendDirection.improving);
      expect(a.performanceTrend.slope, closeTo(0.34, 0.001));
      expect(a.cgpa, closeTo(7.6, 0.001));
      expect(a.cgpaEstimated, isTrue);
      expect(a.latestPerformance, 8.1);
      // (7.4·1 + 7.8·2 + 8.1·3) / 6
      expect(a.recentWeightedAverage, closeTo(7.883, 0.001));
      expect(a.consistency, Consistency.consistent);
      expect(a.signals.map((s) => s.level), contains(SignalLevel.positive));
    });

    test('trend uses only the last 4 semesters', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [
        sem(1, sgpa: 5.0), sem(2, sgpa: 8.0), sem(3, sgpa: 8.0), sem(4, sgpa: 8.0), sem(5, sgpa: 8.0),
      ]));
      expect(a.performanceTrend.direction, TrendDirection.stable);
      expect(a.performanceTrend.points, 4);
    });

    test('declining SGPA raises an attention signal with an explanation', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [
        sem(1, sgpa: 8.2), sem(2, sgpa: 7.6), sem(3, sgpa: 7.0),
      ]));
      expect(a.performanceTrend.direction, TrendDirection.declining);
      final signal = a.signals.firstWhere((s) => s.level == SignalLevel.attention);
      expect(signal.message, contains('−0.60 SGPA per semester'));
      expect(a.highestSignal, SignalLevel.attention);
    });

    test('high marks but volatile is distinguished from consistent', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [
        sem(1, sgpa: 9.2), sem(2, sgpa: 7.6), sem(3, sgpa: 9.3), sem(4, sgpa: 7.7),
      ]));
      expect(a.consistency, Consistency.variable);
      expect(a.signals.any((s) => s.level == SignalLevel.monitor), isTrue);
    });

    test('reported CGPA is preferred over the estimate', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [sem(1, sgpa: 7.0, cgpa: 7.0), sem(2, sgpa: 8.0, cgpa: 7.45)]));
      expect(a.cgpa, 7.45);
      expect(a.cgpaEstimated, isFalse);
    });

    test('falls back to percentage when there is no SGPA', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [sem(1, pct: 60), sem(2, pct: 64), sem(3, pct: 69)]));
      expect(a.performanceMetric, 'Percentage');
      expect(a.performanceTrend.direction, TrendDirection.improving);
    });

    test('one semester is insufficient for a trend', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [sem(1, sgpa: 7)]));
      expect(a.performanceTrend.direction, TrendDirection.insufficientData);
      expect(a.consistency, Consistency.insufficientData);
      expect(a.signals, isEmpty);
    });
  });

  group('attendance', () {
    test('weighted by classes when counts exist; low subjects in latest semester', () {
      final a = StudentAnalyticsEngine.compute(history(attendance: [
        att(4, 'DBMS', 90, held: 40, attended: 36),
        att(4, 'OS', 80, held: 60, attended: 48),
        att(5, 'CN', 70),
        att(5, 'AI', 64),
      ]));
      expect(a.attendanceSeries[0].value, closeTo(84, 0.001)); // 84/100
      expect(a.attendanceSeries[1].value, closeTo(67, 0.001)); // mean, no counts
      expect(a.attendanceTrend.direction, TrendDirection.declining);
      expect(a.lowAttendanceSubjects.map((s) => s.subjectName), ['AI', 'CN']);
      expect(a.signals.first.message, contains('Attendance 67.0% in semester 5'));
    });

    test('session attendance fills gaps but imported figures win', () {
      final sessions = [
        for (var i = 0; i < 4; i++)
          AttendanceSession(id: 'x$i', facultyId: 'f', subjectId: 'sub_cn', sectionId: 'sec',
              date: DateTime(2026, 9, i + 1), startTime: '', endTime: ''),
        AttendanceSession(id: 'y', facultyId: 'f', subjectId: 'sub_ai', sectionId: 'sec',
            date: DateTime(2026, 9, 9), startTime: '', endTime: ''),
      ];
      final records = [
        for (var i = 0; i < 3; i++) AttendanceRecord(id: 'r$i', sessionId: 'x$i', studentId: 's1', status: 'present'),
        AttendanceRecord(id: 'r3', sessionId: 'x3', studentId: 's1', status: 'absent'),
        AttendanceRecord(id: 'r4', sessionId: 'y', studentId: 's1', status: 'present'),
      ];
      final live = StudentAnalyticsEngine.attendanceFromSessions(
        studentId: 's1', semester: 5, sectionSessions: sessions, records: records,
        subjectNames: {'sub_cn': 'CN', 'sub_ai': 'AI'},
      );
      expect(live.firstWhere((l) => l.subjectName == 'CN').percentage, 75);

      final a = StudentAnalyticsEngine.compute(history(attendance: [att(5, 'AI', 50)]), sessionAttendance: live);
      expect(a.attendance.firstWhere((x) => x.subjectName == 'AI').percentage, 50); // imported wins
      expect(a.attendance.firstWhere((x) => x.subjectName == 'CN').fromSessions, isTrue);
    });
  });

  group('subjects & backlogs', () {
    test('outstanding, cleared and repeated backlogs', () {
      final a = StudentAnalyticsEngine.compute(history(subjects: [
        subj(3, 'DBMS', total: 30, passed: false),
        subj(3, 'DBMS', total: 45, passed: true, attempt: 2), // cleared
        subj(3, 'OS', total: 20, passed: false),
        subj(3, 'OS', total: 25, passed: false, attempt: 2), // outstanding & repeated
        subj(4, 'CN', total: 70, passed: true),
      ], semesters: [sem(4, sgpa: 6, backlogs: 3)]));
      expect(a.backlogs.derivedFromSubjects, isTrue);
      expect(a.backlogs.current, 1);
      expect(a.backlogs.outstanding.single.subjectName, 'OS');
      expect(a.backlogs.cleared.single.subjectName, 'DBMS');
      expect(a.backlogs.repeated.single.subjectName, 'OS');
      expect(a.backlogs.reportedCount, 3);
      expect(a.signals.first.message, '1 outstanding backlog');
    });

    test('falls back to the reported backlog count without pass/fail data', () {
      final a = StudentAnalyticsEngine.compute(history(semesters: [sem(1, sgpa: 6, backlogs: 2)]));
      expect(a.backlogs.derivedFromSubjects, isFalse);
      expect(a.backlogs.current, 2);
    });

    test('relative strengths and weaknesses against the student\'s own average', () {
      final a = StudentAnalyticsEngine.compute(history(subjects: [
        subj(3, 'DBMS', total: 90), subj(3, 'OS', total: 60), subj(3, 'CN', total: 75), subj(3, 'AI', total: 75),
      ]));
      final standing = {for (final s in a.subjects) s.subjectName: s.standing};
      expect(standing, {
        'AI': SubjectStanding.typical,
        'CN': SubjectStanding.typical,
        'DBMS': SubjectStanding.strength,
        'OS': SubjectStanding.weakness,
      });
    });

    test('assessment trend within a subject', () {
      Assessment q(int day, double score) => Assessment(
          id: 'q$day', studentId: 's1', semesterNumber: 5, subjectName: 'CN', assessmentType: 'Quiz',
          score: score, maxScore: 10, assessedOn: DateTime(2026, 9, day));
      final a = StudentAnalyticsEngine.compute(history(assessments: [q(20, 5), q(1, 9), q(10, 7)]));
      final t = a.assessmentTrends.single;
      expect(t.scores.map((p) => p.value), [90, 70, 50]); // date order
      expect(t.trend.direction, TrendDirection.declining);
    });
  });

  test('class summary counts', () {
    final improving = StudentAnalyticsEngine.compute(history(semesters: [sem(1, sgpa: 7), sem(2, sgpa: 7.5)]));
    final declining = StudentAnalyticsEngine.compute(history(semesters: [sem(1, sgpa: 8), sem(2, sgpa: 7.5)]));
    final empty = StudentAnalyticsEngine.compute(history());
    final summary = StudentAnalyticsEngine.summarize([improving, declining, empty]);
    expect(summary.studentCount, 3);
    expect(summary.withHistory, 2);
    expect(summary.attention, 1);
    expect(summary.stable, 1);
    expect(summary.improving, 1);
    expect(summary.averageCgpa, closeTo(7.5, 0.001));
  });
}
