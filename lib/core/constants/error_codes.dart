/// Centralised error code registry.
/// Backend returns these codes; frontend maps them to localised messages.
class ErrorCodes {
  ErrorCodes._();

  // Auth errors
  static const String invalidCredentials = 'AUTH_001';
  static const String accountNotFound = 'AUTH_002';
  static const String accountSuspended = 'AUTH_003';
  static const String accountDeleted = 'AUTH_004';
  static const String emailNotVerified = 'AUTH_005';
  static const String tokenExpired = 'AUTH_006';
  static const String tokenInvalid = 'AUTH_007';
  static const String refreshTokenExpired = 'AUTH_008';
  static const String sessionLimitExceeded = 'AUTH_009';
  static const String rateLimitExceeded = 'AUTH_010';
  static const String otpInvalid = 'AUTH_011';
  static const String otpExpired = 'AUTH_012';
  static const String teacherCodeInvalid = 'AUTH_013';
  static const String teacherCodeExpired = 'AUTH_014';
  static const String teacherAlreadyLinked = 'AUTH_015';
  static const String privilegeEscalation = 'AUTH_016';
  static const String deviceNotTrusted = 'AUTH_017';

  // Registration errors
  static const String emailAlreadyExists = 'REG_001';
  static const String weakPassword = 'REG_002';
  static const String invalidEmail = 'REG_003';
  static const String termsNotAccepted = 'REG_004';

  // Network errors
  static const String networkUnavailable = 'NET_001';
  static const String timeoutError = 'NET_002';
  static const String serverError = 'NET_003';

  // Validation errors
  static const String validationError = 'VAL_001';

  // Unknown
  static const String unknown = 'ERR_000';
}
