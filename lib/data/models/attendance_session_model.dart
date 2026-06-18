class AttendanceSession {
  final String id;
  final String facultyId;
  final String subjectId;
  final String sectionId;
  final DateTime date;
  final String startTime; // format e.g. "10:00 AM"
  final String endTime;   // format e.g. "11:00 AM"

  AttendanceSession({
    required this.id,
    required this.facultyId,
    required this.subjectId,
    required this.sectionId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id'] as String,
      facultyId: json['facultyId'] as String,
      subjectId: json['subjectId'] as String,
      sectionId: json['sectionId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facultyId': facultyId,
      'subjectId': subjectId,
      'sectionId': sectionId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  AttendanceSession copyWith({
    String? id,
    String? facultyId,
    String? subjectId,
    String? sectionId,
    DateTime? date,
    String? startTime,
    String? endTime,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      subjectId: subjectId ?? this.subjectId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
