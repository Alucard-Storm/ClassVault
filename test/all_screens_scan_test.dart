import 'dart:convert';
import 'dart:io';

import 'package:classvault/app.dart';
import 'package:classvault/core/router/app_router.dart';
import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/drift_attendance_service.dart';
import 'package:classvault/data/services/drift_auth_service.dart';
import 'package:classvault/data/services/providers.dart';
import 'package:classvault/features/analytics/analytics_service.dart';
import 'package:classvault/features/auth/auth_provider.dart';
import 'package:classvault/features/intelligence/intelligence_service.dart';
import 'package:classvault/features/prediction/prediction_service.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders every page of the app as each role, at phone, tablet and desktop
/// widths, and fails if any page throws or overflows. Each problem is listed
/// with the widget and source location that caused it.
///
/// Uses the real app shell, theme and router.

const sizes = {'phone': Size(390, 844), 'tablet': Size(800, 1024), 'desktop': Size(1440, 900)};

String model(String family) => jsonEncode((jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync())['models'] as List)
    .firstWhere((m) => m['family'] == family));

/// Realistic data: two sections, a faculty member teaching section A, eight
/// students with three semesters of history, attendance sessions, active
/// (test) models with predictions, notes, and an import batch.
Future<({AppDatabase db, String predictionId})> seed({bool empty = false}) async {
  final db = AppDatabase(NativeDatabase.memory());
  await DriftAuthService(db).createInitialAdmin(name: 'Admin User', email: 'admin@college.edu', password: 'admin-pass');
  if (empty) return (db: db, predictionId: '');

  final academic = DriftAcademicService(db);
  final history = DriftAcademicHistoryService(db);
  final attendance = DriftAttendanceService(db);
  await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
  await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'Computer Science and Engineering'));
  await academic.addSemester(Semester(id: 'sem4', branchId: 'b', semesterNumber: 4));
  await academic.addSemester(Semester(id: 'sem5', branchId: 'b', semesterNumber: 5));
  await academic.addSection(Section(id: 'secA', semesterId: 'sem4', name: 'Section A'));
  await academic.addSection(Section(id: 'secB', semesterId: 'sem4', name: 'Section B'));
  await academic.addSection(Section(id: 'sec5', semesterId: 'sem5', name: 'Section A'));
  for (final (id, code, name) in [('sub1', 'CS401', 'Database Management Systems'), ('sub2', 'CS402', 'Operating Systems')]) {
    await academic.addSubject(Subject(id: id, code: code, name: name));
    await academic.addSubjectMapping(SubjectMapping(id: 'm$id', sectionId: 'secA', subjectId: id));
  }
  await academic.addFaculty(Faculty(id: 'f1', employeeId: 'EMP001', name: 'Dr. Ananya Krishnamurthy', email: 'faculty@college.edu'));
  await academic.addFacultyAssignment(FacultyAssignment(id: 'fa1', facultyId: 'f1', subjectMappingId: 'msub1'));
  await academic.addFacultyAssignment(FacultyAssignment(id: 'fa2', facultyId: 'f1', subjectMappingId: 'msub2'));

  final students = [
    for (var i = 0; i < 8; i++)
      Student(id: 's$i', rollNumber: 'CS2023${i.toString().padLeft(3, '0')}',
          name: i == 0 ? 'Venkata Subramanian Raghunathan' : 'Student Number $i', sectionId: i < 6 ? 'secA' : 'secB'),
  ];
  await academic.addStudentsBulk(students);
  await history.commitImport(
    batch: ImportBatch(id: 'imp1', fileName: 'history_2023_batch_cse_full_export.xlsx', importedAt: DateTime(2026, 6, 1),
        recordCount: 40, notes: 'Semester results: 24, Attendance: 16', rejectedRows: 2, warningCount: 3),
    schoolResults: [for (final s in students) SchoolResult(id: 'sc${s.id}', studentId: s.id, level: '10th', percentage: 84)],
    semesterResults: [
      for (var i = 0; i < 8; i++)
        for (var sem = 1; sem <= 3; sem++)
          SemesterResult(id: 'r$i$sem', studentId: 's$i', semesterNumber: sem, sgpa: i < 3 ? 7.2 - sem * 0.6 : 7.9 + sem * 0.1,
              cgpa: 7.5, backlogs: i < 3 ? sem - 1 : 0),
    ],
    subjectResults: [
      for (var i = 0; i < 8; i++)
        SubjectResult(id: 'x$i', studentId: 's$i', semesterNumber: 3, subjectName: 'Database Management Systems',
            internalMarks: 20, practicalMarks: 22, externalMarks: i < 3 ? 10 : 50, maxMarks: 100, passed: i >= 3),
    ],
    attendanceSummaries: [
      for (var i = 0; i < 8; i++)
        AttendanceSummary(id: 'a$i', studentId: 's$i', semesterNumber: 3, subjectName: 'Operating Systems',
            classesHeld: 40, classesAttended: i < 3 ? 24 : 37, percentage: i < 3 ? 60 : 92.5),
    ],
    assessments: [
      for (var i = 0; i < 8; i++)
        for (var q = 0; q < 3; q++)
          Assessment(id: 'q$i$q', studentId: 's$i', semesterNumber: 3, subjectName: 'Operating Systems',
              assessmentType: q == 2 ? 'Lab' : 'Quiz', score: i < 3 ? 8.0 - q * 2 : 8, maxScore: 10,
              assessedOn: DateTime(2026, 3, 1 + q * 10)),
    ],
  );
  for (var d = 0; d < 4; d++) {
    final sessionId = 'sess$d';
    await attendance.addSession(
      AttendanceSession(id: sessionId, facultyId: 'f1', subjectId: d.isEven ? 'sub1' : 'sub2', sectionId: 'secA',
          date: DateTime(2026, 9, 20 + d), startTime: '10:00 AM', endTime: '11:00 AM'),
      [
        for (var i = 0; i < 6; i++)
          AttendanceRecord(id: '$sessionId-$i', sessionId: sessionId, studentId: 's$i', status: i == d ? 'absent' : 'present'),
      ],
    );
  }

  // Predictions (test models) and faculty activity, driven through the real services.
  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  final admin = AppUser(uid: 'admin', name: 'Admin', email: 'a', role: UserRole.admin);
  final predictions = container.read(predictionServiceProvider);
  for (final family in ['logistic', 'ridge']) {
    await predictions.activate(await predictions.importModel(model(family)), acknowledgeWarnings: true);
  }
  await predictions.importModel(model('gbt_classifier'));
  for (final section in await container.read(analyticsServiceProvider).visibleSections(admin)) {
    await predictions.generateForSection(section, admin);
  }
  final predictionId = (await predictions.historyFor('s0', admin)).firstWhere((p) => p.isRisk).record.id;
  final intel = container.read(intelligenceServiceProvider);
  await intel.addNote(studentId: 's0', type: 'meeting', note: 'Discussed attendance and workload in detail.',
      followUpOn: DateTime(2026, 9, 1), user: admin);
  await intel.reviewPrediction(predictionId: predictionId, agree: true, reason: 'Matches what I see in class.', user: admin);
  container.dispose();
  return (db: db, predictionId: predictionId);
}

