import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/core/utils/secure_storage.dart';
import 'package:edu_auth/core/feature_flags/feature_flag_service.dart';
import 'package:edu_auth/features/auth/domain/entities/session_entity.dart';
import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';
import 'package:edu_auth/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:edu_auth/features/auth/data/models/auth_request_models.dart';
import 'package:edu_auth/features/auth/data/models/session_model.dart';
import 'package:edu_auth/features/auth/data/models/user_model.dart';

/// Concrete implementation of [AuthRepository].
///
/// Responsibilities:
/// - Delegates every call to [AuthRemoteDatasource] (which talks to IAuthService).
/// - Persists / reads session tokens from [SecureStorage].
/// - Applies offline-first caching for the current user.
/// - Enforces frontend-side rate-limiting mirror (backend is authoritative).
/// - Honours [FeatureFlagService] guards before executing operations.
///
/// Data Flow:
///   UseCase → AuthRepositoryImpl → AuthRemoteDatasource → IAuthService
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final FeatureFlagService   _flags;

  const AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required FeatureFlagService   flags,
  })  : _remote = remote,
        _flags  = flags;

  // ══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, SessionEntity>> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceDescription,
  }) async {
    AppLogger.info('AuthRepo: login attempt → $email');

    // ── Frontend rate-limit mirror ─────────────────────────────────────────
    if (_flags.rateLimiting) {
      final lockResult = await _checkLocalLockout(email);
      if (lockResult != null) return Left(lockResult);
    }

    final result = await _remote.login(
      LoginRequest(
        email:             email,
        password:          password,
        deviceId:          deviceId,
        deviceDescription: deviceDescription,
      ),
    );

    return result.fold(
      (failure) async {
        // Increment local counter on credential failures only
        if (failure is InvalidCredentialsFailure) {
          await _incrementLoginAttempts(email);
        }
        AppLogger.warn('AuthRepo: login failed → ${failure.code}');
        return Left(failure);
      },
      (session) async {
        await _persistSession(session);
        await _resetLoginAttempts(email);
        AppLogger.info('AuthRepo: login success → userId=${session.userId}');
        return Right(session);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER STUDENT
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, UserEntity>> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required bool   acceptedTerms,
    required bool   acceptedPrivacy,
    required String deviceId,
  }) async {
    AppLogger.info('AuthRepo: registerStudent → $email');

    final result = await _remote.registerStudent(
      RegisterStudentRequest(
        email:          email,
        password:       password,
        fullName:       fullName,
        deviceId:       deviceId,
        acceptedTerms:  acceptedTerms,
        acceptedPrivacy: acceptedPrivacy,
      ),
    );

    result.fold(
      (f) => AppLogger.warn('AuthRepo: registerStudent failed → ${f.code}'),
      (u) => AppLogger.info('AuthRepo: registerStudent success → ${u.id}'),
    );

    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER TEACHER
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, UserEntity>> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required bool   acceptedTerms,
    required bool   acceptedPrivacy,
    required String deviceId,
  }) async {
    AppLogger.info('AuthRepo: registerTeacher → $email');

    final result = await _remote.registerTeacher(
      RegisterTeacherRequest(
        email:          email,
        password:       password,
        fullName:       fullName,
        deviceId:       deviceId,
        acceptedTerms:  acceptedTerms,
        acceptedPrivacy: acceptedPrivacy,
      ),
    );

    result.fold(
      (f) => AppLogger.warn('AuthRepo: registerTeacher failed → ${f.code}'),
      (u) => AppLogger.info('AuthRepo: registerTeacher success → ${u.id} code=${u.teacherCode}'),
    );

    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // OTP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String userId,
    required String otp,
    required String purpose,
  }) async {
    AppLogger.info('AuthRepo: verifyOtp → userId=$userId purpose=$purpose');

    if (!_flags.otpEnabled) {
      AppLogger.info('AuthRepo: OTP feature disabled — auto-pass');
      return const Right(true);
    }

    return _remote.verifyOtp(OtpRequest(userId: userId, otp: otp, purpose: purpose));
  }

  @override
  Future<Either<Failure, bool>> resendOtp({
    required String userId,
    required String purpose,
  }) async {
    AppLogger.info('AuthRepo: resendOtp → userId=$userId');
    return _remote.resendOtp(userId: userId, purpose: purpose);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PASSWORD RECOVERY
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, bool>> forgotPassword({required String email}) async {
    AppLogger.info('AuthRepo: forgotPassword → $email');
    return _remote.forgotPassword(email);
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
  }) async {
    AppLogger.info('AuthRepo: resetPassword → userId=$userId');
    return _remote.resetPassword(userId, otp, newPassword);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TEACHER LINKING
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, bool>> linkToTeacher({
    required String studentId,
    required String teacherCode,
    required String accessToken,
  }) async {
    AppLogger.info('AuthRepo: linkToTeacher → studentId=$studentId code=$teacherCode');

    if (!_flags.teacherCodeSystem) {
      return const Left(UnknownFailure('Teacher code system is disabled'));
    }

    return _remote.linkToTeacher(
      LinkTeacherRequest(studentId: studentId, teacherCode: teacherCode),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SESSION / TOKEN
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, SessionEntity>> refreshToken({
    required String refreshToken,
    required String deviceId,
  }) async {
    AppLogger.info('AuthRepo: refreshToken');

    final result = await _remote.refreshToken(refreshToken, deviceId);

    return result.fold(
      (f) {
        AppLogger.warn('AuthRepo: refreshToken failed → ${f.code}');
        return Left(f);
      },
      (session) async {
        await _persistSession(session);
        AppLogger.info('AuthRepo: refreshToken success');
        return Right(session);
      },
    );
  }

  @override
  Future<Either<Failure, bool>> logout({
    required String accessToken,
    required String deviceId,
  }) async {
    AppLogger.info('AuthRepo: logout → deviceId=$deviceId');
    final result = await _remote.logout(accessToken, deviceId);
    await _clearSession();
    return result;
  }

  @override
  Future<Either<Failure, bool>> logoutAllDevices({
    required String accessToken,
  }) async {
    AppLogger.info('AuthRepo: logoutAllDevices');
    final result = await _remote.logoutAll(accessToken);
    await _clearSession();
    return result;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser({
    required String accessToken,
  }) async {
    AppLogger.info('AuthRepo: getCurrentUser');

    final result = await _remote.getCurrentUser(accessToken);

    // Cache user locally for offline-first reads
    result.fold(
      (f) => AppLogger.warn('AuthRepo: getCurrentUser failed → ${f.code}'),
      (u)  => _cacheUser(u),
    );

    return result;
  }

  @override
  Future<Either<Failure, bool>> verifyEmail({
    required String userId,
    required String token,
  }) async {
    AppLogger.info('AuthRepo: verifyEmail → userId=$userId');
    return _remote.verifyEmail(userId, token);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUDIT
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> logAuditEvent({
    required String action,
    required String deviceId,
    String?  userId,
    bool     success    = true,
    String?  failureCode,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_flags.auditLogging) return;
    await _remote.service.logAudit(
      action:      action,
      deviceId:    deviceId,
      userId:      userId,
      success:     success,
      failureCode: failureCode,
      metadata:    metadata,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SESSION PERSISTENCE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _persistSession(SessionModel session) async {
    await Future.wait([
      SecureStorage.write(AppConstants.kAccessToken,   session.accessToken),
      SecureStorage.write(AppConstants.kRefreshToken,  session.refreshToken),
      SecureStorage.write(AppConstants.kUserId,        session.userId),
      SecureStorage.write(AppConstants.kSessionExpiry, session.accessTokenExpiry.toIso8601String()),
    ]);
    AppLogger.debug('AuthRepo: session persisted → userId=${session.userId}');
  }

  Future<void> _clearSession() async {
    await Future.wait([
      SecureStorage.delete(AppConstants.kAccessToken),
      SecureStorage.delete(AppConstants.kRefreshToken),
      SecureStorage.delete(AppConstants.kUserId),
      SecureStorage.delete(AppConstants.kSessionExpiry),
      SecureStorage.delete(AppConstants.kUserCache),
    ]);
    AppLogger.debug('AuthRepo: session cleared');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER CACHE HELPERS (offline-first)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _cacheUser(UserModel user) async {
    try {
      // Store role separately for fast auth-guard reads
      await SecureStorage.write(AppConstants.kUserRole,
          user.role == UserRole.teacher ? 'teacher' : 'student');
    } catch (e) {
      AppLogger.warn('AuthRepo: failed to cache user role', error: e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RATE-LIMIT HELPERS (frontend mirror — backend is authoritative)
  // ══════════════════════════════════════════════════════════════════════════

  Future<RateLimitFailure?> _checkLocalLockout(String email) async {
    final raw = await SecureStorage.read('${AppConstants.kLockoutUntil}_$email');
    if (raw == null) return null;

    final until = DateTime.tryParse(raw);
    if (until == null) return null;

    if (DateTime.now().isBefore(until)) {
      final secs = until.difference(DateTime.now()).inSeconds;
      AppLogger.warn('AuthRepo: local lockout active → ${secs}s remaining');
      return RateLimitFailure(retryAfterSeconds: secs);
    }

    // Lockout expired — clean up
    await _resetLoginAttempts(email);
    return null;
  }

  Future<void> _incrementLoginAttempts(String email) async {
    final raw      = await SecureStorage.read('${AppConstants.kLoginAttempts}_$email');
    final attempts = int.tryParse(raw ?? '0') ?? 0;
    final next     = attempts + 1;

    await SecureStorage.write('${AppConstants.kLoginAttempts}_$email', '$next');
    AppLogger.warn('AuthRepo: login attempt #$next for $email');

    if (next >= AppConstants.maxLoginAttempts) {
      final lockUntil = DateTime.now()
          .add(Duration(minutes: AppConstants.lockoutDurationMinutes));
      await SecureStorage.write(
          '${AppConstants.kLockoutUntil}_$email', lockUntil.toIso8601String());
      AppLogger.security('Local lockout triggered', userId: email);
    }
  }

  Future<void> _resetLoginAttempts(String email) async {
    await SecureStorage.delete('${AppConstants.kLoginAttempts}_$email');
    await SecureStorage.delete('${AppConstants.kLockoutUntil}_$email');
  }
}
