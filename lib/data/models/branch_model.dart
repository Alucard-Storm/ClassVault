class Branch {
  final String id;
  final String courseId;
  final String name;

  Branch({
    required this.id,
    required this.courseId,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
    };
  }

  Branch copyWith({
    String? id,
    String? courseId,
    String? name,
  }) {
    return Branch(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
    );
  }
}
