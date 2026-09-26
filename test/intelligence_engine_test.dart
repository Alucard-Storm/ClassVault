import 'dart:convert';

import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/repositories/intervention_repository.dart';
import 'package:classvault/features/analytics/engine/student_analytics.dart';
import 'package:classvault/features/intelligence/engine/attention_queue.dart';
import 'package:classvault/features/intelligence/engine/readiness.dart';
import 'package:classvault/features/prediction/engine/explanation.dart';
import 'package:flutter_test/flutter_test.dart';

StudentAnalytics analytics({
  String id = 's1',
  String name = 'Asha',
  List<double> sgpa = const [],
  double? attendance,
  List<SubjectResult> subjects = const [],
  List<Assessment> assessments = const [],
}) {
  final student = Student(id: id, rollNumber: id.toUpperCase(), name: name, sectionId: 'sec');
  return StudentAnalyticsEngine.compute(StudentAcademicHistory(
    student: student,
    enrollments: const [],
    schoolResults: const [],
    semesterResults: [
      for (var i = 0; i < sgpa.length; i++)
        SemesterResult(id: '$id$i', studentId: id, semesterNumber: i + 1, sgpa: sgpa[i]),
    ],
    subjectResults: subjects,
    attendanceSummaries: [
      if (attendance != null)
        AttendanceSummary(id: '${id}a', studentId: id, semesterNumber: sgpa.length, subjectName: 'X', percentage: attendance),
    ],
    assessments: assessments,
  ));
}

Assessment lab(String id, double score) => Assessment(
    id: id, studentId: 's1', semesterNumber: 3, subjectName: 'DBMS', assessmentType: 'Lab', score: score, maxScore: 10);

PredictionView risk(String band, {String id = 'p1', double p = 0.7}) => PredictionView.of(PredictionRecord(
      id: id, studentId: 's1', task: 'risk', modelId: 'm', featureVersion: 'fv1', targetSemester: 4,
      probability: p, band: band, featuresJson: '{}', contributionsJson: jsonEncode([]),
      synthetic: false, generatedAt: DateTime(2026, 9, 1),
    ));

InterventionEntry entry(String type,
        {String status = 'done', DateTime? at, DateTime? followUp, String? predictionId, String? assessment}) =>
    InterventionEntry(
      Intervention(
        id: '$type${at?.day}', studentId: 's1', authorId: 'f1', type: type, note: 'n', status: status,
        followUpOn: followUp, predictionId: predictionId, reviewAssessment: assessment,
        createdAt: at ?? DateTime(2026, 9, 20), updatedAt: at ?? DateTime(2026, 9, 20),
      ),
      'Dr. F',
    );

QueueInput input(StudentAnalytics a, {PredictionView? latestRisk, List<InterventionEntry> interventions = const []}) =>
    QueueInput(analytics: a, sectionLabel: 'CSE · Sem 4 · A', latestRisk: latestRisk, interventions: interventions);

final now = DateTime(2026, 9, 26);

