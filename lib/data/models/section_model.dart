class Section {
  final String id;
  final String semesterId;
  final String name;

  Section({
    required this.id,
    required this.semesterId,
    required this.name,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      semesterId: json['semesterId'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'semesterId': semesterId,
      'name': name,
    };
  }

  Section copyWith({
    String? id,
    String? semesterId,
    String? name,
  }) {
    return Section(
      id: id ?? this.id,
      semesterId: semesterId ?? this.semesterId,
      name: name ?? this.name,
    );
  }
}
