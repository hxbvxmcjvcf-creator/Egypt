import 'package:equatable/equatable.dart';

/// Base domain failure — UI maps code → localised message.
abstract class Failure extends Equatable {
  final String code;
  final String message;
  const Failure({required this.code, required this.message});
  @override
  List<Object?> get props => [code, message];
}

class InvalidCredentialsFailure  extends Failure { const InvalidCredentialsFailure()  : super(code: 'AUTH_001', message: 'Invalid credentials'); }
class AccountNotFoundFailure     extends Failure { const AccountNotFoundFailure()     : super(code: 'AUTH_002', message: 'Account not found'); }
class AccountSuspendedFailure    extends Failure { const AccountSuspendedFailure()    : super(code: 'AUTH_003', message: 'Account suspended'); }
class AccountDeletedFailure      extends Failure { const AccountDeletedFailure()      : super(code: 'AUTH_004', message: 'Account deleted'); }
class EmailNotVerifiedFailure    extends Failure { const EmailNotVerifiedFailure()    : super(code: 'AUTH_005', message: 'Email not verified'); }
class TokenExpiredFailure        extends Failure { const TokenExpiredFailure()        : super(code: 'AUTH_006', message: 'Token expired'); }
class TokenInvalidFailure        extends Failure { const TokenInvalidFailure()        : super(code: 'AUTH_007', message: 'Token invalid'); }
class RefreshTokenExpiredFailure extends Failure { const RefreshTokenExpiredFailure() : super(code: 'AUTH_008', message: 'Refresh token expired'); }
class SessionLimitFailure        extends Failure { const SessionLimitFailure()        : super(code: 'AUTH_009', message: 'Session limit exceeded'); }
class OtpInvalidFailure          extends Failure { const OtpInvalidFailure()          : super(code: 'AUTH_011', message: 'Invalid OTP'); }
class OtpExpiredFailure          extends Failure { const OtpExpiredFailure()          : super(code: 'AUTH_012', message: 'OTP expired'); }
class TeacherCodeInvalidFailure  extends Failure { const TeacherCodeInvalidFailure()  : super(code: 'AUTH_013', message: 'Invalid teacher code'); }
class TeacherCodeExpiredFailure  extends Failure { const TeacherCodeExpiredFailure()  : super(code: 'AUTH_014', message: 'Teacher code expired'); }
class AlreadyLinkedFailure       extends Failure { const AlreadyLinkedFailure()       : super(code: 'AUTH_015', message: 'Already linked'); }
class DeviceNotTrustedFailure    extends Failure { const DeviceNotTrustedFailure()    : super(code: 'AUTH_017', message: 'New device detected'); }
class EmailAlreadyExistsFailure  extends Failure { const EmailAlreadyExistsFailure()  : super(code: 'REG_001',  message: 'Email already exists'); }
class TermsNotAcceptedFailure    extends Failure { const TermsNotAcceptedFailure()    : super(code: 'REG_004',  message: 'Terms not accepted'); }
class NetworkFailure             extends Failure { const NetworkFailure()             : super(code: 'NET_001',  message: 'No internet'); }
class TimeoutFailure             extends Failure { const TimeoutFailure()             : super(code: 'NET_002',  message: 'Request timeout'); }
class ServerFailure              extends Failure { const ServerFailure([String msg = 'Server error']) : super(code: 'NET_003', message: msg); }
class ValidationFailure          extends Failure { const ValidationFailure(String msg) : super(code: 'VAL_001', message: msg); }
class UnknownFailure             extends Failure { const UnknownFailure([String msg = 'Unknown error']) : super(code: 'ERR_000', message: msg); }

class RateLimitFailure extends Failure {
  final int retryAfterSeconds;
  const RateLimitFailure({this.retryAfterSeconds = 60})
      : super(code: 'AUTH_010', message: 'Rate limit exceeded');
  @override
  List<Object?> get props => [...super.props, retryAfterSeconds];
}
