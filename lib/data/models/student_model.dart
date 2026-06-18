class Student {
  final String id;
  final String rollNumber;
  final String name;
  final String sectionId;

  Student({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.sectionId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      rollNumber: json['rollNumber'] as String,
      name: json['name'] as String,
      sectionId: json['sectionId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rollNumber': rollNumber,
      'name': name,
      'sectionId': sectionId,
    };
  }

  Student copyWith({
    String? id,
    String? rollNumber,
    String? name,
    String? sectionId,
  }) {
    return Student(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      name: name ?? this.name,
      sectionId: sectionId ?? this.sectionId,
    );
  }
}