/// Pumps the real app signed in as [login] (or signed out) at [path] and
/// returns the problems reported while rendering it.
Future<List<String>> visit(WidgetTester tester, AppDatabase db, Size size, String path, {(String, String)? login}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  final problems = <String>[];
  final original = FlutterError.onError;
  FlutterError.onError = (details) => problems.add(_describe(details));
  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  try {
    if (login != null) await container.read(authStateProvider.notifier).login(login.$1, login.$2);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const ClassVaultApp()));
    await _settle(tester);
    // Only attribute problems to [path]: drop those from the landing page.
    if (container.read(routerProvider).routerDelegate.currentConfiguration.uri.path != path) {
      problems.clear();
      container.read(routerProvider).go(path);
      await _settle(tester);
    }
    final location = container.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
    if (location != path) problems.add('Redirected to $location');
    final exception = tester.takeException();
    if (exception != null) problems.add('Exception: $exception');
  } finally {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    FlutterError.onError = original;
    tester.view.reset();
  }
  // Follow-on errors ("not laid out", semantics assertions) are symptoms of
  // a root layout error; keep only the roots when one exists.
  final roots = problems.where((p) => !_isCascade(p)).toSet().toList();
  return roots.isEmpty ? problems.toSet().toList() : roots;
}

bool _isCascade(String p) =>
    p.startsWith('RenderBox was not laid out') || p.contains('_needsLayout') || p.contains('parentDataDirty');

