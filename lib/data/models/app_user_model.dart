enum UserRole { admin, faculty, student }

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? associatedId; // Link to studentId or facultyId

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.associatedId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.student,
      ),
      associatedId: json['associatedId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'associatedId': associatedId,
    };
  }

  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? associatedId,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      associatedId: associatedId ?? this.associatedId,
    );
  }
}
