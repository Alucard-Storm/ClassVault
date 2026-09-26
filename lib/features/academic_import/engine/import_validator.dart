import '../../../core/utils/id_generator.dart';
import '../../../data/models/models.dart';
import 'column_mapper.dart';
import 'import_schema.dart';
import 'workbook_reader.dart';

enum IssueSeverity { error, warning }

class ImportIssue {
  final String sheetName;
  final int? rowNumber; // null = applies to the whole sheet
  final String? rollNumber;
  final IssueSeverity severity;
  final String message;

  const ImportIssue({
    required this.sheetName,
    this.rowNumber,
    this.rollNumber,
    required this.severity,
    required this.message,
  });

  bool get isError => severity == IssueSeverity.error;
}

class SheetValidation {
  final String sheetName;
  final ImportTarget target;
  final int totalRows;
  final int validRows;
  final int recordCount;
  final List<ImportIssue> issues;

  const SheetValidation({
    required this.sheetName,
    required this.target,
    required this.totalRows,
    required this.validRows,
    required this.recordCount,
    required this.issues,
  });

  /// A sheet-level error (e.g. a missing required column) skips the sheet.
  bool get isSkipped => issues.any((i) => i.isError && i.rowNumber == null);
  int get errorRows => totalRows - validRows;
}

/// Everything that would be written, plus what was rejected and why.
class ImportPlan {
  final String fileName;
  final List<SheetValidation> sheets;
  final List<SchoolResult> schoolResults;
  final List<SemesterResult> semesterResults;
  final List<SubjectResult> subjectResults;
  final List<AttendanceSummary> attendanceSummaries;
  final List<Assessment> assessments;

  const ImportPlan({
    required this.fileName,
    required this.sheets,
    required this.schoolResults,
    required this.semesterResults,
    required this.subjectResults,
    required this.attendanceSummaries,
    required this.assessments,
  });

  int get recordCount =>
      schoolResults.length +
      semesterResults.length +
      subjectResults.length +
      attendanceSummaries.length +
      assessments.length;

  List<ImportIssue> get issues => [for (final s in sheets) ...s.issues];
  int get errorCount => issues.where((i) => i.isError).length;
  int get warningCount => issues.where((i) => !i.isError).length;

  /// Short human summary stored on the import batch.
  String get summary => [
        if (schoolResults.isNotEmpty) 'School results: ${schoolResults.length}',
        if (semesterResults.isNotEmpty) 'Semester results: ${semesterResults.length}',
        if (subjectResults.isNotEmpty) 'Subject marks: ${subjectResults.length}',
        if (attendanceSummaries.isNotEmpty) 'Attendance: ${attendanceSummaries.length}',
        if (assessments.isNotEmpty) 'Assessments: ${assessments.length}',
      ].join(', ');
}

class ImportValidator {
  final Map<String, Student> _studentsByRoll;
  final Map<String, Subject> _subjectsByKey;

  ImportValidator({required List<Student> students, required List<Subject> subjects})
      : _studentsByRoll = {for (final s in students) _rollKey(s.rollNumber): s},
        _subjectsByKey = {
          for (final s in subjects) ...{_norm(s.code): s, _norm(s.name): s},
        };

  static String _rollKey(String roll) => roll.trim().toLowerCase();
  static String _norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  ImportPlan validate(RawWorkbook workbook, Map<String, SheetMapping> mappings) {
    final ctx = _Context();
    final sheets = <SheetValidation>[];

    for (final sheet in workbook.sheets) {
      final mapping = mappings[sheet.name];
      final target = mapping?.target;
      if (mapping == null || target == null) continue;
      sheets.add(_validateSheet(sheet, target, mapping, ctx));
    }

    return ImportPlan(
      fileName: workbook.fileName,
      sheets: sheets,
      schoolResults: ctx.schoolResults,
      semesterResults: ctx.semesterResults,
      subjectResults: ctx.subjectResults,
      attendanceSummaries: ctx.attendanceSummaries,
      assessments: ctx.assessments,
    );
  }

