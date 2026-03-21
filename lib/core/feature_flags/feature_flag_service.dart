import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/logging/app_logger.dart';

/// Feature flags — enable/disable auth features remotely.
/// Fetched from backend; cached locally for offline access.
class FeatureFlagService {
  static final Map<String, bool> _defaults = {
    'otp_enabled':              true,
    'email_verification':       true,
    'teacher_code_system':      true,
    'rate_limiting':            true,
    'device_tracking':          true,
    'recaptcha_enabled':        false, // Enable when reCAPTCHA is wired
    'sms_otp':                  false, // Enable when SMS provider integrated
    'ai_fraud_detection':       false, // Enable when AI hook is wired
    'ai_smart_suggestions':     false,
    'concurrent_session_limit': true,
    'audit_logging':            true,
    'google_sign_in':           false, // Future OAuth integration
    'apple_sign_in':            false,
    'biometric_auth':           false,
  };

  Map<String, bool> _flags = Map.from(_defaults);

  /// Load cached flags from local storage.
  Future<void> loadCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.kFeatureFlags);
      if (raw != null) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        _flags = {..._defaults, ...decoded.map((k, v) => MapEntry(k, v as bool))};
      }
    } catch (e) {
      AppLogger.warn('FeatureFlags: failed to load cache, using defaults');
    }
  }

  /// Update flags from backend response and persist.
  Future<void> updateFromRemote(Map<String, bool> remoteFlags) async {
    _flags = {..._defaults, ...remoteFlags};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.kFeatureFlags, jsonEncode(_flags));
    } catch (e) {
      AppLogger.warn('FeatureFlags: failed to persist remote flags');
    }
  }

  bool isEnabled(String flag) => _flags[flag] ?? false;

  bool get otpEnabled            => isEnabled('otp_enabled');
  bool get emailVerification     => isEnabled('email_verification');
  bool get teacherCodeSystem     => isEnabled('teacher_code_system');
  bool get rateLimiting          => isEnabled('rate_limiting');
  bool get deviceTracking        => isEnabled('device_tracking');
  bool get recaptchaEnabled      => isEnabled('recaptcha_enabled');
  bool get smsOtp                => isEnabled('sms_otp');
  bool get aiFraudDetection      => isEnabled('ai_fraud_detection');
  bool get aiSmartSuggestions    => isEnabled('ai_smart_suggestions');
  bool get concurrentSessionLimit => isEnabled('concurrent_session_limit');
  bool get auditLogging          => isEnabled('audit_logging');
}
