import 'package:edu_auth/core/constants/app_constants.dart';

/// Client-side validators for UX feedback only.
/// Backend performs authoritative validation.
class Validators {
  Validators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!ok.hasMatch(v.trim())) return 'Invalid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < AppConstants.passwordMinLength) return 'Too short';
    if (!RegExp(r'[A-Z]').hasMatch(v))                return 'Needs uppercase';
    if (!RegExp(r'[0-9]').hasMatch(v))                return 'Needs number';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Needs special char';
    return null;
  }

  static String? confirmPassword(String? v, String pw) {
    if (v == null || v.isEmpty) return 'Required';
    if (v != pw) return 'Passwords do not match';
    return null;
  }

  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length < 3) return 'Name too short';
    return null;
  }

  static String? teacherCode(String? v) {
    if (v == null || v.trim().isEmpty) return 'Code is required';
    if (v.trim().length != AppConstants.teacherCodeLength) return 'Must be 8 characters';
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(v.trim().toUpperCase())) return 'Invalid format';
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.isEmpty) return 'OTP required';
    if (v.length != 6 || !RegExp(r'^\d{6}$').hasMatch(v)) return 'Must be 6 digits';
    return null;
  }

  static String? required(String? v, {String field = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  /// Returns 0–4 strength score.
  static int passwordStrength(String pw) {
    int s = 0;
    if (pw.length >= AppConstants.passwordMinLength) s++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) s++;
    if (RegExp(r'[0-9]').hasMatch(pw)) s++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw)) s++;
    return s;
  }
}
