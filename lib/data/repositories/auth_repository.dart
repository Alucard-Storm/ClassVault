import '../models/models.dart';

abstract class AuthRepository {
  /// [loginId] is an email (admin/faculty) or roll number (student).
  Future<AppUser?> login(String loginId, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> authStateChanges();

  /// Changes the signed-in user's password after verifying the current one.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// True on a fresh install, before any account exists.
  Future<bool> needsInitialSetup();

  /// Creates the first administrator. Fails once any account exists.
  Future<AppUser> createInitialAdmin({
    required String name,
    required String email,
    required String password,
  });
}