  SheetValidation _validateSheet(
    RawSheet sheet,
    ImportTarget target,
    SheetMapping mapping,
    _Context ctx,
  ) {
    final issues = <ImportIssue>[];
    final dataRows = [
      for (var i = 0; i < sheet.rows.length; i++)
        if (sheet.rows[i].isNotEmpty) i,
    ];

    // Sheet-level checks: required columns and target-specific alternatives.
    final missing = target.requiredFields.where((f) => mapping.columnFor(f) == null).toList();
    final alternativeError = _missingAlternative(target, mapping);
    if (missing.isNotEmpty || alternativeError != null) {
      issues.add(ImportIssue(
        sheetName: sheet.name,
        severity: IssueSeverity.error,
        message: [
          if (missing.isNotEmpty) 'Missing required column(s): ${missing.map((f) => f.label).join(', ')}.',
          ?alternativeError,
          'Sheet skipped.',
        ].join(' '),
      ));
      return SheetValidation(
        sheetName: sheet.name,
        target: target,
        totalRows: dataRows.length,
        validRows: 0,
        recordCount: 0,
        issues: issues,
      );
    }

    var validRows = 0;
    var records = 0;
    final namesSeen = <String, String>{};

    for (final index in dataRows) {
      final row = _Row(sheet, index, mapping);
      final rowIssues = <ImportIssue>[];
      void error(String m) => rowIssues.add(ImportIssue(
          sheetName: sheet.name, rowNumber: row.number, rollNumber: row.roll,
          severity: IssueSeverity.error, message: m));
      void warn(String m) => rowIssues.add(ImportIssue(
          sheetName: sheet.name, rowNumber: row.number, rollNumber: row.roll,
          severity: IssueSeverity.warning, message: m));

      // Identity
      final roll = row.roll;
      Student? student;
      if (roll == null) {
        error('Missing roll number.');
      } else {
        student = _studentsByRoll[_rollKey(roll)];
        if (student == null) {
          error('Roll number "$roll" is not in ClassVault. Add the student first.');
        }
      }

      final name = row.text(ImportField.name);
      if (student != null && name != null) {
        if (_norm(name) != _norm(student.name)) {
          warn('Name "$name" differs from "${student.name}" in ClassVault.');
        }
        final seen = namesSeen.putIfAbsent(_rollKey(roll!), () => name);
        if (_norm(seen) != _norm(name)) {
          warn('Roll number "$roll" appears with different names ("$seen" and "$name").');
        }
      }

      final pending = student == null
          ? const <_Pending>[]
          : switch (target) {
              ImportTarget.schoolResults => _schoolRows(row, student, error, warn),
              ImportTarget.semesterResults => _semesterRows(row, student, mapping, error, warn),
              ImportTarget.subjectMarks => _subjectRows(row, student, error, warn),
              ImportTarget.attendance => _attendanceRows(row, student, error, warn),
              ImportTarget.assessments => _assessmentRows(row, student, error, warn),
            };

      // Duplicate natural keys across the whole workbook.
      if (!rowIssues.any((i) => i.isError)) {
        for (final p in pending) {
          final firstSeen = ctx.keys[p.key];
          if (firstSeen != null) {
            error('Duplicate of ${firstSeen.sheet} row ${firstSeen.row} (${p.describe}).');
          }
        }
      }

      issues.addAll(rowIssues);
      if (rowIssues.any((i) => i.isError)) continue;

      if (pending.isEmpty) {
        issues.add(ImportIssue(
          sheetName: sheet.name, rowNumber: row.number, rollNumber: roll,
          severity: IssueSeverity.warning, message: 'Row has no values to import.'));
        continue;
      }

      validRows++;
      for (final p in pending) {
        ctx.keys[p.key] = (sheet: sheet.name, row: row.number);
        p.commit(ctx);
        records++;
      }
    }

    return SheetValidation(
      sheetName: sheet.name,
      target: target,
      totalRows: dataRows.length,
      validRows: validRows,
      recordCount: records,
      issues: issues,
    );
  }

