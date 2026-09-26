import 'package:excel/excel.dart';

/// Builds `ClassVault_Academic_Import.xlsx`: one sheet per import target with
/// the canonical headers (which the column mapper recognises exactly), plus
/// an instructions sheet that the importer ignores.
class TemplateBuilder {
  const TemplateBuilder._();

  static const fileName = 'ClassVault_Academic_Import.xlsx';

  static const sheets = <String, List<String>>{
    'Students': ['Roll No', 'Name', '10th %', '12th %', 'Diploma %'],
    'Semester_Results': ['Roll No', 'Semester', 'Academic Year', 'SGPA', 'Percentage', 'CGPA', 'Backlogs'],
    'Subject_Marks': ['Roll No', 'Semester', 'Subject', 'Internal', 'Practical', 'External', 'Total',
        'Max Marks', 'Grade', 'Result', 'Attempt'],
    'Attendance': ['Roll No', 'Semester', 'Subject', 'Classes Held', 'Classes Attended', 'Attendance %'],
    'Assessments': ['Roll No', 'Semester', 'Subject', 'Assessment Type', 'Title', 'Score', 'Max Score', 'Date'],
  };

  static const _instructions = [
    'ClassVault academic history import',
    '',
    'Fill in any of the sheets; leave the ones you do not need empty or delete them.',
    'Roll No must match a student already in ClassVault.',
    'Semester is a number from 1 to 12.',
    'Percentages are 0-100; SGPA/CGPA are 0-10.',
    'Subject can be the subject name or code from ClassVault.',
    'Result is Pass or Fail. Attempt defaults to 1; use 2, 3... for re-attempts of a backlog.',
    'Attendance: give Attendance %, or Classes Held and Classes Attended.',
    'Dates: YYYY-MM-DD or DD/MM/YYYY.',
    'Your own spreadsheets work too: the importer lets you map columns with different names.',
  ];

  static List<int> build() {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet()!;

    var first = true;
    for (final entry in sheets.entries) {
      if (first) {
        excel.rename(defaultSheet, entry.key);
        first = false;
      }
      excel.appendRow(entry.key, entry.value.map((h) => TextCellValue(h)).toList());
    }
    for (final line in _instructions) {
      excel.appendRow('Instructions', [TextCellValue(line)]);
    }
    excel.setDefaultSheet(sheets.keys.first);
    return excel.encode()!;
  }
}
