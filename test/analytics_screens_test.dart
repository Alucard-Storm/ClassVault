import 'package:classvault/core/router/app_router.dart';
import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/drift_auth_service.dart';
import 'package:classvault/data/services/providers.dart';
import 'package:classvault/core/theme/app_theme.dart';
import 'package:classvault/features/analytics/class_analytics_screen.dart';
import 'package:classvault/features/analytics/student_insights_screen.dart';
import 'package:classvault/features/auth/auth_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Two sections; faculty f1 teaches only section A. Asha (A) has a declining
/// SGPA and an outstanding backlog; Ben (A) is steady; Chen is in B.
Future<AppDatabase> seed() async {
  final db = AppDatabase(NativeDatabase.memory());
  final academic = DriftAcademicService(db);
  final history = DriftAcademicHistoryService(db);
  // The first admin must exist before any other account, as in real use.
  await DriftAuthService(db).createInitialAdmin(name: 'Admin', email: 'admin@college.edu', password: 'admin-pass');

  await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
  await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'CSE'));
  await academic.addSemester(Semester(id: 'sem5', branchId: 'b', semesterNumber: 5));
  await academic.addSection(Section(id: 'secA', semesterId: 'sem5', name: 'A'));
  await academic.addSection(Section(id: 'secB', semesterId: 'sem5', name: 'B'));
  await academic.addSubject(Subject(id: 'sub', code: 'CS501', name: 'CN'));
  await academic.addSubjectMapping(SubjectMapping(id: 'mA', sectionId: 'secA', subjectId: 'sub'));
  await academic.addFaculty(Faculty(id: 'f1', employeeId: 'E1', name: 'Dr. F', email: 'f@college.edu'));
  await academic.addFacultyAssignment(FacultyAssignment(id: 'fa', facultyId: 'f1', subjectMappingId: 'mA'));

  await academic.addStudentsBulk([
    Student(id: 's1', rollNumber: 'CS001', name: 'Asha Rao', sectionId: 'secA'),
    Student(id: 's2', rollNumber: 'CS002', name: 'Ben Das', sectionId: 'secA'),
    Student(id: 's3', rollNumber: 'CS003', name: 'Chen Li', sectionId: 'secB'),
  ]);

  await history.upsertSemesterResults([
    SemesterResult(id: 'a1', studentId: 's1', semesterNumber: 1, sgpa: 8.2),
    SemesterResult(id: 'a2', studentId: 's1', semesterNumber: 2, sgpa: 7.6),
    SemesterResult(id: 'a3', studentId: 's1', semesterNumber: 3, sgpa: 7.0),
    SemesterResult(id: 'b1', studentId: 's2', semesterNumber: 1, sgpa: 7.5),
    SemesterResult(id: 'b2', studentId: 's2', semesterNumber: 2, sgpa: 7.6),
    SemesterResult(id: 'b3', studentId: 's2', semesterNumber: 3, sgpa: 7.5),
  ]);
  await history.upsertSubjectResults([
    SubjectResult(id: 'x', studentId: 's1', semesterNumber: 3, subjectName: 'OS', totalMarks: 30, maxMarks: 100, passed: false),
  ]);
  await history.upsertAttendanceSummaries([
    AttendanceSummary(id: 'y', studentId: 's1', semesterNumber: 3, subjectName: 'OS', percentage: 62),
  ]);
  return db;
}

Future<ProviderContainer> signIn(AppDatabase db, String login, String password) async {
  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  addTearDown(container.dispose);
  await container.read(authStateProvider.notifier).login(login, password);
  return container;
}

/// Mounts only the analytics routes (with the app theme), so the screens
/// under test render without the role dashboards.
Future<void> pumpAnalytics(WidgetTester tester, ProviderContainer container, String path) async {
  final router = GoRouter(initialLocation: path, routes: [
    GoRoute(
      path: '/analytics',
      builder: (_, _) => const ClassAnalyticsScreen(),
      routes: [
        GoRoute(
          path: 'student/:id',
          builder: (_, state) => StudentInsightsScreen(studentId: state.pathParameters['id']!),
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

void main() {
  for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1440, 900))]) {
    testWidgets('admin: class overview and student insights on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await seed();
      addTearDown(db.close);

      await pumpAnalytics(tester, await signIn(db, 'admin@college.edu', 'admin-pass'), '/analytics');

      // Section A is first; Asha raises attention, Ben is stable.
      expect(find.text('Asha Rao'), findsWidgets);
      expect(find.text('Ben Das'), findsWidgets);
      expect(find.text('Chen Li'), findsNothing);
      expect(find.text('Attention signals'), findsOneWidget);

      await tester.ensureVisible(find.text('Asha Rao').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Asha Rao').first);
      await tester.pumpAndSettle();

      expect(find.text('Student Insights'), findsWidgets);
      expect(find.text('1 outstanding backlog'), findsOneWidget);
      expect(find.textContaining('Attendance 62.0% in semester 3'), findsOneWidget);
      expect(find.textContaining('SGPA declining'), findsOneWidget);
    });
  }

  testWidgets('faculty only sees assigned sections and their students', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await seed();
    addTearDown(db.close);

    final c = await signIn(db, 'f@college.edu', 'f@college.edu');
    await pumpAnalytics(tester, c, '/analytics');
    expect(find.text('Asha Rao'), findsWidgets);
    expect(find.text('Chen Li'), findsNothing);

    // Chen is in section B, which this faculty member does not teach.
    await pumpAnalytics(tester, c, '/analytics/student/s3');
    expect(find.text('Student not available'), findsOneWidget);
  });

  test('route guard: analytics is for admin and faculty only', () {
    AppUser as(UserRole role) => AppUser(uid: 'u', name: 'n', email: 'e', role: role);
    for (final path in ['/analytics', '/analytics/student/s1']) {
      expect(appRedirect(user: as(UserRole.admin), isLoading: false, path: path), isNull);
      expect(appRedirect(user: as(UserRole.faculty), isLoading: false, path: path), isNull);
      expect(appRedirect(user: as(UserRole.student), isLoading: false, path: path), '/student');
      expect(appRedirect(user: null, isLoading: false, path: path), '/login');
    }
  });
}
