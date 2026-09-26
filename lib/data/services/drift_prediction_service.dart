import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/models.dart';
import '../repositories/prediction_repository.dart';

class DriftPredictionService implements PredictionRepository {
  final AppDatabase _db;

  DriftPredictionService(this._db);

  @override
  Future<List<MlModelRecord>> getModels() =>
      (_db.select(_db.mlModels)..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).get();

  @override
  Future<void> addModel(MlModelRecord model) => _db.into(_db.mlModels).insert(model.toInsertable());

  @override
  Future<void> setActive(String id, bool active) {
    return _db.transaction(() async {
      final model = await (_db.select(_db.mlModels)..where((t) => t.id.equals(id))).getSingle();
      if (active) {
        await (_db.update(_db.mlModels)..where((t) => t.task.equals(model.task)))
            .write(const MlModelsCompanion(active: Value(false)));
      }
      await (_db.update(_db.mlModels)..where((t) => t.id.equals(id)))
          .write(MlModelsCompanion(active: Value(active)));
    });
  }

  @override
  Future<void> deleteModel(String id) => (_db.delete(_db.mlModels)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> addPredictions(List<PredictionRecord> predictions) =>
      _db.batch((b) => b.insertAll(_db.predictions, predictions.map((p) => p.toInsertable())));

  @override
  Future<List<PredictionRecord>> getPredictionsForStudent(String studentId) {
    return (_db.select(_db.predictions)
          ..where((t) => t.studentId.equals(studentId))
          ..orderBy([(t) => OrderingTerm.desc(t.generatedAt)]))
        .get();
  }

  @override
  Future<PredictionRecord?> getPrediction(String id) =>
      (_db.select(_db.predictions)..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<Map<String, int>> countByModel() async {
    final count = _db.predictions.id.count();
    final rows = await (_db.selectOnly(_db.predictions)
          ..addColumns([_db.predictions.modelId, count])
          ..groupBy([_db.predictions.modelId]))
        .get();
    return {for (final r in rows) r.read(_db.predictions.modelId)!: r.read(count)!};
  }

  @override
  Future<List<PredictionRun>> getActivity({int limit = 50}) async {
    final p = _db.predictions;
    final count = p.id.count();
    final query = _db.selectOnly(p).join([
      leftOuterJoin(_db.users, _db.users.uid.equalsExp(p.generatedBy)),
    ])
      ..addColumns([p.generatedAt, p.generatedBy, p.modelId, p.task, p.synthetic, _db.users.name, count])
      ..groupBy([p.generatedAt, p.generatedBy, p.modelId, p.task, p.synthetic, _db.users.name])
      ..orderBy([OrderingTerm.desc(p.generatedAt)])
      ..limit(limit);
    return [
      for (final r in await query.get())
        PredictionRun(
          generatedAt: r.read(p.generatedAt)!,
          generatedBy: r.read(p.generatedBy),
          generatedByName: r.read(_db.users.name),
          modelId: r.read(p.modelId)!,
          task: r.read(p.task)!,
          synthetic: r.read(p.synthetic)!,
          count: r.read(count)!,
        ),
    ];
  }

  @override
  Future<Map<String, PredictionRecord>> getLatestPredictions(List<String> studentIds, String task) async {
    if (studentIds.isEmpty) return const {};
    final rows = await (_db.select(_db.predictions)
          ..where((t) => t.studentId.isIn(studentIds) & t.task.equals(task))
          ..orderBy([(t) => OrderingTerm.desc(t.generatedAt)]))
        .get();
    final latest = <String, PredictionRecord>{};
    for (final r in rows) {
      latest.putIfAbsent(r.studentId, () => r);
    }
    return latest;
  }
}
