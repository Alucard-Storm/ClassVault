import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../../core/utils/password_hasher.dart';
import '../database/app_database.dart';
import '../models/models.dart';

/// Keeps login accounts in step with faculty/student records.
///
/// Faculty sign in with their email, students with their roll number. A new
/// account's initial password is the same as its login ID, as entered.
class UserAccounts {
  final AppDatabase _db;

  UserAccounts(this._db);

  static String normalizeLoginId(String loginId) => loginId.trim().toLowerCase();

  /// Creates the account for [associatedId], or updates its name/login ID if
  /// it already exists. An existing password is never touched. With
  /// [createIfMissing] false, only an existing account is updated.
  Future<void> upsertFor({
    required String associatedId,
    required UserRole role,
    required String name,
    required String loginId,
    bool createIfMissing = true,
  }) async {
    final existing = await (_db.select(_db.users)
          ..where((u) => u.associatedId.equals(associatedId)))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.users)..where((u) => u.uid.equals(existing.uid))).write(
        UsersCompanion(
          name: Value(name),
          loginId: Value(normalizeLoginId(loginId)),
        ),
      );
      return;
    }
    if (!createIfMissing) return;

    final salt = PasswordHasher.newSalt();
    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            uid: IdGenerator.next('usr'),
            name: name,
            loginId: normalizeLoginId(loginId),
            role: role.name,
            associatedId: Value(associatedId),
            passwordHash: PasswordHasher.hash(loginId.trim(), salt),
            passwordSalt: salt,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> deleteFor(String associatedId) async {
    await (_db.delete(_db.users)..where((u) => u.associatedId.equals(associatedId))).go();
  }
}
