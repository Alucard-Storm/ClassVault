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
import 'package:classvault/features/auth/auth_provider.dart';
import 'package:classvault/features/pilot/engine/pilot_evaluation.dart';
import 'package:classvault/features/pilot/engine/pilot_report_markdown.dart';
import 'package:classvault/features/pilot/pilot_evaluation_screen.dart';
import 'package:classvault/features/pilot/pilot_service.dart';
import 'package:classvault/features/prediction/prediction_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

String model(String family) => jsonEncode((jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync())['models'] as List)
    .firstWhere((m) => m['family'] == family));

/// 12 students in two sections with three semesters of history. Predictions
/// are generated for semester 4, then semester 4 outcomes are imported.
Future<(AppDatabase, ProviderContainer)> setUpPilot() async {
  final db = AppDatabase(NativeDatabase.memory());
  final academic = DriftAcademicService(db);
  final history = DriftAcademicHistoryService(db);
  await DriftAuthService(db).createInitialAdmin(name: 'Admin', email: 'admin@college.edu', password: 'admin-pass');
  await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
  await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'CSE'));
  await academic.addSemester(Semester(id: 'sem4', branchId: 'b', semesterNumber: 4));
  await academic.addSection(Section(id: 'secA', semesterId: 'sem4', name: 'A'));
  await academic.addSection(Section(id: 'secB', semesterId: 'sem4', name: 'B'));
  final students = [
    for (var i = 0; i < 12; i++)
      Student(id: 's$i', rollNumber: 'CS${100 + i}', name: 'Pilot Student $i', sectionId: i.isEven ? 'secA' : 'secB'),
  ];
  await academic.addStudentsBulk(students, createAccounts: false);
  await history.upsertSemesterResults([
    for (var i = 0; i < 12; i++)
      for (var sem = 1; sem <= 3; sem++)
        SemesterResult(
          id: 's$i-$sem', studentId: 's$i', semesterNumber: sem,
          // Half the students decline towards failing, half are steady.
          sgpa: i < 6 ? 6.8 - sem * 0.5 : 7.8, backlogs: i < 6 ? sem - 1 : 0,
        ),
  ]);

  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  await container.read(authStateProvider.notifier).login('admin@college.edu', 'admin-pass');
  final user = container.read(authStateProvider).valueOrNull!;
  final predictions = container.read(predictionServiceProvider);
  for (final family in ['logistic', 'ridge']) {
    await predictions.activate(await predictions.importModel(model(family)), acknowledgeWarnings: true);
  }
  for (final section in await container.read(analyticsServiceProvider).visibleSections(user)) {
    await predictions.generateForSection(section, user);
  }

  // Semester 4 outcomes arrive: the declining students have difficulty.
  await history.commitImport(
    batch: ImportBatch(id: 'b4', fileName: 'sem4.xlsx', importedAt: DateTime.now(), recordCount: 12,
        rejectedRows: 1, warningCount: 2),
    semesterResults: [
      for (var i = 0; i < 12; i++)
        SemesterResult(id: 's$i-4', studentId: 's$i', semesterNumber: 4, sgpa: i < 6 ? 4.9 : 7.9),
    ],
  );
  return (db, container);
}

void main() {
  test('pilot service: admin only, test models excluded by default, outcomes matched', () async {
    final (db, c) = await setUpPilot();
    addTearDown(db.close);
    addTearDown(c.dispose);
    final admin = c.read(authStateProvider).valueOrNull!;
    final service = c.read(pilotServiceProvider);

    await expectLater(
      service.evaluate(AppUser(uid: 'f', name: 'F', email: 'f', role: UserRole.faculty)),
      throwsStateError,
    );

    final real = await service.evaluate(admin);
    expect(real.risk, isNull); // only test-model predictions exist
    // 1 of 13 rows rejected (8%) exceeds the 5% limit, so bad data blocks the pilot.
    final quality = real.checks.firstWhere((ch) => ch.name == 'Data quality');
    expect(quality.status, CheckStatus.fail);
    expect(quality.detail, startsWith('8% of imported rows rejected'));
    expect(real.verdict, PilotVerdict.doNotRely);

    final withTest = await service.evaluate(admin, includeTestModels: true);
    expect(withTest.risk!.n, 12);
    expect(withTest.risk!.positives, 6);
    expect(withTest.risk!.groups.map((g) => g.group), ['CSE · Sem 4 · A', 'CSE · Sem 4 · B']);
    expect(withTest.forecast!.n, 12);
    expect(withTest.forecast!.expectedCoverage, 0.8);
    expect(withTest.dataQuality.rejectedRows, 1);
    expect(withTest.dataQuality.warnings, 2);

    final markdown = PilotReportMarkdown.render(withTest);
    expect(markdown, contains('# ClassVault pilot evaluation'));
    expect(markdown, contains('| Predictions with outcomes | 12 (6 had difficulty) |'));
    expect(markdown, isNot(contains('Pilot Student')));
    expect(markdown, isNot(contains('CS10')));
  });

  for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1440, 900))]) {
    testWidgets('pilot evaluation screen on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (db, c) = await setUpPilot();
      addTearDown(db.close);
      addTearDown(c.dispose);

      final router = GoRouter(initialLocation: '/admin/pilot', routes: [
        GoRoute(path: '/admin/pilot', builder: (_, _) => const PilotEvaluationScreen()),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ));
      await tester.pumpAndSettle();

      expect(find.text(PilotVerdict.doNotRely.message), findsOneWidget);
      expect(find.text('Pilot criteria'), findsOneWidget);
      expect(find.textContaining('No risk predictions have known outcomes yet'), findsWidgets);
      expect(find.text('Export Report'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('Outcomes known'), findsNWidgets(2)); // risk + forecast
      expect(find.text('By section'), findsOneWidget);
      expect(find.text('sem4.xlsx'), findsOneWidget);
    });
  }
}
