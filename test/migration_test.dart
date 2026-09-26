import 'package:classvault/data/database/app_database.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v2.dart' as v2;
import 'generated_migrations/schema_v3.dart' as v3;

/// Schema snapshots live in drift_schemas/. After changing tables:
///   dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
///   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  for (final from in [1, 2, 3]) {
    test('v$from → v4 produces exactly the current schema', () async {
      final db = AppDatabase(await verifier.startAt(from));
      await verifier.migrateAndValidate(db, 4);
      await db.close();
    });
  }

  test('v1 data survives the upgrade to v4', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old.customStatement(
      "INSERT INTO students (id, roll_number, name, section_id) VALUES ('s1', 'CS001', 'Asha', 'sec')",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    expect((await db.select(db.students).get()).single.rollNumber, 'CS001');
    expect(await db.select(db.predictions).get(), isEmpty);
    expect(await db.select(db.interventions).get(), isEmpty);
    await db.close();
  });

  test('v2 predictions survive the upgrade to v4', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    await old.customStatement(
      "INSERT INTO students (id, roll_number, name, section_id) VALUES ('s1', 'CS001', 'Asha', 'sec')",
    );
    await old.customStatement(
      'INSERT INTO predictions (id, student_id, task, model_id, feature_version, target_semester, '
      "features_json, contributions_json, synthetic, generated_at) VALUES ('p1', 's1', 'risk', 'm', 'fv1', 4, "
      "'{}', '[]', 0, 1790000000)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    expect((await db.select(db.predictions).get()).single.id, 'p1');
    await db.close();
  });

  test('v3 import batches gain empty quality counts', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    await old.customStatement(
      'INSERT INTO import_batches (id, file_name, imported_at, record_count) '
      "VALUES ('b1', 'old.xlsx', 1790000000, 12)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 4);
    final batch = (await db.select(db.importBatches).get()).single;
    expect(batch.recordCount, 12);
    expect(batch.rejectedRows, isNull);
    await db.close();
  });
}
