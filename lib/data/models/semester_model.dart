class Semester {
  final String id;
  final String branchId;
  final int semesterNumber;

  Semester({
    required this.id,
    required this.branchId,
    required this.semesterNumber,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['id'] as String,
      branchId: json['branchId'] as String,
      semesterNumber: json['semesterNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'semesterNumber': semesterNumber,
    };
  }

  Semester copyWith({
    String? id,
    String? branchId,
    int? semesterNumber,
  }) {
    return Semester(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      semesterNumber: semesterNumber ?? this.semesterNumber,
    );
  }
}
