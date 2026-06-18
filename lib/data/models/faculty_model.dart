class Faculty {
  final String id;
  final String employeeId;
  final String name;
  final String email;

  Faculty({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'email': email,
    };
  }

  Faculty copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? email,
  }) {
    return Faculty(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
