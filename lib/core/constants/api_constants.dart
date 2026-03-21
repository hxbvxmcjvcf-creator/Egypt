/// API endpoint constants.
/// Base URLs come from EnvironmentConfig — never hardcoded here.
class ApiConstants {
  ApiConstants._();

  static const String loginEndpoint = '/auth/login';
  static const String registerStudentEndpoint = '/auth/register/student';
  static const String registerTeacherEndpoint = '/auth/register/teacher';
  static const String verifyOtpEndpoint = '/auth/otp/verify';
  static const String resendOtpEndpoint = '/auth/otp/resend';
  static const String refreshTokenEndpoint = '/auth/token/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String logoutAllEndpoint = '/auth/logout/all';
  static const String forgotPasswordEndpoint = '/auth/password/forgot';
  static const String resetPasswordEndpoint = '/auth/password/reset';
  static const String verifyEmailEndpoint = '/auth/email/verify';
  static const String linkTeacherEndpoint = '/auth/link/teacher';
  static const String featureFlagsEndpoint = '/config/feature-flags';
  static const String deviceRegisterEndpoint = '/auth/device/register';

  // Standard API response keys
  static const String dataKey = 'data';
  static const String errorKey = 'error';
  static const String messageKey = 'message';
  static const String codeKey = 'code';
  static const String successKey = 'success';
}
