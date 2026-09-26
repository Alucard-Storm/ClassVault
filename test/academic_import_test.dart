import 'dart:convert';

import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/features/academic_import/engine/column_mapper.dart';
import 'package:classvault/features/academic_import/engine/import_schema.dart';
import 'package:classvault/features/academic_import/engine/import_validator.dart';
import 'package:classvault/features/academic_import/engine/template_builder.dart';
import 'package:classvault/features/academic_import/engine/workbook_reader.dart';
import 'package:drift/native.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

RawSheet sheet(String name, List<String> headers, List<List<Object?>> rows) =>
    RawSheet(name: name, headers: headers, rows: rows, firstDataRowNumber: 2);

RawWorkbook book(List<RawSheet> sheets) => RawWorkbook(fileName: 'test.xlsx', sheets: sheets);

final students = [
  Student(id: 's1', rollNumber: 'CS001', name: 'Asha Rao', sectionId: 'sec'),
  Student(id: 's2', rollNumber: 'CS002', name: 'Vikram Shah', sectionId: 'sec'),
];
final subjects = [Subject(id: 'sub_dbms', code: 'CS301', name: 'DBMS')];

ImportPlan validate(List<RawSheet> sheets) {
  final wb = book(sheets);
  final mappings = {for (final s in wb.sheets) s.name: ColumnMapper.suggest(s)};
  return ImportValidator(students: students, subjects: subjects).validate(wb, mappings);
}

List<String> errors(ImportPlan plan) =>
    plan.issues.where((i) => i.isError).map((i) => i.message).toList();