void main() {
  group('project readiness', () {
    test('strong when every evaluable criterion is met', () {
      final r = ProjectReadiness.assess(analytics(
        sgpa: [8.0, 8.2, 8.4],
        attendance: 92,
        subjects: [SubjectResult(id: 'x', studentId: 's1', semesterNumber: 3, subjectName: 'OS', passed: true)],
        assessments: [lab('l1', 8), lab('l2', 9)],
      ));
      expect(r.level, ReadinessLevel.strong);
      expect(r.evaluated, 6);
      expect(r.met, 6);
    });

    test('developing when one criterion is missed', () {
      final r = ProjectReadiness.assess(analytics(sgpa: [8.0, 8.2, 8.4], attendance: 80, assessments: [lab('l1', 9)]));
      // Backlogs: no data; attendance below 85%.
      expect(r.level, ReadinessLevel.developing);
      expect(r.criteria.firstWhere((c) => c.name == 'Attendance').result, CriterionResult.notMet);
    });

    test('not indicated when several criteria are missed', () {
      final r = ProjectReadiness.assess(analytics(sgpa: [6.0, 6.5, 5.5], attendance: 70));
      expect(r.level, ReadinessLevel.notIndicated);
    });

    test('not enough data for a new student', () {
      expect(ProjectReadiness.assess(analytics(sgpa: [8.5])).level, ReadinessLevel.insufficientData);
    });

    test('practical score only counts lab, practical and project work', () {
      final a = analytics(sgpa: [8], assessments: [
        lab('l1', 9),
        Assessment(id: 'q', studentId: 's1', semesterNumber: 1, subjectName: 'DBMS', assessmentType: 'Quiz', score: 2, maxScore: 10),
        Assessment(id: 'p', studentId: 's1', semesterNumber: 1, subjectName: 'SE', assessmentType: 'Assignment',
            title: 'Mini Project', score: 7, maxScore: 10),
      ]);
      expect(a.practicalAssessments, 2);
      expect(a.practicalScorePercent, 80);
    });
  });

  group('attention queue', () {
    test('ranks by signals and risk; skips students with nothing to review', () {
      final declining = analytics(id: 's1', name: 'Asha', sgpa: [8.2, 7.6, 7.0], attendance: 60);
      final steady = analytics(id: 's2', name: 'Ben', sgpa: [7.5, 7.6, 7.5], attendance: 90);
      final riskOnly = analytics(id: 's3', name: 'Chen', sgpa: [7.5, 7.6, 7.5], attendance: 90);

      final q = AttentionQueue.build([
        input(steady),
        input(riskOnly, latestRisk: risk('moderate')),
        input(declining, latestRisk: risk('elevated')),
      ], now: now);

      expect(q.map((i) => i.student.name), ['Asha', 'Chen']);
      // 2 attention signals (declining SGPA, low attendance) × 3 + elevated risk 4.
      expect(q.first.priority, 2 * QueueWeights.attentionSignal + QueueWeights.elevatedRisk);
      expect(q.first.reasons.last, 'Risk signal elevated (70%)');
      expect(q.every((i) => i.status == QueueStatus.needsReview), isTrue);
    });

    test('faculty disagreement overrides the risk signal', () {
      final a = analytics(sgpa: [7.5, 7.6, 7.5], attendance: 90);
      final q = AttentionQueue.build([
        input(a, latestRisk: risk('elevated'), interventions: [
          entry('prediction_review', predictionId: 'p1', assessment: 'disagree', at: DateTime(2026, 5, 1)),
        ]),
      ], now: now);
      expect(q, isEmpty); // nothing else to review
    });

    test('agreeing keeps the risk signal; review older than 30 days needs review again', () {
      final a = analytics(sgpa: [7.5, 7.6, 7.5], attendance: 90);
      final q = AttentionQueue.build([
        input(a, latestRisk: risk('elevated'), interventions: [
          entry('prediction_review', predictionId: 'p1', assessment: 'agree', at: DateTime(2026, 7, 1)),
        ]),
      ], now: now);
      expect(q.single.status, QueueStatus.needsReview);
      expect(q.single.riskOverridden, isFalse);
    });

    test('open follow-ups are in progress; overdue ones raise priority', () {
      final a = analytics(sgpa: [7.5, 7.6, 7.5], attendance: 90);
      final q = AttentionQueue.build([
        input(a, interventions: [
          entry('meeting', status: 'open', followUp: DateTime(2026, 9, 20), at: DateTime(2026, 9, 10)),
        ]),
      ], now: now);
      expect(q.single.status, QueueStatus.inProgress);
      expect(q.single.overdueFollowUp, DateTime(2026, 9, 20));
      expect(q.single.priority, QueueWeights.overdueFollowUp);
    });

    test('a recent completed note marks the student recently reviewed and sorts them later', () {
      final reviewed = analytics(id: 's1', name: 'Asha', sgpa: [8.2, 7.6, 7.0]);
      final fresh = analytics(id: 's2', name: 'Ben', sgpa: [8.2, 7.9, 7.6]);
      final q = AttentionQueue.build([
        input(reviewed, interventions: [entry('note', at: DateTime(2026, 9, 20))]),
        input(fresh),
      ], now: now);
      expect(q.map((i) => (i.student.name, i.status)), [
        ('Ben', QueueStatus.needsReview),
        ('Asha', QueueStatus.recentlyReviewed),
      ]);
    });
  });
}
