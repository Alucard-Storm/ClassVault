import 'dart:convert';
import 'dart:io';

import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/drift_attendance_service.dart';
import 'package:classvault/data/services/drift_prediction_service.dart';
import 'package:classvault/features/analytics/analytics_service.dart';
import 'package:classvault/features/prediction/engine/model_bundle.dart';
import 'package:classvault/features/prediction/prediction_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final fixtureModels = [
  for (final m in (jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync())['models'] as List))
    jsonEncode(m),
];
String modelOf(String family) => fixtureModels.firstWhere((m) => (jsonDecode(m) as Map)['family'] == family);

final admin = AppUser(uid: 'admin', name: 'Admin', email: 'a', role: UserRole.admin);
final otherFaculty = AppUser(uid: 'f2', name: 'F2', email: 'f', role: UserRole.faculty, associatedId: 'f2');

void main() {
  late AppDatabase db;
  late PredictionService service;
  late SectionOption section;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final academic = DriftAcademicService(db);
    final history = DriftAcademicHistoryService(db);
    final analytics = AnalyticsService(academic: academic, attendance: DriftAttendanceService(db), history: history);
    service = PredictionService(
      academic: academic, history: history, predictions: DriftPredictionService(db), analytics: analytics,
    );

    await academic.addCourse(Course(id: 'c', name: 'B.Tech'));
    await academic.addBranch(Branch(id: 'b', courseId: 'c', name: 'CSE'));
    await academic.addSemester(Semester(id: 'sem3', branchId: 'b', semesterNumber: 3));
    await academic.addSection(Section(id: 'sec', semesterId: 'sem3', name: 'A'));
    await academic.addStudentsBulk([
      Student(id: 's1', rollNumber: 'CS001', name: 'Asha', sectionId: 'sec'),
      Student(id: 's2', rollNumber: 'CS002', name: 'New Student', sectionId: 'sec'), // no history
    ], createAccounts: false);
    await history.upsertSemesterResults([
      SemesterResult(id: 'r1', studentId: 's1', semesterNumber: 1, sgpa: 7.9),
      SemesterResult(id: 'r2', studentId: 's1', semesterNumber: 2, sgpa: 6.1, backlogs: 2),
    ]);
    section = (await analytics.visibleSections(admin)).single;
  });

  tearDown(() => db.close());

  test('import validates and rejects duplicates', () async {
    final m = await service.importModel(modelOf('logistic'), importedBy: 'admin');
    expect(m.record.active, isFalse);
    expect(m.bundle.isSynthetic, isTrue);
    await expectLater(service.importModel(modelOf('logistic')), throwsA(isA<ModelFormatException>()));
    await expectLater(service.importModel('{"schema":"x"}'), throwsA(isA<ModelFormatException>()));
  });

  test('synthetic or failing models need acknowledgement; one active per task', () async {
    final lr = await service.importModel(modelOf('logistic'));
    final gbt = await service.importModel(modelOf('gbt_classifier'));
    expect(lr.warnings.first, contains('synthetic'));
    await expectLater(service.activate(lr), throwsA(isA<ModelActivationException>()));

    await service.activate(lr, acknowledgeWarnings: true);
    await service.activate(gbt, acknowledgeWarnings: true);
    final active = await service.activeModels();
    expect(active.map((m) => m.record.id), [gbt.record.id]);
  });

  test('generates explained predictions for the current semester; skips students without history', () async {
    await service.activate(await service.importModel(modelOf('logistic')), acknowledgeWarnings: true);
    await service.activate(await service.importModel(modelOf('ridge')), acknowledgeWarnings: true);

    final result = await service.generateForSection(section, admin);
    expect(result.predicted, 1);
    expect(result.skippedNoHistory, 1);

    final latest = await service.latestFor(['s1', 's2']);
    final risk = latest.risk['s1']!;
    expect(risk.record.targetSemester, 3);
    expect(risk.record.synthetic, isTrue);
    expect(risk.band, isNotNull);
    expect(risk.contributions, isNotEmpty);
    expect(jsonDecode(risk.record.featuresJson)['prev_sgpa'], 6.1);
    final forecast = latest.forecast['s1']!;
    expect(forecast.record.lower! <= forecast.record.value! && forecast.record.value! <= forecast.record.upper!, isTrue);
    expect(latest.risk.containsKey('s2'), isFalse);
  });

  test('history is scoped to visible sections', () async {
    final lr = await service.importModel(modelOf('logistic'));
    await service.activate(lr, acknowledgeWarnings: true);
    await service.generateForSection(section, admin);

    await expectLater(service.generateForSection(section, otherFaculty), throwsStateError);
    expect(await service.historyFor('s1', otherFaculty), isEmpty);
    expect((await service.historyFor('s1', admin)).single.record.modelId, lr.record.id);
  });

  test('models that made predictions cannot be removed; unused ones can', () async {
    final used = await service.importModel(modelOf('logistic'));
    final unused = await service.importModel(modelOf('gbt_classifier'));
    await service.activate(used, acknowledgeWarnings: true);
    await service.generateForSection(section, admin);

    await expectLater(service.delete(used), throwsA(isA<ModelInUseException>()));
    await service.delete(unused);
    expect((await service.models()).map((m) => m.record.id), [used.record.id]);
    expect(await service.predictionCounts(), {used.record.id: 1});
  });

  test('explain: summary, exact method, model card, audit trail and access', () async {
    await db.into(db.users).insert(UsersCompanion.insert(
          uid: 'admin', name: 'Admin Person', loginId: 'a@x.y', role: 'admin',
          passwordHash: 'h', passwordSalt: 's', createdAt: DateTime(2026),
        ));
    final gbt = await service.importModel(modelOf('gbt_classifier'));
    await service.activate(gbt, acknowledgeWarnings: true);
    await service.generateForSection(section, admin);
    final id = (await service.historyFor('s1', admin)).single.record.id;

    final e = (await service.explain(id, admin))!;
    expect(e.prediction.method, ExplanationMethod.treeShap);
    expect(e.summary, startsWith('Estimated '));
    expect(e.model!.modelId, gbt.record.id);
    expect(e.generatedByName, 'Admin Person');
    expect(e.trainingAverage('prev_sgpa'), isNotNull);
    expect(e.isStale, isFalse);

    expect(await service.explain(id, otherFaculty), isNull);
    expect(await service.explain('missing', admin), isNull);

    final runs = await service.activity();
    expect(runs.single.count, 1);
    expect(runs.single.generatedByName, 'Admin Person');
  });

  test('explain flags predictions whose inputs have changed', () async {
    await service.activate(await service.importModel(modelOf('logistic')), acknowledgeWarnings: true);
    await service.generateForSection(section, admin);
    final id = (await service.historyFor('s1', admin)).single.record.id;

    // A corrected semester-2 result arrives after the prediction was made.
    await DriftAcademicHistoryService(db).upsertSemesterResults([
      SemesterResult(id: 'fix', studentId: 's1', semesterNumber: 2, sgpa: 6.9, backlogs: 2),
    ]);
    final e = (await service.explain(id, admin))!;
    expect(e.isStale, isTrue);
    final change = e.changes.firstWhere((c) => c.feature == 'prev_sgpa');
    expect((change.then, change.now), (6.1, 6.9));
  });

  test('no active models means nothing is generated', () async {
    final result = await service.generateForSection(section, admin);
    expect(result.predicted, 0);
  });

  test('training export covers students with outcomes only', () async {
    final export = await service.exportTrainingData();
    expect(export.rows, 1); // s1: predict sem 2 from sem 1
    expect(export.csv, isNot(contains('Asha')));
    expect(service.exportSyntheticTrainingData().csv, contains(',synthetic,'));
  });
}
