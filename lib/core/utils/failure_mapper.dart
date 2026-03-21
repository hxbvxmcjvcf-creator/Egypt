// lib/core/utils/failure_mapper.dart
// ALWAYS import with: package:edu_auth/core/utils/failure_mapper.dart
//
// Maps a domain Failure → a localised Arabic/English user-facing string.
// The UI NEVER shows failure.message (which is English) directly.
// Always call FailureMapper.toMessage(context, failure) instead.

import 'package:flutter/material.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/l10n/app_localizations.dart';

class FailureMapper {
  FailureMapper._();

  /// Returns a localised, user-friendly error message for any [Failure].
  static String toMessage(BuildContext context, Failure failure) {
    final l = AppLocalizations.of(context);

    // ── Typed failures first (most specific) ────────────────────────────
    if (failure is InvalidCredentialsFailure)  return l.errInvalidCredentials;
    if (failure is AccountNotFoundFailure)     return l.errAccountNotFound;
    if (failure is AccountSuspendedFailure)    return l.errAccountSuspended;
    if (failure is AccountDeletedFailure)      return l.errAccountSuspended;
    if (failure is EmailNotVerifiedFailure)    return l.errEmailNotVerified;
    if (failure is TokenExpiredFailure)        return l.errSessionExpired;
    if (failure is RefreshTokenExpiredFailure) return l.errSessionExpired;
    if (failure is TokenInvalidFailure)        return l.errSessionExpired;
    if (failure is SessionLimitFailure)        return l.errMaxDevices;
    if (failure is OtpInvalidFailure)          return l.errInvalidCredentials;
    if (failure is OtpExpiredFailure)          return _otpExpired(l);
    if (failure is TeacherCodeInvalidFailure)  return l.errTeacherCode;
    if (failure is TeacherCodeExpiredFailure)  return l.errTeacherCode;
    if (failure is AlreadyLinkedFailure)       return _alreadyLinked(l);
    if (failure is DeviceNotTrustedFailure)    return l.errDeviceNew;
    if (failure is EmailAlreadyExistsFailure)  return l.errEmailExists;
    if (failure is TermsNotAcceptedFailure)    return l.termsRequired;
    if (failure is NetworkFailure)             return l.errNetwork;
    if (failure is TimeoutFailure)             return l.errTimeout;
    if (failure is ServerFailure)              return l.errServer;
    if (failure is RateLimitFailure)           return l.errTooManyAttempts;
    if (failure is ValidationFailure)          return failure.message;

    // ── Fallback by error code ───────────────────────────────────────────
    switch (failure.code) {
      case 'AUTH_001': return l.errInvalidCredentials;
      case 'AUTH_002': return l.errAccountNotFound;
      case 'AUTH_003': return l.errAccountSuspended;
      case 'AUTH_005': return l.errEmailNotVerified;
      case 'AUTH_006':
      case 'AUTH_007':
      case 'AUTH_008': return l.errSessionExpired;
      case 'AUTH_009': return l.errMaxDevices;
      case 'AUTH_010': return l.errTooManyAttempts;
      case 'AUTH_011':
      case 'AUTH_012': return _otpExpired(l);
      case 'AUTH_013':
      case 'AUTH_014': return l.errTeacherCode;
      case 'AUTH_017': return l.errDeviceNew;
      case 'REG_001':  return l.errEmailExists;
      case 'NET_001':  return l.errNetwork;
      case 'NET_002':  return l.errTimeout;
      case 'NET_003':  return l.errServer;
      default:         return l.errUnknown;
    }
  }

  // ── Private helpers for strings not yet in AppLocalizations ─────────────
  static String _otpExpired(AppLocalizations l) {
    // Both OTP invalid & expired map to errUnknown if not in l10n yet
    // Add otpExpired/otpInvalid to AppLocalizations to improve this
    return l.errUnknown;
  }

  static String _alreadyLinked(AppLocalizations l) {
    return l.errUnknown; // Replace with l.alreadyLinked when added to l10n
  }
}
