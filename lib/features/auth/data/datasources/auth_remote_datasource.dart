import 'package:dartz/dartz.dart';

import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/services/interfaces/i_auth_service.dart';
import 'package:edu_auth/features/auth/data/models/auth_request_models.dart';
import 'package:edu_auth/features/auth/data/models/session_model.dart';
import 'package:edu_auth/features/auth/data/models/user_model.dart';

/// Bridges domain ↔ [IAuthService].
/// Maps every thrown exception to a typed [Failure].
///
/// This class is ONLY responsible for:
///   1. Calling IAuthService methods.
///   2. Wrapping results in Either<Failure, T>.
///   3. Mapping error codes → concrete Failure subclasses.
class AuthRemoteDatasource {
  final IAuthService _service;

  const AuthRemoteDatasource(this._service);

  /// Exposed for audit calls from AuthRepositoryImpl.
  IAuthService get service => _service;

  // ══════════════════════════════════════════════════════════════════════════
  // GENERIC WRAPPER
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on Exception catch (e) {
      final code = e.toString().replaceAll('Exception: ', '');
      AppLogger.error('AuthRemoteDatasource: [$code]', error: e);
      return Left(_mapCode(code));
    } catch (e, st) {
      AppLogger.error('AuthRemoteDatasource: unknown error', error: e, st: st);
      return const Left(UnknownFailure());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR CODE MAPPING
  // ══════════════════════════════════════════════════════════════════════════

  Failure _mapCode(String code) {
    switch (code) {
      case 'AUTH_001': return const InvalidCredentialsFailure();
      case 'AUTH_002': return const AccountNotFoundFailure();
      case 'AUTH_003': return const AccountSuspendedFailure();
      case 'AUTH_004': return const AccountDeletedFailure();
      case 'AUTH_005': return const EmailNotVerifiedFailure();
      case 'AUTH_006': return const TokenExpiredFailure();
      case 'AUTH_007': return const TokenInvalidFailure();
      case 'AUTH_008': return const RefreshTokenExpiredFailure();
      case 'AUTH_009': return const SessionLimitFailure();
      case 'AUTH_010': return const RateLimitFailure();
      case 'AUTH_011': return const OtpInvalidFailure();
      case 'AUTH_012': return const OtpExpiredFailure();
      case 'AUTH_013': return const TeacherCodeInvalidFailure();
      case 'AUTH_014': return const TeacherCodeExpiredFailure();
      case 'AUTH_015': return const AlreadyLinkedFailure();
      case 'AUTH_017': return const DeviceNotTrustedFailure();
      case 'REG_001':  return const EmailAlreadyExistsFailure();
      case 'REG_004':  return const TermsNotAcceptedFailure();
      case 'NET_001':  return const NetworkFailure();
      case 'NET_002':  return const TimeoutFailure();
      case 'NET_003':  return const ServerFailure();
      default:         return UnknownFailure(code);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELEGATED CALLS
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<Failure, SessionModel>> login(LoginRequest req) =>
      _run(() => _service.login(req));

  Future<Either<Failure, UserModel>> registerStudent(RegisterStudentRequest req) =>
      _run(() => _service.registerStudent(req));

  Future<Either<Failure, UserModel>> registerTeacher(RegisterTeacherRequest req) =>
      _run(() => _service.registerTeacher(req));

  Future<Either<Failure, bool>> verifyOtp(OtpRequest req) =>
      _run(() => _service.verifyOtp(req));

  Future<Either<Failure, bool>> resendOtp({
    required String userId,
    required String purpose,
  }) =>
      _run(() => _service.resendOtp(userId: userId, purpose: purpose));

  Future<Either<Failure, bool>> forgotPassword(String email) =>
      _run(() => _service.forgotPassword(email: email));

  Future<Either<Failure, bool>> resetPassword(
    String userId,
    String otp,
    String newPw,
  ) =>
      _run(() => _service.resetPassword(
            userId:      userId,
            otp:         otp,
            newPassword: newPw,
          ));

  Future<Either<Failure, bool>> linkToTeacher(LinkTeacherRequest req) =>
      _run(() => _service.linkToTeacher(req));

  Future<Either<Failure, SessionModel>> refreshToken(
    String rt,
    String deviceId,
  ) =>
      _run(() => _service.refreshToken(refreshToken: rt, deviceId: deviceId));

  Future<Either<Failure, bool>> logout(String at, String deviceId) =>
      _run(() => _service.logout(accessToken: at, deviceId: deviceId));

  Future<Either<Failure, bool>> logoutAll(String at) =>
      _run(() => _service.logoutAllDevices(accessToken: at));

  Future<Either<Failure, UserModel>> getCurrentUser(String at) =>
      _run(() => _service.getCurrentUser(accessToken: at));

  Future<Either<Failure, bool>> verifyEmail(String userId, String token) =>
      _run(() => _service.verifyEmail(userId: userId, token: token));
}
