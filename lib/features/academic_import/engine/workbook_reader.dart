import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// A sheet as plain values: each cell is a `String`, `num`, `bool`,
/// `DateTime` or `null`. Parsing into domain types happens in the validator.
class RawSheet {
  final String name;
  final List<String> headers;
  final List<List<Object?>> rows;

  /// Spreadsheet row number of `rows[0]` (1-based, after the header row), so
  /// errors can point at the row the user sees in Excel.
  final int firstDataRowNumber;

  RawSheet({
    required this.name,
    required this.headers,
    required this.rows,
    required this.firstDataRowNumber,
  });

  Object? cell(int rowIndex, int columnIndex) {
    final row = rows[rowIndex];
    return columnIndex < row.length ? row[columnIndex] : null;
  }
}

class RawWorkbook {
  final String fileName;
  final List<RawSheet> sheets;

  RawWorkbook({required this.fileName, required this.sheets});
}

class WorkbookReadException implements Exception {
  final String message;
  WorkbookReadException(this.message);
  @override
  String toString() => message;
}

class WorkbookReader {
  const WorkbookReader._();

  static RawWorkbook read(String fileName, List<int> bytes) {
    final lower = fileName.toLowerCase();
    final List<RawSheet> sheets;
    if (lower.endsWith('.csv')) {
      sheets = [_readCsv(_baseName(fileName), bytes)];
    } else if (lower.endsWith('.xlsx')) {
      sheets = _readXlsx(bytes);
    } else {
      throw WorkbookReadException('Unsupported file type. Use .xlsx or .csv.');
    }

    final nonEmpty = sheets.where((s) => s.headers.isNotEmpty && s.rows.isNotEmpty).toList();
    if (nonEmpty.isEmpty) {
      throw WorkbookReadException('The file has no sheets with a header row and data.');
    }
    return RawWorkbook(fileName: fileName, sheets: nonEmpty);
  }

  static RawSheet _readCsv(String name, List<int> bytes) {
    var text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('﻿')) text = text.substring(1); // Excel's UTF-8 BOM
    final table = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(text.replaceAll('\r\n', '\n'));
    return _fromTable(name, table.map((r) => r.map(_normalizeCsvCell).toList()).toList());
  }

  static List<RawSheet> _readXlsx(List<int> bytes) {
    final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (_) {
      throw WorkbookReadException('Could not read the workbook. Is it a valid .xlsx file?');
    }
    return [
      for (final entry in excel.tables.entries)
        _fromTable(
          entry.key,
          entry.value.rows.map((r) => r.map((c) => _fromCellValue(c?.value)).toList()).toList(),
        ),
    ];
  }

  /// Uses the first non-empty row as the header and drops blank rows.
  static RawSheet _fromTable(String name, List<List<Object?>> table) {
    var headerIndex = table.indexWhere((r) => r.any((c) => !_isBlank(c)));
    if (headerIndex == -1) {
      return RawSheet(name: name, headers: const [], rows: const [], firstDataRowNumber: 1);
    }

    final headers = table[headerIndex].map((c) => c?.toString().trim() ?? '').toList();
    final rows = <List<Object?>>[];
    var firstDataRow = -1;
    for (var i = headerIndex + 1; i < table.length; i++) {
      final row = table[i];
      if (row.every(_isBlank)) {
        // Keep row numbering aligned with the spreadsheet by padding with an
        // empty row only if data follows; trailing blanks are dropped below.
        rows.add(const []);
        continue;
      }
      if (firstDataRow == -1) firstDataRow = i;
      rows.add(row);
    }
    // Trim leading/trailing blank rows while keeping interior alignment.
    final leading = firstDataRow == -1 ? rows.length : firstDataRow - headerIndex - 1;
    final trimmed = rows.skip(leading).toList();
    while (trimmed.isNotEmpty && trimmed.last.isEmpty) {
      trimmed.removeLast();
    }

    return RawSheet(
      name: name,
      headers: headers,
      rows: trimmed,
      // +1 for 1-based numbering, +1 to skip the header row.
      firstDataRowNumber: headerIndex + leading + 2,
    );
  }

  static Object? _fromCellValue(CellValue? value) {
    return switch (value) {
      null => null,
      IntCellValue(:final value) => value,
      DoubleCellValue(:final value) => value,
      BoolCellValue(:final value) => value,
      DateCellValue(:final year, :final month, :final day) => DateTime(year, month, day),
      DateTimeCellValue(:final year, :final month, :final day) => DateTime(year, month, day),
      TextCellValue() => _emptyToNull(value.toString().trim()),
      _ => _emptyToNull(value.toString().trim()),
    };
  }

  static Object? _normalizeCsvCell(dynamic value) =>
      value == null ? null : _emptyToNull(value.toString().trim());

  static Object? _emptyToNull(String s) => s.isEmpty ? null : s;

  static bool _isBlank(Object? c) => c == null || (c is String && c.trim().isEmpty);

  static String _baseName(String fileName) {
    final slash = fileName.lastIndexOf(RegExp(r'[\\/]'));
    final name = slash == -1 ? fileName : fileName.substring(slash + 1);
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? name : name.substring(0, dot);
  }
}
