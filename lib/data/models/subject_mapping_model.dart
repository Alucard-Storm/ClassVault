class SubjectMapping {
  final String id;
  final String sectionId;
  final String subjectId;

  SubjectMapping({
    required this.id,
    required this.sectionId,
    required this.subjectId,
  });

  factory SubjectMapping.fromJson(Map<String, dynamic> json) {
    return SubjectMapping(
      id: json['id'] as String,
      sectionId: json['sectionId'] as String,
      subjectId: json['subjectId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sectionId': sectionId,
      'subjectId': subjectId,
    };
  }

  SubjectMapping copyWith({
    String? id,
    String? sectionId,
    String? subjectId,
  }) {
    return SubjectMapping(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      subjectId: subjectId ?? this.subjectId,
    );
  }
}
