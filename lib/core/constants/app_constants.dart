// lib/core/constants/app_constants.dart
// ALWAYS import with: package:edu_auth/core/constants/app_constants.dart

/// Enum replaces ALL hardcoded OTP purpose strings.
/// Prevents typos that cause backend rejections.
enum OtpPurpose {
  login,
  register,
  resetPassword,
  verifyEmail;

  /// The exact string value sent to the backend — do NOT change.
  String get value {
    switch (this) {
      case OtpPurpose.login:         return 'login';
      case OtpPurpose.register:      return 'register';
      case OtpPurpose.resetPassword: return 'reset_password';
      case OtpPurpose.verifyEmail:   return 'verify_email';
    }
  }
}

/// App-wide constants — never hardcode in UI layers.
class AppConstants {
  AppConstants._();

  static const String appName    = 'EduPlatform';
  static const String appVersion = '1.0.0';

  // ── Default locale ───────────────────────────────────────────────────────
  static const String defaultLocale = 'ar';

  // ── SecureStorage keys ───────────────────────────────────────────────────
  static const String kAccessToken   = 'access_token';
  static const String kRefreshToken  = 'refresh_token';
  static const String kUserId        = 'user_id';
  static const String kUserRole      = 'user_role';
  static const String kSessionExpiry = 'session_expiry';
  static const String kDeviceId      = 'device_id';
  static const String kLanguage      = 'app_language';
  static const String kLoginAttempts = 'login_attempts';
  static const String kLockoutUntil  = 'lockout_until';
  static const String kUserCache     = 'user_cache';
  static const String kFeatureFlags  = 'feature_flags';

  // ── Session ──────────────────────────────────────────────────────────────
  static const int accessTokenTTLMin   = 60;
  static const int refreshTokenTTLDays = 30;
  static const int inactivityMinutes   = 30;

  // ── Rate limiting (UI mirror — backend is authoritative) ─────────────────
  static const int maxLoginAttempts       = 5;
  static const int lockoutDurationMinutes = 15;
  static const int otpResendCooldownSec   = 60;
  static const int otpExpiryMinutes       = 10;

  // ── Password ─────────────────────────────────────────────────────────────
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;

  // ── Teacher code ─────────────────────────────────────────────────────────
  static const int teacherCodeLength = 8;

  // ── Concurrent sessions ──────────────────────────────────────────────────
  static const int maxConcurrentSessions = 3;
}
