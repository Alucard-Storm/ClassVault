/// What a sheet contains, i.e. which history table its rows become.
enum ImportTarget {
  schoolResults('School Results', 'Students / 10th & 12th results'),
  semesterResults('Semester Results', 'SGPA, CGPA, percentage, backlogs'),
  subjectMarks('Subject Marks', 'Internal / practical / external marks'),
  attendance('Attendance', 'Subject-wise attendance per semester'),
  assessments('Assessments', 'Quizzes, mid-terms, lab tests');

  final String label;
  final String description;
  const ImportTarget(this.label, this.description);

  List<ImportField> get fields => switch (this) {
        schoolResults => const [
            ImportField.rollNumber,
            ImportField.name,
            ImportField.tenthPercentage,
            ImportField.twelfthPercentage,
            ImportField.diplomaPercentage,
            ImportField.level,
            ImportField.percentage,
            ImportField.board,
            ImportField.passingYear,
          ],
        semesterResults => const [
            ImportField.rollNumber,
            ImportField.name,
            ImportField.semester,
            ImportField.academicYear,
            ImportField.sgpa,
            ImportField.percentage,
            ImportField.cgpa,
            ImportField.backlogs,
          ],
        subjectMarks => const [
            ImportField.rollNumber,
            ImportField.name,
            ImportField.semester,
            ImportField.subject,
            ImportField.internalMarks,
            ImportField.practicalMarks,
            ImportField.externalMarks,
            ImportField.totalMarks,
            ImportField.maxMarks,
            ImportField.grade,
            ImportField.result,
            ImportField.attempt,
          ],
        attendance => const [
            ImportField.rollNumber,
            ImportField.name,
            ImportField.semester,
            ImportField.subject,
            ImportField.classesHeld,
            ImportField.classesAttended,
            ImportField.attendancePercentage,
          ],
        assessments => const [
            ImportField.rollNumber,
            ImportField.name,
            ImportField.semester,
            ImportField.subject,
            ImportField.assessmentType,
            ImportField.title,
            ImportField.score,
            ImportField.maxScore,
            ImportField.date,
          ],
      };

  /// Columns that must be mapped for the sheet to be importable. Some
  /// targets have alternatives (e.g. attendance % or held + attended); those
  /// are checked by the validator.
  List<ImportField> get requiredFields => switch (this) {
        schoolResults => const [ImportField.rollNumber],
        semesterResults => const [ImportField.rollNumber],
        subjectMarks => const [ImportField.rollNumber, ImportField.semester, ImportField.subject],
        attendance => const [ImportField.rollNumber, ImportField.semester, ImportField.subject],
        assessments => const [
            ImportField.rollNumber,
            ImportField.semester,
            ImportField.subject,
            ImportField.assessmentType,
            ImportField.score,
            ImportField.maxScore,
          ],
      };

  /// Fields that may appear once per semester in "wide" layouts, e.g.
  /// `Sem 1 SGPA | Sem 2 SGPA | ...`.
  List<ImportField> get perSemesterFields => this == semesterResults
      ? const [ImportField.sgpa, ImportField.percentage, ImportField.cgpa, ImportField.backlogs]
      : const [];

  /// Words in a sheet name that identify this target.
  List<String> get sheetKeywords => switch (this) {
        schoolResults => const ['student', 'school', '10th', '12th'],
        semesterResults => const ['semester', 'sgpa', 'cgpa', 'result'],
        subjectMarks => const ['subject', 'mark'],
        attendance => const ['attend'],
        assessments => const ['assess', 'test', 'quiz', 'exam'],
      };
}