  String? _missingAlternative(ImportTarget target, SheetMapping m) {
    bool has(ImportField f) => m.columnFor(f) != null;
    switch (target) {
      case ImportTarget.schoolResults:
        final wide = has(ImportField.tenthPercentage) ||
            has(ImportField.twelfthPercentage) ||
            has(ImportField.diplomaPercentage);
        final long = has(ImportField.level) && has(ImportField.percentage);
        return wide || long ? null : 'Map a 10th/12th/Diploma % column, or both Level and Percentage.';
      case ImportTarget.semesterResults:
        if (m.hasPerSemesterColumns) return null;
        if (!has(ImportField.semester)) return 'Map a Semester column (or per-semester columns like "Sem 1 SGPA").';
        final anyValue = [ImportField.sgpa, ImportField.percentage, ImportField.cgpa, ImportField.backlogs]
            .any(has);
        return anyValue ? null : 'Map at least one of SGPA, Percentage, CGPA or Backlogs.';
      case ImportTarget.subjectMarks:
        final anyMarks = [
          ImportField.internalMarks, ImportField.practicalMarks, ImportField.externalMarks,
          ImportField.totalMarks, ImportField.grade, ImportField.result,
        ].any(has);
        return anyMarks ? null : 'Map at least one marks, grade or result column.';
      case ImportTarget.attendance:
        final ok = has(ImportField.attendancePercentage) ||
            (has(ImportField.classesHeld) && has(ImportField.classesAttended));
        return ok ? null : 'Map Attendance %, or both Classes Held and Classes Attended.';
      case ImportTarget.assessments:
        return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Per-target row parsing. Each returns the records the row would produce;
  // problems are reported through [error]/[warn].
  // ---------------------------------------------------------------------------

  List<_Pending> _schoolRows(_Row row, Student student, _Report error, _Report warn) {
    final out = <_Pending>[];
    final board = row.text(ImportField.board);
    final year = row.integer(ImportField.passingYear, error);
    if (year != null && (year < 1950 || year > DateTime.now().year + 1)) {
      error('Passing year $year is out of range.');
    }

    void add(String level, double? pct) {
      if (pct == null) return;
      if (!_inRange(pct, 0, 100)) {
        error('$level percentage $pct must be between 0 and 100.');
        return;
      }
      out.add(_Pending(
        key: 'school|${student.id}|$level',
        describe: '$level result',
        commit: (ctx) => ctx.schoolResults.add(SchoolResult(
          id: IdGenerator.next('schr'),
          studentId: student.id,
          level: level,
          board: board,
          percentage: pct,
          passingYear: year,
        )),
      ));
    }

    add('10th', row.number_(ImportField.tenthPercentage, error));
    add('12th', row.number_(ImportField.twelfthPercentage, error));
    add('diploma', row.number_(ImportField.diplomaPercentage, error));

    final levelText = row.text(ImportField.level);
    if (levelText != null) {
      final level = _parseLevel(levelText);
      if (level == null) {
        error('Unknown level "$levelText". Use 10th, 12th or Diploma.');
      } else {
        add(level, row.number_(ImportField.percentage, error));
      }
    }
    return out;
  }

  List<_Pending> _semesterRows(
    _Row row,
    Student student,
    SheetMapping mapping,
    _Report error,
    _Report warn,
  ) {
    final academicYear = row.text(ImportField.academicYear);

    // Collect values per semester from both long and wide layouts.
    final bySemester = <int, Map<ImportField, double?>>{};
    final longSemester = row.semester(error);
    if (longSemester != null) {
      final values = bySemester.putIfAbsent(longSemester, () => {});
      for (final f in ImportTarget.semesterResults.perSemesterFields) {
        values[f] = row.number_(f, error);
      }
    }
    for (final entry in mapping.columns.entries) {
      final target = entry.value;
      if (target.semester == null) continue;
      final values = bySemester.putIfAbsent(target.semester!, () => {});
      values[target.field] = row.numberAt(entry.key, error);
    }

    final out = <_Pending>[];
    for (final entry in bySemester.entries) {
      final sem = entry.key;
      final v = entry.value;
      final sgpa = v[ImportField.sgpa];
      final pct = v[ImportField.percentage];
      final cgpa = v[ImportField.cgpa];
      final backlogsRaw = v[ImportField.backlogs];
      if (sgpa == null && pct == null && cgpa == null && backlogsRaw == null) continue;

      if (sgpa != null && !_inRange(sgpa, 0, 10)) error('Sem $sem SGPA $sgpa must be between 0 and 10.');
      if (cgpa != null && !_inRange(cgpa, 0, 10)) error('Sem $sem CGPA $cgpa must be between 0 and 10.');
      if (pct != null && !_inRange(pct, 0, 100)) error('Sem $sem percentage $pct must be between 0 and 100.');
      int? backlogs;
      if (backlogsRaw != null) {
        if (backlogsRaw < 0 || backlogsRaw != backlogsRaw.roundToDouble()) {
          error('Sem $sem backlogs "$backlogsRaw" must be a whole number of 0 or more.');
        } else {
          backlogs = backlogsRaw.toInt();
        }
      }

      out.add(_Pending(
        key: 'sem|${student.id}|$sem',
        describe: 'semester $sem result',
        commit: (ctx) => ctx.semesterResults.add(SemesterResult(
          id: IdGenerator.next('semr'),
          studentId: student.id,
          semesterNumber: sem,
          academicYear: academicYear,
          sgpa: sgpa,
          percentage: pct,
          cgpa: cgpa,
          backlogs: backlogs ?? 0,
        )),
      ));
    }
    return out;
  }

  List<_Pending> _subjectRows(_Row row, Student student, _Report error, _Report warn) {
    final sem = row.semester(error);
    final subject = _subject(row, error);
    final internal = row.number_(ImportField.internalMarks, error);
    final practical = row.number_(ImportField.practicalMarks, error);
    final external = row.number_(ImportField.externalMarks, error);
    var total = row.number_(ImportField.totalMarks, error);
    final max = row.number_(ImportField.maxMarks, error);
    final grade = row.text(ImportField.grade);
    final resultText = row.text(ImportField.result);
    final attempt = row.integer(ImportField.attempt, error) ?? 1;
    if (sem == null || subject == null) return const [];

    for (final (label, value) in [
      ('Internal', internal), ('Practical', practical), ('External', external), ('Total', total),
    ]) {
      if (value != null && value < 0) error('$label marks cannot be negative.');
    }
    if (max != null && max <= 0) error('Max marks must be greater than 0.');
    if (attempt < 1) error('Attempt must be 1 or more.');

    final components = [internal, practical, external].whereType<double>().toList();
    if (total == null && components.isNotEmpty) {
      total = components.fold<double>(0, (a, b) => a + b);
    } else if (total != null && components.length >= 2) {
      final sum = components.fold<double>(0, (a, b) => a + b);
      if ((sum - total).abs() > 0.5) {
        warn('Total $total does not equal the sum of components ($sum).');
      }
    }
    if (total != null && max != null && total > max) error('Total $total exceeds max marks $max.');

    bool? passed;
    if (resultText != null) {
      passed = _parsePass(resultText);
      if (passed == null) error('Unknown result "$resultText". Use Pass or Fail.');
    } else if (grade != null && _failGrades.contains(grade.trim().toUpperCase())) {
      passed = false;
    }

    if (internal == null && practical == null && external == null && total == null &&
        grade == null && passed == null) {
      return const [];
    }

    final (subjectId, subjectName) = subject;
    return [
      _Pending(
        key: 'subj|${student.id}|$sem|${_norm(subjectName)}|$attempt',
        describe: '$subjectName, sem $sem, attempt $attempt',
        commit: (ctx) => ctx.subjectResults.add(SubjectResult(
          id: IdGenerator.next('subr'),
          studentId: student.id,
          semesterNumber: sem,
          subjectId: subjectId,
          subjectName: subjectName,
          internalMarks: internal,
          practicalMarks: practical,
          externalMarks: external,
          totalMarks: total,
          maxMarks: max,
          grade: grade,
          passed: passed,
          attempt: attempt,
        )),
      ),
    ];
  }

  List<_Pending> _attendanceRows(_Row row, Student student, _Report error, _Report warn) {
    final sem = row.semester(error);
    final subject = _subject(row, error);
    final held = row.integer(ImportField.classesHeld, error);
    final attended = row.integer(ImportField.classesAttended, error);
    var pct = row.number_(ImportField.attendancePercentage, error);
    if (sem == null || subject == null) return const [];

    if (held != null && held <= 0) error('Classes held must be greater than 0.');
    if (attended != null && attended < 0) error('Classes attended cannot be negative.');
    if (held != null && attended != null && held > 0) {
      if (attended > held) {
        error('Classes attended ($attended) exceeds classes held ($held).');
      } else {
        final computed = attended / held * 100;
        if (pct == null) {
          pct = double.parse(computed.toStringAsFixed(2));
        } else if ((computed - pct).abs() > 1) {
          warn('Attendance $pct% does not match $attended/$held (${computed.toStringAsFixed(1)}%).');
        }
      }
    }
    if (pct == null) return const [];
    if (!_inRange(pct, 0, 100)) error('Attendance $pct% must be between 0 and 100.');

    final (subjectId, subjectName) = subject;
    final percentage = pct;
    return [
      _Pending(
        key: 'att|${student.id}|$sem|${_norm(subjectName)}',
        describe: '$subjectName attendance, sem $sem',
        commit: (ctx) => ctx.attendanceSummaries.add(AttendanceSummary(
          id: IdGenerator.next('atts'),
          studentId: student.id,
          semesterNumber: sem,
          subjectId: subjectId,
          subjectName: subjectName,
          classesHeld: held,
          classesAttended: attended,
          percentage: percentage,
        )),
      ),
    ];
  }

  List<_Pending> _assessmentRows(_Row row, Student student, _Report error, _Report warn) {
    final sem = row.semester(error);
    final subject = _subject(row, error);
    final type = row.text(ImportField.assessmentType);
    final title = row.text(ImportField.title);
    final score = row.number_(ImportField.score, error);
    final max = row.number_(ImportField.maxScore, error);
    final date = row.date(ImportField.date, error);
    if (type == null) error('Missing assessment type.');
    if (score == null) error('Missing score.');
    if (max == null) error('Missing max score.');
    if (sem == null || subject == null || type == null || score == null || max == null) return const [];

    if (max <= 0) error('Max score must be greater than 0.');
    if (score < 0) error('Score cannot be negative.');
    if (score > max) error('Score $score exceeds max score $max.');

    final (subjectId, subjectName) = subject;
    return [
      _Pending(
        key: 'asmt|${student.id}|$sem|${_norm(subjectName)}|${_norm(type)}|${_norm(title ?? '')}|'
            '${date?.toIso8601String()}|$score|$max',
        describe: '$subjectName ${title ?? type}',
        commit: (ctx) => ctx.assessments.add(Assessment(
          id: IdGenerator.next('asmt'),
          studentId: student.id,
          semesterNumber: sem,
          subjectId: subjectId,
          subjectName: subjectName,
          assessmentType: type,
          title: title,
          score: score,
          maxScore: max,
          assessedOn: date,
        )),
      ),
    ];
  }

  /// Resolves a subject against the catalogue by code or name, returning
  /// (subjectId, canonical name). Unknown subjects are kept by name.
  (String?, String)? _subject(_Row row, _Report error) {
    final text = row.text(ImportField.subject);
    if (text == null) {
      error('Missing subject.');
      return null;
    }
    final known = _subjectsByKey[_norm(text)];
    return known == null ? (null, text.trim()) : (known.id, known.name);
  }

  static bool _inRange(double v, double min, double max) => v >= min && v <= max;

  static const _failGrades = {'F', 'FF', 'FAIL', 'AB', 'ABS', 'E', 'NC', 'U'};

  static bool? _parsePass(String s) {
    final v = s.trim().toLowerCase();
    if (['pass', 'p', 'passed', 'cleared', 'yes', 'y', 'true', 'ok'].contains(v)) return true;
    if (['fail', 'f', 'failed', 'no', 'n', 'false', 'kt', 'atkt', 'ab', 'absent', 're', 'reappear',
        'backlog'].contains(v)) {
      return false;
    }
    return null;
  }

  static String? _parseLevel(String s) {
    final v = normalizeHeader(s);
    if (['10', '10th', 'x', 'ssc', 'sslc', 'matric', 'class 10', 'tenth', 'secondary'].contains(v)) {
      return '10th';
    }
    if (['12', '12th', 'xii', 'hsc', 'puc', 'class 12', 'twelfth', 'intermediate',
        'higher secondary', 'senior secondary'].contains(v)) {
      return '12th';
    }
    if (v.contains('diploma')) return 'diploma';
    return null;
  }
}

typedef _Report = void Function(String message);

/// A record the row will produce once the whole row is known to be valid.
class _Pending {
  final String key;
  final String describe;
  final void Function(_Context ctx) commit;
  _Pending({required this.key, required this.describe, required this.commit});
}

class _Context {
  final keys = <String, ({String sheet, int row})>{};
  final schoolResults = <SchoolResult>[];
  final semesterResults = <SemesterResult>[];
  final subjectResults = <SubjectResult>[];
  final attendanceSummaries = <AttendanceSummary>[];
  final assessments = <Assessment>[];
}

/// Typed access to one sheet row through the mapping.
class _Row {
  final RawSheet sheet;
  final int index;
  final SheetMapping mapping;

  _Row(this.sheet, this.index, this.mapping);

  int get number => sheet.firstDataRowNumber + index;

  String? get roll => text(ImportField.rollNumber);

  Object? _raw(ImportField field) {
    final col = mapping.columnFor(field);
    return col == null ? null : sheet.cell(index, col);
  }

  String _header(int col) => sheet.headers[col].isEmpty ? 'Column ${col + 1}' : sheet.headers[col];

  static const _blanks = {'-', '--', 'na', 'n/a', 'nil', 'null', 'none', ''};

  static bool _isBlank(Object? v) =>
      v == null || (v is String && _blanks.contains(v.trim().toLowerCase()));

  String? text(ImportField field) {
    final v = _raw(field);
    if (_isBlank(v)) return null;
    if (v is double && v == v.roundToDouble()) return v.toInt().toString(); // "101.0" → "101"
    if (v is DateTime) return v.toIso8601String().substring(0, 10);
    return v.toString().trim();
  }

  double? number_(ImportField field, _Report error) {
    final col = mapping.columnFor(field);
    return col == null ? null : numberAt(col, error);
  }

  double? numberAt(int col, _Report error) {
    final v = sheet.cell(index, col);
    if (_isBlank(v)) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim().replaceAll('%', '').replaceAll(' ', '');
    final parsed = double.tryParse(s);
    if (parsed == null) {
      // "AB" (absent) and similar markers read as no value.
      if (['ab', 'abs', 'absent'].contains(s.toLowerCase())) return null;
      error('${_header(col)}: "$v" is not a number.');
    }
    return parsed;
  }

  int? integer(ImportField field, _Report error) {
    final n = number_(field, error);
    if (n == null) return null;
    if (n != n.roundToDouble()) {
      error('${field.label}: "$n" must be a whole number.');
      return null;
    }
    return n.toInt();
  }

  static const _roman = {
    'i': 1, 'ii': 2, 'iii': 3, 'iv': 4, 'v': 5, 'vi': 6,
    'vii': 7, 'viii': 8, 'ix': 9, 'x': 10, 'xi': 11, 'xii': 12,
  };

  int? semester(_Report error) {
    final v = _raw(ImportField.semester);
    if (_isBlank(v)) {
      if (mapping.columnFor(ImportField.semester) != null) error('Missing semester.');
      return null;
    }
    int? sem;
    if (v is num && v == v.roundToDouble()) {
      sem = v.toInt();
    } else {
      final s = v.toString().trim().toLowerCase();
      final roman = _roman[s.replaceAll(RegExp(r'^(sem(ester)?)\s*'), '')];
      sem = roman ?? int.tryParse(RegExp(r'\d+').firstMatch(s)?.group(0) ?? '');
    }
    if (sem == null || sem < 1 || sem > 12) {
      error('Semester "$v" is not valid (expected 1–12).');
      return null;
    }
    return sem;
  }

  DateTime? date(ImportField field, _Report error) {
    final v = _raw(field);
    if (_isBlank(v)) return null;
    if (v is DateTime) return v;
    final s = v.toString().trim();
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final m = RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$').firstMatch(s);
    if (m != null) {
      // Day-first, as used in Indian academic records.
      final d = int.parse(m.group(1)!), mo = int.parse(m.group(2)!), y = int.parse(m.group(3)!);
      final date = DateTime(y, mo, d);
      if (date.month == mo && date.day == d) return date;
    }
    error('${field.label}: "$s" is not a valid date (use YYYY-MM-DD or DD/MM/YYYY).');
    return null;
  }
}
