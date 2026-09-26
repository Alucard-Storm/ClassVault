import 'import_schema.dart';
import 'workbook_reader.dart';

/// How one sheet should be imported. `target == null` means skip the sheet.
class SheetMapping {
  final ImportTarget? target;

  /// Column index → destination. Unmapped columns are ignored.
  final Map<int, ColumnTarget> columns;

  const SheetMapping({required this.target, required this.columns});

  SheetMapping copyWith({ImportTarget? target, bool clearTarget = false, Map<int, ColumnTarget>? columns}) {
    return SheetMapping(
      target: clearTarget ? null : (target ?? this.target),
      columns: columns ?? this.columns,
    );
  }

  int? columnFor(ImportField field) {
    for (final e in columns.entries) {
      if (e.value.field == field && e.value.semester == null) return e.key;
    }
    return null;
  }

  bool get hasPerSemesterColumns => columns.values.any((c) => c.semester != null);
}

class ColumnMapper {
  const ColumnMapper._();

  static final _semesterToken = RegExp(
    r'\b(?:sem|semester|s)\s?(\d{1,2})\b|\b(\d{1,2})(?:st|nd|rd|th)?\s?sem(?:ester)?\b',
  );

  /// Suggests a target and column mapping for every sheet.
  static SheetMapping suggest(RawSheet sheet) {
    final target = suggestTarget(sheet);
    return SheetMapping(
      target: target,
      columns: target == null ? const {} : suggestColumns(sheet, target),
    );
  }

  static ImportTarget? suggestTarget(RawSheet sheet) {
    final sheetName = normalizeHeader(sheet.name);
    ImportTarget? best;
    var bestScore = 0;

    for (final target in ImportTarget.values) {
      final columns = suggestColumns(sheet, target);
      final dataColumns = columns.values
          .where((c) => c.field != ImportField.rollNumber && c.field != ImportField.name)
          .length;
      if (dataColumns == 0 || !columns.values.any((c) => c.field == ImportField.rollNumber)) {
        continue;
      }
      final keywordHits = target.sheetKeywords.where(sheetName.contains).length;
      final requiredMapped = target.requiredFields
          .every((f) => columns.values.any((c) => c.field == f));
      final score = keywordHits * 100 + (requiredMapped ? 50 : 0) + dataColumns * 10;
      if (score > bestScore) {
        bestScore = score;
        best = target;
      }
    }
    return best;
  }

  static Map<int, ColumnTarget> suggestColumns(RawSheet sheet, ImportTarget target) {
    final result = <int, ColumnTarget>{};

    // Wide per-semester columns first ("Sem 1 SGPA", "SGPA Sem 2", "3rd Sem %").
    if (target.perSemesterFields.isNotEmpty) {
      for (var i = 0; i < sheet.headers.length; i++) {
        final wide = _matchPerSemester(sheet.headers[i], target);
        if (wide != null && !result.containsValue(wide)) result[i] = wide;
      }
    }

    // Then plain columns: best-scoring (column, field) pairs, each used once.
    final candidates = <({int column, ImportField field, int score})>[];
    for (var i = 0; i < sheet.headers.length; i++) {
      if (result.containsKey(i)) continue;
      final header = normalizeHeader(sheet.headers[i]);
      if (header.isEmpty) continue;
      for (final field in target.fields) {
        final score = _score(header, field);
        if (score > 0) candidates.add((column: i, field: field, score: score));
      }
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));

    final usedFields = <ImportField>{};
    for (final c in candidates) {
      if (result.containsKey(c.column) || usedFields.contains(c.field)) continue;
      result[c.column] = ColumnTarget(c.field);
      usedFields.add(c.field);
    }
    return result;
  }

  static ColumnTarget? _matchPerSemester(String rawHeader, ImportTarget target) {
    final header = normalizeHeader(rawHeader);
    final match = _semesterToken.firstMatch(header);
    if (match == null) return null;
    final semester = int.parse(match.group(1) ?? match.group(2)!);
    if (semester < 1 || semester > 12) return null;

    final rest = header.replaceRange(match.start, match.end, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (rest.isEmpty) return null;
    ImportField? best;
    var bestScore = 0;
    for (final field in target.perSemesterFields) {
      final score = _score(rest, field);
      if (score > bestScore) {
        bestScore = score;
        best = field;
      }
    }
    return best == null ? null : ColumnTarget(best, semester);
  }

  /// Exact synonym match beats a whole-word containment match; longer
  /// synonyms beat shorter ones ("roll number" over "roll").
  static int _score(String header, ImportField field) {
    var best = 0;
    for (final synonym in field.synonyms) {
      if (header == synonym) {
        best = 1000 + synonym.length > best ? 1000 + synonym.length : best;
      } else if (RegExp('\\b${RegExp.escape(synonym)}\\b').hasMatch(header)) {
        best = 100 + synonym.length > best ? 100 + synonym.length : best;
      }
    }
    return best;
  }
}
