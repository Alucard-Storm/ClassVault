import 'dart:convert';
import 'dart:io';

import 'package:classvault/core/theme/app_theme.dart';
import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/drift_auth_service.dart';
import 'package:classvault/data/services/providers.dart';
import 'package:classvault/features/analytics/analytics_service.dart';
import 'package:classvault/features/analytics/class_analytics_screen.dart';
import 'package:classvault/features/analytics/student_insights_screen.dart';
import 'package:classvault/features/auth/auth_provider.dart';
import 'package:classvault/features/faculty/faculty_dashboard.dart';
import 'package:classvault/features/intelligence/attention_queue_screen.dart';
import 'package:classvault/features/intelligence/attention_summary_card.dart';
import 'package:classvault/features/prediction/prediction_explanation_screen.dart';
import 'package:classvault/features/prediction/prediction_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

String logisticModel() => jsonEncode((jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync())['models'] as List)
    .firstWhere((m) => m['family'] == 'logistic'));

/// Faculty "Dr. A" teaches section A: Asha (struggling, with a risk
/// prediction) and Ben (strong, project-ready indicators).
Future<(AppDatabase, ProviderContainer)> setUpApp() async {
  final db = AppDatabase(NativeDatabase.memory());
  final academic = DriftAcademicService(db);
  final history = DriftAcademicHistoryService(db);
  await DriftAuthService(db).createInitialAdmin(name: 'Admin', email: 'admin@college.edu', password: 'admin-pass');
  await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
  await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'CSE'));
  await academic.addSemester(Semester(id: 'sem4', branchId: 'b', semesterNumber: 4));
  await academic.addSection(Section(id: 'secA', semesterId: 'sem4', name: 'A'));
  await academic.addSubject(Subject(id: 'sub', code: 'CS401', name: 'OS'));
  await academic.addSubjectMapping(SubjectMapping(id: 'm', sectionId: 'secA', subjectId: 'sub'));
  await academic.addFaculty(Faculty(id: 'f1', employeeId: 'E1', name: 'Dr. A', email: 'fa@college.edu'));
  await academic.addFacultyAssignment(FacultyAssignment(id: 'fa', facultyId: 'f1', subjectMappingId: 'm'));
  await academic.addStudentsBulk([
    Student(id: 's1', rollNumber: 'CS001', name: 'Asha Rao', sectionId: 'secA'),
    Student(id: 's2', rollNumber: 'CS002', name: 'Ben Das', sectionId: 'secA'),
  ], createAccounts: false);
  await history.upsertSemesterResults([
    for (final (id, sem, sgpa) in [('s1', 1, 6.4), ('s1', 2, 5.6), ('s1', 3, 5.1), ('s2', 1, 8.1), ('s2', 2, 8.3), ('s2', 3, 8.4)])
      SemesterResult(id: '$id$sem', studentId: id, semesterNumber: sem, sgpa: sgpa, backlogs: id == 's1' ? 2 : 0),
  ]);
  await history.upsertSubjectResults([
    SubjectResult(id: 'x1', studentId: 's1', semesterNumber: 3, subjectName: 'Maths', totalMarks: 31, maxMarks: 100, passed: false),
    SubjectResult(id: 'x2', studentId: 's2', semesterNumber: 3, subjectName: 'Maths', totalMarks: 88, maxMarks: 100, passed: true),
  ]);
  await history.upsertAttendanceSummaries([
    AttendanceSummary(id: 'a1', studentId: 's1', semesterNumber: 3, subjectName: 'Maths', percentage: 64),
    AttendanceSummary(id: 'a2', studentId: 's2', semesterNumber: 3, subjectName: 'Maths', percentage: 93),
  ]);
  await history.addAssessments([
    Assessment(id: 'l1', studentId: 's2', semesterNumber: 3, subjectName: 'OS', assessmentType: 'Lab', score: 9, maxScore: 10),
  ]);

  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  await container.read(authStateProvider.notifier).login('fa@college.edu', 'fa@college.edu');
  final user = container.read(authStateProvider).valueOrNull!;
  final service = container.read(predictionServiceProvider);
  // Models are imported by an admin; faculty can generate predictions.
  final admin = AppUser(uid: 'admin', name: 'Admin', email: 'a', role: UserRole.admin);
  final model = await service.importModel(logisticModel(), importedBy: admin.uid);
  await service.activate(model, acknowledgeWarnings: true);
  final section = (await container.read(analyticsServiceProvider).visibleSections(user)).single;
  await service.generateForSection(section, user);
  return (db, container);
}