enum ImportField {
  rollNumber('Roll Number', ['roll no', 'roll number', 'roll', 'enrollment no', 'enrollment number',
      'enrolment no', 'enrolment number', 'registration no', 'registration number', 'reg no',
      'usn', 'prn', 'student id', 'admission no', 'admission number']),
  name('Student Name', ['name', 'student name', 'full name', 'student']),
  semester('Semester', ['semester', 'sem', 'term', 'semester no', 'sem no']),
  academicYear('Academic Year', ['academic year', 'session', 'ay', 'year']),
  sgpa('SGPA', ['sgpa', 'gpa', 'spi']),
  cgpa('CGPA', ['cgpa', 'cpi']),
  percentage('Percentage', ['percentage', 'percent', 'aggregate', 'marks percentage']),
  backlogs('Backlogs', ['backlogs', 'backlog', 'arrears', 'arrear', 'kt', 'atkt', 'failed subjects']),
  subject('Subject', ['subject', 'subject name', 'course', 'course name', 'paper', 'subject code',
      'course code']),
  internalMarks('Internal Marks', ['internal', 'internal marks', 'ia', 'cie', 'sessional', 'internals']),
  practicalMarks('Practical Marks', ['practical', 'practical marks', 'lab', 'lab marks', 'practicals']),
  externalMarks('External Marks', ['external', 'external marks', 'end sem', 'end semester', 'ese',
      'see', 'theory', 'externals']),
  totalMarks('Total Marks', ['total', 'total marks', 'marks', 'marks obtained', 'obtained']),
  maxMarks('Max Marks', ['max marks', 'maximum marks', 'out of', 'max', 'full marks']),
  grade('Grade', ['grade', 'letter grade', 'grade point']),
  result('Result (Pass/Fail)', ['result', 'status', 'pass fail', 'pass or fail']),
  attempt('Attempt', ['attempt', 'attempt no', 'attempt number']),
  classesHeld('Classes Held', ['classes held', 'held', 'total classes', 'lectures held', 'conducted',
      'classes conducted', 'total lectures']),
  classesAttended('Classes Attended', ['classes attended', 'attended', 'present', 'lectures attended']),
  attendancePercentage('Attendance %', ['attendance', 'attendance percentage', 'attd', 'attn',
      'att', 'attendance percent', 'percentage']),
  level('Level (10th/12th/Diploma)', ['level', 'qualification', 'exam', 'standard', 'class']),
  board('Board', ['board', 'board university']),
  passingYear('Passing Year', ['passing year', 'year of passing', 'passout year', 'year']),
  tenthPercentage('10th %', ['10th', '10th percentage', 'ssc', 'sslc', 'class 10', 'x percentage',
      'matric', 'tenth', '10 percentage']),
  twelfthPercentage('12th %', ['12th', '12th percentage', 'hsc', 'puc', 'class 12', 'xii percentage',
      'intermediate', 'twelfth', '12 percentage']),
  diplomaPercentage('Diploma %', ['diploma', 'diploma percentage']),
  assessmentType('Assessment Type', ['assessment type', 'type', 'assessment', 'exam type', 'test type',
      'component']),
  title('Title', ['title', 'assessment name', 'test name', 'name of test']),
  score('Score', ['score', 'marks obtained', 'obtained', 'marks', 'scored']),
  maxScore('Max Score', ['max score', 'maximum', 'out of', 'max marks', 'total marks', 'maximum marks']),
  date('Date', ['date', 'assessed on', 'test date', 'conducted on']);

  final String label;
  final List<String> synonyms;
  const ImportField(this.label, this.synonyms);
}

/// Where a column goes: a field, plus the semester for wide per-semester
/// columns (`Sem 3 SGPA` → sgpa @ 3).
class ColumnTarget {
  final ImportField field;
  final int? semester;

  const ColumnTarget(this.field, [this.semester]);

  String get label => semester == null ? field.label : 'Sem $semester ${field.label}';

  @override
  bool operator ==(Object other) =>
      other is ColumnTarget && other.field == field && other.semester == semester;

  @override
  int get hashCode => Object.hash(field, semester);
}

/// Normalizes a header/sheet name for matching: lowercase, `%` → "percentage",
/// punctuation → spaces, collapsed whitespace, "no." → "no".
String normalizeHeader(String header) {
  return header
      .toLowerCase()
      .replaceAll('%', ' percentage ')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