Future<void> _settle(WidgetTester tester) async {
  // Skeleton shimmers repeat forever; pump a bounded number of frames.
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _describe(FlutterErrorDetails d) {
  final text = d.toString();
  final first = d.exceptionAsString().split('\n').first;
  final where = RegExp(r'file:///[^\s]*?(lib/[^\s:]+:\d+)').firstMatch(text)?.group(1);
  final creator = RegExp(r'creator: ([^\n]+)').firstMatch(text)?.group(1)?.split(' ← ').take(4).join(' ← ');
  return [first, if (where != null) 'at $where', if (where == null && creator != null) 'in $creator'].join(' ');
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('scan every page at phone, tablet and desktop widths', (tester) async {
    // Silence framework logging while scanning so the report stays readable;
    // the exact original is restored because the test binding checks it.
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {};
    addTearDown(() => debugPrint = originalDebugPrint);
    final data = await seed();
    final empty = await seed(empty: true);
    const admin = ('admin@college.edu', 'admin-pass');
    const faculty = ('faculty@college.edu', 'faculty@college.edu');
    const student = ('CS2023000', 'CS2023000');

    final pages = <(String, (String, String)?, AppDatabase)>[
      ('/login', null, empty.db), // first-run setup
      ('/login', null, data.db), // login form
      for (final p in [
        '/admin', '/admin/academic', '/admin/subjects', '/admin/faculty', '/admin/faculty-assignment',
        '/admin/students', '/admin/students/import', '/admin/promotion', '/admin/academic-import',
        '/admin/models', '/admin/pilot', '/reports', '/analytics', '/analytics/attention',
        '/analytics/student/s0', '/analytics/student/s0/prediction/${data.predictionId}',
      ])
        (p, admin, data.db),
      for (final p in ['/admin', '/admin/students', '/admin/models', '/admin/pilot', '/analytics', '/analytics/attention', '/reports'])
        (p, admin, empty.db), // empty states
      for (final p in [
        '/faculty', '/faculty/mark-attendance', '/faculty/edit-attendance', '/reports',
        '/analytics', '/analytics/attention', '/analytics/student/s0',
      ])
        (p, faculty, data.db),
      for (final p in ['/student', '/reports']) (p, student, data.db),
    ];

    final report = <String>[];
    for (final (path, login, db) in pages) {
      final who = login == null ? 'signed out' : login.$1.split('@').first;
      final dataset = identical(db, empty.db) ? 'empty' : 'data';
      for (final entry in sizes.entries) {
        final problems = await visit(tester, db, entry.value, path, login: login);
        for (final p in problems) {
          report.add('$path [$who, $dataset, ${entry.key}] $p');
        }
      }
    }
    await data.db.close();
    await empty.db.close();

    debugPrint = originalDebugPrint;
    // ignore: avoid_print
    print(report.isEmpty ? 'SCAN: no problems' : 'SCAN: ${report.length} problems\n${report.join('\n')}');
    expect(report, isEmpty);
  }, timeout: const Timeout(Duration(minutes: 10)));
}
