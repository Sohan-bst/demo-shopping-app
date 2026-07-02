import '../constants/app_strings.dart';

/// Reusable form-field validators returning a Material-friendly error string
/// (or null when the value is valid). Shared by the login/register/profile
/// forms so validation rules stay consistent and DRY.
class Validators {
  const Validators._();

  static final RegExp _emailRegExp = RegExp(
    r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  /// Requires a non-empty, well-formed email address.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errRequired;
    if (!_emailRegExp.hasMatch(v)) return AppStrings.errEmailInvalid;
    return null;
  }

  /// Requires a password of at least 6 characters.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.errRequired;
    if (v.length < 6) return AppStrings.errPasswordShort;
    return null;
  }

  /// Requires a name of at least 2 characters.
  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errRequired;
    if (v.length < 2) return AppStrings.errNameShort;
    return null;
  }

  /// Confirms that [value] matches the [original] password.
  static String? confirmPassword(String? value, String original) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.errRequired;
    if (v != original) return AppStrings.errPasswordMismatch;
    return null;
  }

  /// Generic non-empty check.
  static String? required(String? value) {
    if ((value?.trim() ?? '').isEmpty) return AppStrings.errRequired;
    return null;
  }
}
