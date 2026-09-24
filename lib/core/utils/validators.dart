/// Shared form-field validators, so every screen validates the same way
/// instead of each hand-rolling its own (previously `.contains('@')`,
/// duplicated independently in the login and faculty-directory screens).
class Validators {
  const Validators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Returns an error string, or `null` if valid.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }
}
