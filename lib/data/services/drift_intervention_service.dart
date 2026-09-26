import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/models.dart';
import '../repositories/intervention_repository.dart';

class DriftInterventionService implements InterventionRepository {
  final AppDatabase _db;

  DriftInterventionService(this._db);

  @override
  Future<void> add(Intervention intervention) => _db.into(_db.interventions).insert(intervention.toInsertable());

  @override
  Future<void> update(Intervention intervention) => _db.update(_db.interventions).replace(intervention.toInsertable());

  @override
  Future<Intervention?> get(String id) =>
      (_db.select(_db.interventions)..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Future<Map<String, List<InterventionEntry>>> forStudents(List<String> studentIds) async {
    if (studentIds.isEmpty) return const {};
    final i = _db.interventions;
    final query = _db.select(i).join([leftOuterJoin(_db.users, _db.users.uid.equalsExp(i.authorId))])
      ..where(i.studentId.isIn(studentIds))
      ..orderBy([OrderingTerm.desc(i.createdAt)]);
    final out = <String, List<InterventionEntry>>{};
    for (final row in await query.get()) {
      final entry = InterventionEntry(row.readTable(i), row.readTableOrNull(_db.users)?.name);
      out.putIfAbsent(entry.intervention.studentId, () => []).add(entry);
    }
    return out;
  }
}