Future<void> pumpAt(WidgetTester tester, ProviderContainer container, String path) async {
  final router = GoRouter(initialLocation: path, routes: [
    GoRoute(path: '/faculty', builder: (_, _) => const FacultyDashboard()),
    GoRoute(
      path: '/analytics',
      builder: (_, _) => const ClassAnalyticsScreen(),
      routes: [
        GoRoute(path: 'attention', builder: (_, _) => const AttentionQueueScreen()),
        GoRoute(
          path: 'student/:id',
          builder: (_, s) => StudentInsightsScreen(studentId: s.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'prediction/:pid',
              builder: (_, s) => PredictionExplanationScreen(
                  studentId: s.pathParameters['id']!, predictionId: s.pathParameters['pid']!),
            ),
          ],
        ),
      ],
    ),
  ]);
  addTearDown(router.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  ));
  await tester.pumpAndSettle();
}

Future<(AppDatabase, ProviderContainer)> start(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final (db, c) = await setUpApp();
  addTearDown(db.close);
  addTearDown(c.dispose);
  return (db, c);
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> tapChip(WidgetTester tester, String label) async {
  final f = find.widgetWithText(ChoiceChip, label);
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1440, 900))]) {
    testWidgets('attention queue lists and filters students on $label', (tester) async {
      final (_, c) = await start(tester, size);
      await pumpAt(tester, c, '/analytics/attention');

      expect(find.text('Asha Rao'), findsOneWidget);
      expect(find.text('Ben Das'), findsNothing); // nothing to review
      expect(find.textContaining('Risk signal elevated'), findsOneWidget);
      expect(find.text('Needs review'), findsWidgets);

      await tapChip(tester, 'In progress');
      expect(find.text('Asha Rao'), findsNothing);
      await tapChip(tester, 'Needs review');
      await tapText(tester, 'Asha Rao');
      expect(find.text('Notes & interventions'), findsOneWidget);
    });

    testWidgets('notes, readiness and prediction review on $label', (tester) async {
      final (_, c) = await start(tester, size);
      await pumpAt(tester, c, '/analytics/student/s1');

      expect(find.textContaining('Project-readiness indicators:'), findsOneWidget);
      await tapText(tester, 'Add Note');
      await tester.enterText(find.byType(TextFormField).last, 'Met to discuss attendance; agreed weekly check-ins.');
      await tapText(tester, 'Save');
      expect(find.text('Met to discuss attendance; agreed weekly check-ins.'), findsOneWidget);
      expect(find.text('Meeting'), findsOneWidget);

      await tapText(tester, 'Why this signal?');
      expect(find.text('Faculty review'), findsOneWidget);
      await tapText(tester, 'Disagree');
      await tapText(tester, 'Record Review');
      expect(find.text('Say why you disagree'), findsOneWidget); // reason required
      await tester.enterText(find.byType(TextFormField).last, 'Illness in semester 3; now recovered.');
      await tapText(tester, 'Record Review');
      expect(find.textContaining('disagreed on'), findsOneWidget);

      // The queue now shows the override instead of the risk signal.
      await pumpAt(tester, c, '/analytics/attention');
      await tapChip(tester, 'All (1)');
      expect(find.text('Risk overridden by faculty'), findsOneWidget);
      expect(find.textContaining('Risk signal elevated'), findsNothing);
    });

    testWidgets('class overview shows trend, opportunities and queue link on $label', (tester) async {
      final (_, c) = await start(tester, size);
      await pumpAt(tester, c, '/analytics');
      expect(find.text('Class trend'), findsOneWidget);
      expect(find.text('Opportunity indicators'), findsOneWidget);
      expect(find.byTooltip('Project-readiness indicators: strong'), findsOneWidget); // Ben
      await tapText(tester, 'Attention Queue');
      expect(find.text('Asha Rao'), findsOneWidget);
    });

    testWidgets('faculty dashboard shows the attention summary on $label', (tester) async {
      final (_, c) = await start(tester, size);
      await pumpAt(tester, c, '/faculty');
      expect(find.text('1 student to review'), findsOneWidget);
      await tapText(tester, 'Attention Queue');
      expect(find.text('Asha Rao'), findsOneWidget);
    });

    testWidgets('attention summary card links to the queue on $label', (tester) async {
      final (_, c) = await start(tester, size);
      final router = GoRouter(initialLocation: '/home', routes: [
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(
            body: Padding(padding: EdgeInsets.all(24), child: AttentionSummaryCard()),
          ),
        ),
        GoRoute(path: '/analytics/attention', builder: (_, _) => const AttentionQueueScreen()),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ));
      await tester.pumpAndSettle();
      expect(find.text('1 student to review'), findsOneWidget);
      await tapText(tester, 'Attention Queue');
      expect(find.text('Asha Rao'), findsOneWidget);
    });
  }

}
