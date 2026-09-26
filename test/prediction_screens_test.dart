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
import 'package:classvault/features/analytics/analytics_widgets.dart';
import 'package:classvault/features/analytics/class_analytics_screen.dart';
import 'package:classvault/features/analytics/student_insights_screen.dart';
import 'package:classvault/features/auth/auth_provider.dart';
import 'package:classvault/features/prediction/prediction_explanation_screen.dart';
import 'package:classvault/features/prediction/prediction_models_screen.dart';
import 'package:classvault/features/prediction/prediction_service.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

final fixtureModels = [
  for (final m in (jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync())['models'] as List))
    jsonEncode(m),
];
String modelOf(String family) => fixtureModels.firstWhere((m) => (jsonDecode(m) as Map)['family'] == family);

Future<(AppDatabase, ProviderContainer)> setUpApp({bool activate = true}) async {
  final db = AppDatabase(NativeDatabase.memory());
  final academic = DriftAcademicService(db);
  await DriftAuthService(db).createInitialAdmin(name: 'Admin', email: 'admin@college.edu', password: 'admin-pass');
  await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
  await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'CSE'));
  await academic.addSemester(Semester(id: 'sem4', branchId: 'b', semesterNumber: 4));
  await academic.addSection(Section(id: 'secA', semesterId: 'sem4', name: 'A'));
  await academic.addStudentsBulk([Student(id: 's1', rollNumber: 'CS001', name: 'Asha Rao', sectionId: 'secA')],
      createAccounts: false);
  await DriftAcademicHistoryService(db).upsertSemesterResults([
    SemesterResult(id: 'a1', studentId: 's1', semesterNumber: 1, sgpa: 8.2),
    SemesterResult(id: 'a2', studentId: 's1', semesterNumber: 2, sgpa: 7.1),
    SemesterResult(id: 'a3', studentId: 's1', semesterNumber: 3, sgpa: 5.9, backlogs: 2),
  ]);

  final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
  await container.read(authStateProvider.notifier).login('admin@college.edu', 'admin-pass');
  final service = container.read(predictionServiceProvider);
  final risk = await service.importModel(modelOf('logistic'));
  final forecast = await service.importModel(modelOf('ridge'));
  await service.importModel(modelOf('gbt_classifier'));
  if (activate) {
    await service.activate(risk, acknowledgeWarnings: true);
    await service.activate(forecast, acknowledgeWarnings: true);
  }
  return (db, container);
}

