import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/providers.dart';
import 'package:classvault/features/academic_import/academic_import_screen.dart';
import 'package:classvault/features/academic_import/engine/workbook_reader.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

RawWorkbook workbook() => RawWorkbook(fileName: 'history.xlsx', sheets: [
      RawSheet(
        name: 'Semester_Results',
        headers: ['Enrollment No.', 'Student Name', 'Sem 1 SGPA', 'Sem 2 SGPA'],
        rows: [
          ['CS001', 'Asha Rao', 7.1, 7.4],
          ['CS999', 'Unknown', 6.0, 6.2],
        ],
        firstDataRowNumber: 2,
      ),
      RawSheet(
        name: 'Notes',
        headers: ['Remarks'],
        rows: [
          ['imported from registrar'],
        ],
        firstDataRowNumber: 2,
      ),
    ]);

void main() {
  for (final (label, size) in [('phone', const Size(360, 780)), ('desktop', const Size(1400, 900))]) {
    testWidgets('map → preview → import on $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await DriftAcademicService(db).addStudentsBulk(
        [Student(id: 's1', rollNumber: 'CS001', name: 'Asha Rao', sectionId: 'sec')],
        createAccounts: false,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: AcademicImportScreen(initialWorkbook: workbook())),
      ));
      await tester.pumpAndSettle();

      // Mapping step: the wide semester columns were detected; Notes is skipped.
      expect(find.text('Sem 1 SGPA'), findsWidgets);
      expect(find.text("Don't import this sheet"), findsOneWidget);

      await tester.ensureVisible(find.text('Validate & Preview'));
      await tester.tap(find.text('Validate & Preview'));
      await tester.pumpAndSettle();

      // Preview: 2 semester records from CS001, CS999 rejected.
      expect(find.text('Import 2 Records'), findsOneWidget);
      expect(find.textContaining('"CS999" is not in ClassVault'), findsOneWidget);

      await tester.ensureVisible(find.text('Import 2 Records'));
      await tester.tap(find.text('Import 2 Records'));
      await tester.pumpAndSettle();

      expect(find.text('Imported 2 records'), findsOneWidget);
      expect(find.text('history.xlsx'), findsOneWidget); // import history row

      final results = await DriftAcademicHistoryService(db).getSemesterResults('s1');
      expect(results.map((r) => r.sgpa), [7.1, 7.4]);
    });
  }
}
