class FacultyAssignment {
  final String id;
  final String facultyId;
  final String subjectMappingId;

  FacultyAssignment({
    required this.id,
    required this.facultyId,
    required this.subjectMappingId,
  });

  factory FacultyAssignment.fromJson(Map<String, dynamic> json) {
    return FacultyAssignment(
      id: json['id'] as String,
      facultyId: json['facultyId'] as String,
      subjectMappingId: json['subjectMappingId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facultyId': facultyId,
      'subjectMappingId': subjectMappingId,
    };
  }

  FacultyAssignment copyWith({
    String? id,
    String? facultyId,
    String? subjectMappingId,
  }) {
    return FacultyAssignment(
      id: id ?? this.id,
      facultyId: facultyId ?? this.facultyId,
      subjectMappingId: subjectMappingId ?? this.subjectMappingId,
    );
  }
}
