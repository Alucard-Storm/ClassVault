import 'dart:async';
import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../core/utils/password_hasher.dart';
import '../database/app_database.dart';
import '../models/models.dart';
import '../repositories/auth_repository.dart';
import 'user_accounts.dart';

class DriftAuthService implements AuthRepository {
  final AppDatabase _db;
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  DriftAuthService(this._db);

  @override
  Future<AppUser?> login(String loginId, String password) async {
    final normalized = UserAccounts.normalizeLoginId(loginId);
    final row = await (_db.select(_db.users)..where((u) => u.loginId.equals(normalized)))
        .getSingleOrNull();

    if (row == null || !PasswordHasher.verify(password, row.passwordSalt, row.passwordHash)) {
      throw Exception('Invalid login ID or password.');
    }

    final user = _toAppUser(row);
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) throw Exception('You are not signed in.');

    final row = await (_db.select(_db.users)..where((u) => u.uid.equals(user.uid)))
        .getSingleOrNull();
    if (row == null) throw Exception('Account no longer exists.');
    if (!PasswordHasher.verify(currentPassword, row.passwordSalt, row.passwordHash)) {
      throw Exception('Current password is incorrect.');
    }

    final salt = PasswordHasher.newSalt();
    await (_db.update(_db.users)..where((u) => u.uid.equals(user.uid))).write(
      UsersCompanion(
        passwordHash: Value(PasswordHasher.hash(newPassword, salt)),
        passwordSalt: Value(salt),
      ),
    );
  }

  @override
  Future<bool> needsInitialSetup() async {
    final count = await _db.users.count().getSingle();
    return count == 0;
  }

  @override
  Future<AppUser> createInitialAdmin({
    required String name,
    required String email,
    required String password,
  }) async {
    return _db.transaction(() async {
      if (!await needsInitialSetup()) {
        throw Exception('An administrator account already exists.');
      }
      final salt = PasswordHasher.newSalt();
      final row = UserRow(
        uid: IdGenerator.next('usr'),
        name: name.trim(),
        loginId: UserAccounts.normalizeLoginId(email),
        role: UserRole.admin.name,
        associatedId: null,
        passwordHash: PasswordHasher.hash(password, salt),
        passwordSalt: salt,
        createdAt: DateTime.now(),
      );
      await _db.into(_db.users).insert(row);
      return _toAppUser(row);
    });
  }

  AppUser _toAppUser(UserRow row) {
    return AppUser(
      uid: row.uid,
      name: row.name,
      email: row.loginId,
      role: UserRole.values.byName(row.role),
      associatedId: row.associatedId,
    );
  }
}
