import 'dart:async';
import '../models/models.dart';
import '../repositories/auth_repository.dart';

class LocalAuthService implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  // Preset Users
  static final List<AppUser> _presets = [
    AppUser(
      uid: 'admin_uid',
      name: 'System Administrator',
      email: 'admin@campusvault.com',
      role: UserRole.admin,
    ),
    AppUser(
      uid: 'faculty_uid',
      name: 'Dr. Rahul Sharma',
      email: 'faculty@campusvault.com',
      role: UserRole.faculty,
      associatedId: 'fac_1',
    ),
    AppUser(
      uid: 'student_uid',
      name: 'Akshay Kumar',
      email: 'student@campusvault.com',
      role: UserRole.student,
      associatedId: 'stud_1',
    ),
  ];

  LocalAuthService() {
    // Start with logged out status by default
    _controller.add(null);
  }

  @override
  Future<AppUser?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final user = _presets.firstWhere(
        (u) => u.email.toLowerCase().trim() == email.toLowerCase().trim() && 
               password == '${u.role.name}123',
      );
      _currentUser = user;
      _controller.add(user);
      return user;
    } catch (_) {
      throw Exception('Invalid email or password. Use: admin@campusvault.com/admin123, faculty@campusvault.com/faculty123, or student@campusvault.com/student123');
    }
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }
}