void main() {
  group('WorkbookReader', () {
    test('reads CSV with BOM, skipping blank rows but keeping row numbers', () {
      final csv = '﻿Roll No,Semester,SGPA\r\nCS001,1,7.8\r\n,,\r\nCS002,1,8.1\r\n';
      final wb = WorkbookReader.read('results.csv', utf8.encode(csv));
      final s = wb.sheets.single;
      expect(s.name, 'results');
      expect(s.headers, ['Roll No', 'Semester', 'SGPA']);
      expect(s.rows[0], ['CS001', '1', '7.8']);
      expect(s.rows[1], isEmpty); // blank spreadsheet row 3
      expect(s.firstDataRowNumber + 2, 4); // CS002 is on row 4
    });

    test('rejects unsupported files', () {
      expect(() => WorkbookReader.read('x.pdf', [1, 2]), throwsA(isA<WorkbookReadException>()));
    });

    test('template decodes with one sheet per target and ignorable instructions', () {
      final excel = Excel.decodeBytes(TemplateBuilder.build());
      for (final entry in TemplateBuilder.sheets.entries) {
        final headers = excel.tables[entry.key]!.rows.first.map((c) => c?.value.toString()).toList();
        expect(headers, entry.value, reason: entry.key);
      }
      // Header-only sheets carry no rows; only Instructions has content, and
      // it is not mistaken for data.
      final wb = WorkbookReader.read(TemplateBuilder.fileName, TemplateBuilder.build());
      expect(wb.sheets.map((s) => s.name), ['Instructions']);
      expect(ColumnMapper.suggestTarget(wb.sheets.single), isNull);
    });

    test('template headers are recognised exactly', () {
      final expected = {
        'Students': ImportTarget.schoolResults,
        'Semester_Results': ImportTarget.semesterResults,
        'Subject_Marks': ImportTarget.subjectMarks,
        'Attendance': ImportTarget.attendance,
        'Assessments': ImportTarget.assessments,
      };
      for (final entry in TemplateBuilder.sheets.entries) {
        final s = sheet(entry.key, entry.value, [
          ['CS001'],
        ]);
        final mapping = ColumnMapper.suggest(s);
        expect(mapping.target, expected[entry.key], reason: entry.key);
        // Every template column is mapped.
        expect(mapping.columns.length, entry.value.length, reason: entry.key);
      }
    });
  });

  group('ColumnMapper', () {
    test('maps college-specific headers via synonyms', () {
      final s = sheet('Sheet1', ['Enrollment No.', 'Student Name', 'Sem', 'Subject Code', 'CIE', 'ESE', 'Attd %'], [
        ['CS001'],
      ]);
      final cols = ColumnMapper.suggestColumns(s, ImportTarget.subjectMarks);
      expect(cols[0]!.field, ImportField.rollNumber);
      expect(cols[1]!.field, ImportField.name);
      expect(cols[2]!.field, ImportField.semester);
      expect(cols[3]!.field, ImportField.subject);
      expect(cols[4]!.field, ImportField.internalMarks);
      expect(cols[5]!.field, ImportField.externalMarks);
    });

    test('detects wide per-semester columns', () {
      final s = sheet('Results', ['Roll No', 'Sem 1 SGPA', 'SGPA Sem 2', '3rd Sem %', 'Backlogs S4'], [
        ['CS001'],
      ]);
      final mapping = ColumnMapper.suggest(s);
      expect(mapping.target, ImportTarget.semesterResults);
      expect(mapping.columns[1], const ColumnTarget(ImportField.sgpa, 1));
      expect(mapping.columns[2], const ColumnTarget(ImportField.sgpa, 2));
      expect(mapping.columns[3], const ColumnTarget(ImportField.percentage, 3));
      expect(mapping.columns[4], const ColumnTarget(ImportField.backlogs, 4));
    });

    test('skips sheets that do not look importable', () {
      expect(ColumnMapper.suggestTarget(sheet('Instructions', ['Read me'], [['x']])), isNull);
    });
  });

  group('ImportValidator', () {
    test('valid long-format semester results', () {
      final plan = validate([
        sheet('Semester_Results', ['Roll No', 'Semester', 'SGPA', 'Backlogs'], [
          ['CS001', 1, 7.1, 0],
          ['cs001', 'Sem II', 7.4, 1], // roll match is case-insensitive; roman semester
        ]),
      ]);
      expect(errors(plan), isEmpty);
      expect(plan.semesterResults.map((r) => (r.semesterNumber, r.sgpa, r.backlogs)),
          [(1, 7.1, 0), (2, 7.4, 1)]);
    });

    test('wide semester rows produce one record per semester', () {
      final plan = validate([
        sheet('Results', ['Roll No', 'Sem 1 SGPA', 'Sem 2 SGPA'], [
          ['CS001', 7.1, 7.4],
          ['CS002', 8.0, null],
        ]),
      ]);
      expect(errors(plan), isEmpty);
      expect(plan.semesterResults, hasLength(3));
    });

    test('unknown roll numbers, range and format errors reject the row', () {
      final plan = validate([
        sheet('Semester_Results', ['Roll No', 'Semester', 'SGPA', 'Percentage'], [
          ['CS999', 1, 7.0, 70], // unknown student
          ['CS001', 1, 11.2, 70], // SGPA out of range
          ['CS001', 2, 'abc', 70], // malformed
          ['CS001', 13, 7.0, 70], // bad semester
          [null, 1, 7.0, 70], // missing roll
          ['CS002', 3, 7.5, 105], // percentage out of range
          ['CS002', 1, 7.9, 79], // valid
        ]),
      ]);
      final e = errors(plan);
      expect(e, hasLength(6));
      expect(e[0], contains('not in ClassVault'));
      expect(plan.semesterResults.single.studentId, 's2');
      expect(plan.sheets.single.validRows, 1);
      expect(plan.sheets.single.errorRows, 6);
    });

    test('missing required columns skip the whole sheet', () {
      final wb = book([
        sheet('Subject_Marks', ['Roll No', 'Internal'], [['CS001', 20]]),
      ]);
      final plan = ImportValidator(students: students, subjects: subjects).validate(wb, {
        'Subject_Marks': ColumnMapper.suggest(wb.sheets.single)
            .copyWith(target: ImportTarget.subjectMarks),
      });
      expect(plan.sheets.single.isSkipped, isTrue);
      expect(errors(plan).single, contains('Semester'));
      expect(plan.recordCount, 0);
    });

    test('duplicates within the workbook are rejected', () {
      final plan = validate([
        sheet('Attendance', ['Roll No', 'Semester', 'Subject', 'Attendance %'], [
          ['CS001', 3, 'DBMS', 91],
          ['CS001', 3, 'dbms', 88],
        ]),
      ]);
      expect(errors(plan).single, contains('Duplicate of Attendance row 2'));
      expect(plan.attendanceSummaries, hasLength(1));
    });

    test('name mismatches are warnings, not errors', () {
      final plan = validate([
        sheet('Students', ['Roll No', 'Name', '10th %', '12th %'], [
          ['CS001', 'Asha R.', 82, 78],
        ]),
      ]);
      expect(errors(plan), isEmpty);
      expect(plan.warningCount, 1);
      expect(plan.schoolResults.map((r) => (r.level, r.percentage)), [('10th', 82.0), ('12th', 78.0)]);
    });

    test('subject marks: catalogue linking, computed total, fail grade', () {
      final plan = validate([
        sheet('Subject_Marks', ['Roll No', 'Semester', 'Subject', 'Internal', 'Practical', 'External', 'Grade'], [
          ['CS001', 3, 'cs301', 24, 27, 61, 'A'],
          ['CS002', 3, 'Operating Systems', 10, null, 15, 'F'],
        ]),
      ]);
      expect(errors(plan), isEmpty);
      final dbms = plan.subjectResults[0];
      expect(dbms.subjectId, 'sub_dbms');
      expect(dbms.subjectName, 'DBMS');
      expect(dbms.totalMarks, 112);
      final os = plan.subjectResults[1];
      expect(os.subjectId, isNull);
      expect(os.passed, isFalse);
    });

    test('attendance from held/attended, with impossible values rejected', () {
      final plan = validate([
        sheet('Attendance', ['Roll No', 'Semester', 'Subject', 'Classes Held', 'Classes Attended'], [
          ['CS001', 3, 'DBMS', 40, 30],
          ['CS002', 3, 'DBMS', 40, 45],
        ]),
      ]);
      expect(plan.attendanceSummaries.single.percentage, 75);
      expect(errors(plan).single, contains('exceeds classes held'));
    });

    test('assessments: score above max and bad dates are rejected', () {
      final plan = validate([
        sheet('Assessments', ['Roll No', 'Semester', 'Subject', 'Assessment Type', 'Score', 'Max Score', 'Date'], [
          ['CS001', 3, 'DBMS', 'Quiz', 8, 10, '15/08/2026'],
          ['CS001', 3, 'DBMS', 'Quiz', 12, 10, null],
          ['CS002', 3, 'DBMS', 'Quiz', 7, 10, '31/02/2026'],
        ]),
      ]);
      expect(plan.assessments.single.assessedOn, DateTime(2026, 8, 15));
      expect(errors(plan), hasLength(2));
    });
  });

  group('commitImport', () {
    late AppDatabase db;
    late DriftAcademicHistoryService history;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      history = DriftAcademicHistoryService(db);
      final academic = DriftAcademicService(db);
      await academic.addStudentsBulk(students, createAccounts: false);
    });

    tearDown(() => db.close());

    Future<ImportPlan> commit(String batchId) async {
      final plan = validate([
        sheet('Semester_Results', ['Roll No', 'Semester', 'SGPA'], [['CS001', 1, 7.1]]),
        sheet('Assessments', ['Roll No', 'Semester', 'Subject', 'Assessment Type', 'Score', 'Max Score'], [
          ['CS001', 3, 'DBMS', 'Quiz', 8, 10],
        ]),
      ]);
      await history.commitImport(
        batch: ImportBatch(id: batchId, fileName: 'f.xlsx', importedAt: DateTime.now(), recordCount: plan.recordCount),
        semesterResults: plan.semesterResults,
        assessments: plan.assessments,
      );
      return plan;
    }

    test('re-importing the same file does not duplicate records', () async {
      await commit('b1');
      await commit('b2');
      final h = (await history.getStudentHistory('s1'))!;
      expect(h.semesterResults, hasLength(1));
      expect(h.semesterResults.single.importBatchId, 'b2');
      expect(h.assessments, hasLength(1));
    });

    test('rolling back a batch removes what it wrote', () async {
      await commit('b1');
      await history.deleteImportBatch('b1');
      final h = (await history.getStudentHistory('s1'))!;
      expect(h.semesterResults, isEmpty);
      expect(h.assessments, isEmpty);
    });
  });
}
