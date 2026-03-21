// lib/features/auth/presentation/controllers/auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';
import 'package:edu_auth/features/auth/domain/entities/session_entity.dart';
import 'package:edu_auth/core/errors/failures.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AUTH STATE
// ══════════════════════════════════════════════════════════════════════════════
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState { const AuthInitial(); }

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});
  @override List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final UserEntity    user;
  final SessionEntity session;
  const AuthAuthenticated({required this.user, required this.session});
  @override List<Object?> get props => [user.id, session.accessToken];
}

class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }

class AuthRequiresOtp extends AuthState {
  final String userId;
  final String email;
  final String purpose; // use OtpPurpose.xxx.value — never hardcode
  const AuthRequiresOtp({required this.userId, required this.email, required this.purpose});
  @override List<Object?> get props => [userId, purpose];
}

class AuthEmailVerificationPending extends AuthState {
  final UserEntity user;
  const AuthEmailVerificationPending({required this.user});
  @override List<Object?> get props => [user.id];
}

class AuthPasswordResetSent extends AuthState {
  final String email;
  final String userId;
  const AuthPasswordResetSent({required this.email, required this.userId});
  @override List<Object?> get props => [email, userId];
}

class AuthPasswordResetSuccess extends AuthState { const AuthPasswordResetSuccess(); }

class AuthTeacherLinked extends AuthState { const AuthTeacherLinked(); }

class AuthError extends AuthState {
  final Failure failure;
  const AuthError(this.failure);
  @override List<Object?> get props => [failure.code];
}

// ══════════════════════════════════════════════════════════════════════════════
// OTP STATE
// ══════════════════════════════════════════════════════════════════════════════
class OtpState extends Equatable {
  final bool     isLoading;
  final bool     isVerified;
  final Failure? failure;
  final int      resendCooldownSec;
  final bool     canResend;

  const OtpState({
    this.isLoading         = false,
    this.isVerified        = false,
    this.failure           = null,
    this.resendCooldownSec = 0,
    this.canResend         = true,
  });

  OtpState copyWith({
    bool?    isLoading,
    bool?    isVerified,
    Failure? failure,
    int?     resendCooldownSec,
    bool?    canResend,
    bool     clearFailure = false,
  }) => OtpState(
    isLoading:         isLoading         ?? this.isLoading,
    isVerified:        isVerified        ?? this.isVerified,
    failure:           clearFailure ? null : failure ?? this.failure,
    resendCooldownSec: resendCooldownSec ?? this.resendCooldownSec,
    canResend:         canResend         ?? this.canResend,
  );

  @override
  List<Object?> get props => [isLoading, isVerified, failure, resendCooldownSec, canResend];
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION STATE
// ══════════════════════════════════════════════════════════════════════════════
enum SessionStatus { active, inactivityWarning, expired, loggedOut }

class SessionState extends Equatable {
  final SessionStatus status;
  final DateTime?     lastActivityAt;
  final int           inactiveSeconds;

  const SessionState({
    this.status          = SessionStatus.active,
    this.lastActivityAt  = null,
    this.inactiveSeconds = 0,
  });

  SessionState copyWith({
    SessionStatus? status,
    DateTime?      lastActivityAt,
    int?           inactiveSeconds,
  }) => SessionState(
    status:          status          ?? this.status,
    lastActivityAt:  lastActivityAt  ?? this.lastActivityAt,
    inactiveSeconds: inactiveSeconds ?? this.inactiveSeconds,
  );

  @override
  List<Object?> get props => [status, inactiveSeconds];
}

// ══════════════════════════════════════════════════════════════════════════════
// REGISTER FORM STATE
// ══════════════════════════════════════════════════════════════════════════════
class RegisterFormState extends Equatable {
  final bool     isLoading;
  final bool     acceptedTerms;
  final bool     acceptedPrivacy;
  final int      passwordStrength;
  final Failure? failure;

  const RegisterFormState({
    this.isLoading        = false,
    this.acceptedTerms    = false,
    this.acceptedPrivacy  = false,
    this.passwordStrength = 0,
    this.failure          = null,
  });

  RegisterFormState copyWith({
    bool?    isLoading,
    bool?    acceptedTerms,
    bool?    acceptedPrivacy,
    int?     passwordStrength,
    Failure? failure,
    bool     clearFailure = false,
  }) => RegisterFormState(
    isLoading:        isLoading        ?? this.isLoading,
    acceptedTerms:    acceptedTerms    ?? this.acceptedTerms,
    acceptedPrivacy:  acceptedPrivacy  ?? this.acceptedPrivacy,
    passwordStrength: passwordStrength ?? this.passwordStrength,
    failure:          clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [isLoading, acceptedTerms, acceptedPrivacy, passwordStrength, failure?.code];
}
