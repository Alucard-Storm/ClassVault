import 'dart:math';

/// Generates collision-resistant string IDs such as `sres_lq3x9k_8f2a1c`.
///
/// A bare `millisecondsSinceEpoch` collides when many rows are created in the
/// same millisecond (bulk imports), so a random suffix is appended.
class IdGenerator {
  const IdGenerator._();

  static final _random = Random.secure();

  static String next(String prefix) {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final rand = _random.nextInt(0x7fffffff).toRadixString(36).padLeft(6, '0');
    return '${prefix}_${time}_$rand';
  }
}
