/// Marks for one subject in one semester. Re-attempts of a failed subject
/// are separate rows with an incremented [attempt], which is what makes
/// backlog history (raised → cleared) reconstructable.
class SubjectResult {
  final String id;
  final String studentId;
  final int semesterNumber;
  final String? subjectId; // link to Subject when it exists in the catalogue
  final String subjectName; // as it appeared in the source record
  final double? internalMarks;
  final double? practicalMarks;
  final double? externalMarks;
  final double? totalMarks;
  final double? maxMarks;
  final String? grade;
  final bool? passed;
  final int attempt;
  final String? importBatchId;

  SubjectResult({
    required this.id,
    required this.studentId,
    required this.semesterNumber,
    this.subjectId,
    required this.subjectName,
    this.internalMarks,
    this.practicalMarks,
    this.externalMarks,
    this.totalMarks,
    this.maxMarks,
    this.grade,
    this.passed,
    this.attempt = 1,
    this.importBatchId,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      semesterNumber: json['semesterNumber'] as int,
      subjectId: json['subjectId'] as String?,
      subjectName: json['subjectName'] as String,
      internalMarks: (json['internalMarks'] as num?)?.toDouble(),
      practicalMarks: (json['practicalMarks'] as num?)?.toDouble(),
      externalMarks: (json['externalMarks'] as num?)?.toDouble(),
      totalMarks: (json['totalMarks'] as num?)?.toDouble(),
      maxMarks: (json['maxMarks'] as num?)?.toDouble(),
      grade: json['grade'] as String?,
      passed: json['passed'] as bool?,
      attempt: json['attempt'] as int? ?? 1,
      importBatchId: json['importBatchId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'semesterNumber': semesterNumber,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'internalMarks': internalMarks,
      'practicalMarks': practicalMarks,
      'externalMarks': externalMarks,
      'totalMarks': totalMarks,
      'maxMarks': maxMarks,
      'grade': grade,
      'passed': passed,
      'attempt': attempt,
      'importBatchId': importBatchId,
    };
  }

  SubjectResult copyWith({
    String? id,
    String? studentId,
    int? semesterNumber,
    String? subjectId,
    String? subjectName,
    double? internalMarks,
    double? practicalMarks,
    double? externalMarks,
    double? totalMarks,
    double? maxMarks,
    String? grade,
    bool? passed,
    int? attempt,
    String? importBatchId,
  }) {
    return SubjectResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      internalMarks: internalMarks ?? this.internalMarks,
      practicalMarks: practicalMarks ?? this.practicalMarks,
      externalMarks: externalMarks ?? this.externalMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      maxMarks: maxMarks ?? this.maxMarks,
      grade: grade ?? this.grade,
      passed: passed ?? this.passed,
      attempt: attempt ?? this.attempt,
      importBatchId: importBatchId ?? this.importBatchId,
    );
  }
}
