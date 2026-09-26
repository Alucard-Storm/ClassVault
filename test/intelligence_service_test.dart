import 'dart:convert';
import 'dart:io';

import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/drift_attendance_service.dart';
import 'package:classvault/data/services/drift_intervention_service.dart';
import 'package:classvault/data/services/drift_prediction_service.dart';
import 'package:classvault/features/analytics/analytics_service.dart';
import 'package:classvault/features/intelligence/engine/attention_queue.dart';
import 'package:classvault/features/intelligence/intelligence_service.dart';
import 'package:classvault/features/prediction/prediction_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

String logisticModel() => jsonEncode((jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync())['models'] as List)
    .firstWhere((m) => m['family'] == 'logistic'));

final admin = AppUser(uid: 'admin', name: 'Admin', email: 'a', role: UserRole.admin);
final facultyA = AppUser(uid: 'fa', name: 'Dr. A', email: 'fa', role: UserRole.faculty, associatedId: 'f1');

void main() {
  late AppDatabase db;
  late IntelligenceService intel;
  late PredictionService predictions;
  late AnalyticsService analytics;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final academic = DriftAcademicService(db);
    final history = DriftAcademicHistoryService(db);
    analytics = AnalyticsService(academic: academic, attendance: DriftAttendanceService(db), history: history);
    final predictionRepo = DriftPredictionService(db);
    predictions = PredictionService(academic: academic, history: history, predictions: predictionRepo, analytics: analytics);
    intel = IntelligenceService(
      academic: academic, analytics: analytics, predictions: predictionRepo, interventions: DriftInterventionService(db),
    );

    await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
    await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'CSE'));
    await academic.addSemester(Semester(id: 'sem4', branchId: 'b', semesterNumber: 4));
    await academic.addSection(Section(id: 'secA', semesterId: 'sem4', name: 'A'));
    await academic.addSection(Section(id: 'secB', semesterId: 'sem4', name: 'B'));
    await academic.addSubject(Subject(id: 'sub', code: 'CS401', name: 'OS'));
    await academic.addSubjectMapping(SubjectMapping(id: 'm', sectionId: 'secA', subjectId: 'sub'));
    await academic.addFaculty(Faculty(id: 'f1', employeeId: 'E1', name: 'Dr. A', email: 'fa@x.y'));
    await academic.addFacultyAssignment(FacultyAssignment(id: 'fa', facultyId: 'f1', subjectMappingId: 'm'));
    await academic.addStudentsBulk([
      Student(id: 's1', rollNumber: 'CS001', name: 'Asha', sectionId: 'secA'),
      Student(id: 's2', rollNumber: 'CS002', name: 'Bala', sectionId: 'secB'),
    ], createAccounts: false);
    await history.upsertSemesterResults([
      for (final (id, sem, sgpa) in [('s1', 1, 6.4), ('s1', 2, 5.6), ('s1', 3, 5.1), ('s2', 1, 8.0), ('s2', 2, 7.0), ('s2', 3, 6.0)])
        SemesterResult(id: '$id$sem', studentId: id, semesterNumber: sem, sgpa: sgpa, backlogs: 1),
    ]);
    await history.upsertSubjectResults([
      for (final subject in ['Maths', 'Physics'])
        SubjectResult(id: 's1$subject', studentId: 's1', semesterNumber: 3, subjectName: subject,
            totalMarks: 31, maxMarks: 100, passed: false),
    ]);
  });

  tearDown(() => db.close());

  test('queue covers only the sections a user can see', () async {
    final forAdmin = await intel.attentionQueue(admin);
    final forFaculty = await intel.attentionQueue(facultyA);
    expect(forAdmin.map((i) => i.student.id).toSet(), {'s1', 's2'});
    expect(forFaculty.map((i) => i.student.id), ['s1']);
    expect(forFaculty.single.input.sectionLabel, 'CSE · Sem 4 · A');
  });

  test('notes: validation, access and follow-up status', () async {
    await expectLater(
      intel.addNote(studentId: 's2', type: 'meeting', note: 'x', user: facultyA),
      throwsA(isA<AccessDeniedException>()),
    );
    await expectLater(intel.addNote(studentId: 's1', type: 'gossip', note: 'x', user: facultyA), throwsArgumentError);
    await expectLater(intel.addNote(studentId: 's1', type: 'note', note: '  ', user: facultyA), throwsArgumentError);

    final followUp = await intel.addNote(
      studentId: 's1', type: 'meeting', note: 'Discussed workload', followUpOn: DateTime(2026, 10, 3), user: facultyA,
    );
    expect(followUp.status, 'open');
    final plain = await intel.addNote(studentId: 's1', type: 'note', note: 'FYI', user: facultyA);
    expect(plain.status, 'done');

    var queue = await intel.attentionQueue(facultyA, now: DateTime(2026, 9, 26));
    expect(queue.single.status, QueueStatus.inProgress);

    await intel.setStatus(followUp.id, 'done', admin);
    queue = await intel.attentionQueue(facultyA, now: DateTime(2026, 9, 26));
    expect(queue.single.status, QueueStatus.recentlyReviewed);

    final entries = await intel.interventionsFor('s1', facultyA);
    expect(entries, hasLength(2));
    expect(entries.every((e) => e.intervention.authorId == 'fa'), isTrue);
  });

  test('disagreeing with a risk prediction removes it from the priority', () async {
    final model = await predictions.importModel(logisticModel());
    await predictions.activate(model, acknowledgeWarnings: true);
    final sectionA = (await analytics.visibleSections(admin)).firstWhere((s) => s.section.id == 'secA');
    await predictions.generateForSection(sectionA, admin);
    final predictionId = (await predictions.historyFor('s1', admin)).single.record.id;

    expect((await predictions.historyFor('s1', admin)).single.record.band, 'elevated');
    final before = (await intel.attentionQueue(facultyA)).single;
    expect(before.reasons.any((r) => r.startsWith('Risk signal')), isTrue);

    await expectLater(
      intel.reviewPrediction(predictionId: predictionId, agree: false, reason: '', user: facultyA),
      throwsArgumentError,
    );
    await intel.reviewPrediction(
      predictionId: predictionId, agree: false, reason: 'Semester 3 dip was due to illness; recovered.', user: facultyA,
    );

    final after = (await intel.attentionQueue(facultyA)).single;
    expect(after.riskOverridden, isTrue);
    expect(after.priority, lessThan(before.priority));
    expect(after.reasons, contains('Faculty disagreed with the risk signal'));
    final reviews = await intel.reviewsOf(predictionId, 's1', facultyA);
    expect(reviews.single.intervention.reviewAssessment, 'disagree');
    expect(reviews.single.intervention.note, startsWith('Semester 3 dip'));
  });

  test('notes are removed with the student', () async {
    await intel.addNote(studentId: 's1', type: 'note', note: 'x', user: admin);
    await DriftAcademicService(db).deleteStudent('s1');
    expect(await db.select(db.interventions).get(), isEmpty);
  });
}
