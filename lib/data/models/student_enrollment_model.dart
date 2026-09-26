/// One stint of a student in a section. Promotion closes the current
/// enrollment (sets [endedAt]) and opens a new one, so a student's path
/// through semesters/sections is never overwritten.
class StudentEnrollment {
  final String id;
  final String studentId;
  final String sectionId;
  final int semesterNumber; // snapshot, so history survives structure edits
  final String? academicYear; // e.g. "2025-26"
  final DateTime startedAt;
  final DateTime? endedAt; // null = current enrollment

  StudentEnrollment({
    required this.id,
    required this.studentId,
    required this.sectionId,
    required this.semesterNumber,
    this.academicYear,
    required this.startedAt,
    this.endedAt,
  });

  bool get isCurrent => endedAt == null;

  factory StudentEnrollment.fromJson(Map<String, dynamic> json) {
    return StudentEnrollment(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      sectionId: json['sectionId'] as String,
      semesterNumber: json['semesterNumber'] as int,
      academicYear: json['academicYear'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null ? null : DateTime.parse(json['endedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'sectionId': sectionId,
      'semesterNumber': semesterNumber,
      'academicYear': academicYear,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
    };
  }

  StudentEnrollment copyWith({
    String? id,
    String? studentId,
    String? sectionId,
    int? semesterNumber,
    String? academicYear,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return StudentEnrollment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sectionId: sectionId ?? this.sectionId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      academicYear: academicYear ?? this.academicYear,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