Future<void> pumpAt(WidgetTester tester, ProviderContainer container, String path) async {
  final router = GoRouter(initialLocation: path, routes: [
    GoRoute(path: '/admin/models', builder: (_, _) => const PredictionModelsScreen()),
    GoRoute(
      path: '/analytics',
      builder: (_, _) => const ClassAnalyticsScreen(),
      routes: [
        GoRoute(
          path: 'student/:id',
          builder: (_, s) => StudentInsightsScreen(studentId: s.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'prediction/:pid',
              builder: (_, s) => PredictionExplanationScreen(
                studentId: s.pathParameters['id']!,
                predictionId: s.pathParameters['pid']!,
              ),
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

void main() {
  for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1440, 900))]) {
    testWidgets('models screen shows evaluation and warnings on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (db, c) = await setUpApp();
      addTearDown(db.close);
      addTearDown(c.dispose);

      await pumpAt(tester, c, '/admin/models');
      expect(find.text('Academic risk'), findsOneWidget);
      expect(find.text('SGPA forecast'), findsOneWidget);
      expect(find.text('ACTIVE'), findsNWidgets(2));
      expect(find.text('SYNTHETIC: TEST ONLY'), findsNWidgets(3));

      // Activating the inactive tree model asks for acknowledgement.
      final activate = find.widgetWithText(FilledButton, 'Activate');
      await tester.ensureVisible(activate);
      await tester.tap(activate);
      await tester.pumpAndSettle();
      expect(find.text('Activate despite warnings?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('generate predictions and see them explained on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (db, c) = await setUpApp();
      addTearDown(db.close);
      addTearDown(c.dispose);

      await pumpAt(tester, c, '/analytics');
      final generate = find.text('Generate Predictions');
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      expect(find.textContaining('(test)'), findsWidgets); // risk chip from a synthetic model
      expect(find.textContaining('SGPA '), findsWidgets);

      await pumpAt(tester, c, '/analytics/student/s1');
      expect(find.text('Predictions'), findsOneWidget);
      expect(find.text('Academic risk signal for semester 4:'), findsOneWidget);
      expect(find.text('Expected SGPA range for semester 4:'), findsOneWidget);
      expect(find.text('Main factors'), findsNWidgets(2));
      expect(find.textContaining('synthetic data. Do not use'), findsOneWidget);
    });
  }

  for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1440, 900))]) {
    testWidgets('"Why this signal?" explains a prediction on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final (db, c) = await setUpApp();
      addTearDown(db.close);
      addTearDown(c.dispose);
      final user = c.read(authStateProvider).valueOrNull!;
      final service = c.read(predictionServiceProvider);
      final section = (await c.read(analyticsServiceProvider).visibleSections(user)).single;
      await service.generateForSection(section, user);

      await pumpAt(tester, c, '/analytics/student/s1');
      final why = find.text('Why this signal?').first;
      await tester.ensureVisible(why);
      await tester.tap(why);
      await tester.pumpAndSettle();

      expect(find.text('Academic risk signal'), findsOneWidget);
      expect(find.textContaining('Estimated '), findsOneWidget);
      expect(find.text('How each factor moved this estimate'), findsOneWidget);
      expect(find.textContaining('Exact (linear model)'), findsWidgets);
      expect(find.text('Data used'), findsOneWidget);
      expect(find.text('Model and audit trail'), findsOneWidget);
      expect(find.textContaining('synthetic data. Do not use'), findsOneWidget);
      expect(find.textContaining('changed since this prediction'), findsNothing);

      // After the data changes, the explanation says it is out of date.
      await DriftAcademicHistoryService(db).upsertSemesterResults([
        SemesterResult(id: 'fix', studentId: 's1', semesterNumber: 3, sgpa: 6.4, backlogs: 1),
      ]);
      // Leave and reopen the explanation, as a user would.
      await tester.tap(find.byTooltip('Back to student'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Why this signal?').first);
      await tester.tap(find.text('Why this signal?').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('changed since this prediction'), findsOneWidget);
    });
  }

  testWidgets('models screen shows the activity log and keeps used models', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (db, c) = await setUpApp();
    addTearDown(db.close);
    addTearDown(c.dispose);
    final user = c.read(authStateProvider).valueOrNull!;
    final section = (await c.read(analyticsServiceProvider).visibleSections(user)).single;
    await c.read(predictionServiceProvider).generateForSection(section, user);

    await pumpAt(tester, c, '/admin/models');
    expect(find.text('Prediction activity'), findsOneWidget);
    final activityCard = find.ancestor(of: find.text('Prediction activity'), matching: find.byType(AnalyticsCard));
    // One run per active model (risk + forecast), both by the admin.
    expect(find.descendant(of: activityCard, matching: find.text('Admin')), findsNWidgets(2));
    expect(find.textContaining('kept for audit'), findsNWidgets(2));
    expect(find.text('Remove'), findsOneWidget); // only the unused tree model
  });

  testWidgets('no generate button without active models', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final (db, c) = await setUpApp(activate: false);
    addTearDown(db.close);
    addTearDown(c.dispose);

    await pumpAt(tester, c, '/analytics');
    expect(find.text('Generate Predictions'), findsNothing);
    await pumpAt(tester, c, '/analytics/student/s1');
    expect(find.text('Predictions'), findsNothing);
  });
}
