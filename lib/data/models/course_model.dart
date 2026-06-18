class Course {
  final String id;
  final String name;

  Course({
    required this.id,
    required this.name,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  Course copyWith({
    String? id,
    String? name,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
