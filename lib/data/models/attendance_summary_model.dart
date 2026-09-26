/// Aggregate attendance for a subject in a semester. Used for historical
/// data that only exists as percentages (e.g. imported spreadsheets), as
/// opposed to the per-session [AttendanceRecord]s captured in-app.
class AttendanceSummary {
  final String id;
  final String studentId;
  final int semesterNumber;
  final String? subjectId;
  final String subjectName;
  final int? classesHeld;
  final int? classesAttended;
  final double percentage;
  final String? importBatchId;

  AttendanceSummary({
    required this.id,
    required this.studentId,
    required this.semesterNumber,
    this.subjectId,
    required this.subjectName,
    this.classesHeld,
    this.classesAttended,
    required this.percentage,
    this.importBatchId,
  });

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      semesterNumber: json['semesterNumber'] as int,
      subjectId: json['subjectId'] as String?,
      subjectName: json['subjectName'] as String,
      classesHeld: json['classesHeld'] as int?,
      classesAttended: json['classesAttended'] as int?,
      percentage: (json['percentage'] as num).toDouble(),
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
      'classesHeld': classesHeld,
      'classesAttended': classesAttended,
      'percentage': percentage,
      'importBatchId': importBatchId,
    };
  }

  AttendanceSummary copyWith({
    String? id,
    String? studentId,
    int? semesterNumber,
    String? subjectId,
    String? subjectName,
    int? classesHeld,
    int? classesAttended,
    double? percentage,
    String? importBatchId,
  }) {
    return AttendanceSummary(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      classesHeld: classesHeld ?? this.classesHeld,
      classesAttended: classesAttended ?? this.classesAttended,
      percentage: percentage ?? this.percentage,
      importBatchId: importBatchId ?? this.importBatchId,
    );
  }
}
