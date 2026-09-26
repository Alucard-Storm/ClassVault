import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted, iterated SHA-256 for the local credential store.
///
/// Adequate for an on-device database; when auth moves to Firebase this is
/// replaced by Firebase Auth and no longer used.
class PasswordHasher {
  const PasswordHasher._();

  static const _iterations = 10000;
  static final _random = Random.secure();

  static String newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hash(String password, String salt) {
    List<int> digest = utf8.encode('$salt:$password');
    for (var i = 0; i < _iterations; i++) {
      digest = sha256.convert(digest).bytes;
    }
    return base64Url.encode(digest);
  }

  static bool verify(String password, String salt, String expectedHash) {
    final actual = hash(password, salt);
    // Constant-time comparison.
    if (actual.length != expectedHash.length) return false;
    var diff = 0;
    for (var i = 0; i < actual.length; i++) {
      diff |= actual.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return diff == 0;
  }
}
