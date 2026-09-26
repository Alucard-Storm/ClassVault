/// End-of-semester outcome for one student. One row per (student, semester).
class SemesterResult {
  final String id;
  final String studentId;
  final int semesterNumber;
  final String? academicYear;
  final double? sgpa;
  final double? percentage;
  final double? cgpa; // CGPA snapshot as of this semester
  final int backlogs; // backlogs outstanding at the end of this semester
  final String? importBatchId;

  SemesterResult({
    required this.id,
    required this.studentId,
    required this.semesterNumber,
    this.academicYear,
    this.sgpa,
    this.percentage,
    this.cgpa,
    this.backlogs = 0,
    this.importBatchId,
  });

  factory SemesterResult.fromJson(Map<String, dynamic> json) {
    return SemesterResult(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      semesterNumber: json['semesterNumber'] as int,
      academicYear: json['academicYear'] as String?,
      sgpa: (json['sgpa'] as num?)?.toDouble(),
      percentage: (json['percentage'] as num?)?.toDouble(),
      cgpa: (json['cgpa'] as num?)?.toDouble(),
      backlogs: json['backlogs'] as int? ?? 0,
      importBatchId: json['importBatchId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'semesterNumber': semesterNumber,
      'academicYear': academicYear,
      'sgpa': sgpa,
      'percentage': percentage,
      'cgpa': cgpa,
      'backlogs': backlogs,
      'importBatchId': importBatchId,
    };
  }

  SemesterResult copyWith({
    String? id,
    String? studentId,
    int? semesterNumber,
    String? academicYear,
    double? sgpa,
    double? percentage,
    double? cgpa,
    int? backlogs,
    String? importBatchId,
  }) {
    return SemesterResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      academicYear: academicYear ?? this.academicYear,
      sgpa: sgpa ?? this.sgpa,
      percentage: percentage ?? this.percentage,
      cgpa: cgpa ?? this.cgpa,
      backlogs: backlogs ?? this.backlogs,
      importBatchId: importBatchId ?? this.importBatchId,
    );
  }
}
