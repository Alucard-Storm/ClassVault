import '../models/models.dart';

abstract class AuthRepository {
  Future<AppUser?> login(String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Stream<AppUser?> authStateChanges();
}
