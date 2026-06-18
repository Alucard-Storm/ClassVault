class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String status; // 'present' | 'absent'

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      studentId: json['studentId'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'studentId': studentId,
      'status': status,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? status,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
    );
  }
}
