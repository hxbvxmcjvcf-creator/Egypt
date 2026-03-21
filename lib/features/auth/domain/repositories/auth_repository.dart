import 'package:dartz/dartz.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/features/auth/domain/entities/user_entity.dart';
import 'package:edu_auth/features/auth/domain/entities/session_entity.dart';

/// Abstract auth repository — implemented in data layer.
/// Domain layer depends ONLY on this interface.
abstract class AuthRepository {
  // ── Login ──────────────────────────────────────────────────────────────
  Future<Either<Failure, SessionEntity>> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceDescription,
  });

  // ── Registration ───────────────────────────────────────────────────────
  Future<Either<Failure, UserEntity>> registerStudent({
    required String email,
    required String password,
    required String fullName,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
    required String deviceId,
  });

  Future<Either<Failure, UserEntity>> registerTeacher({
    required String email,
    required String password,
    required String fullName,
    required bool acceptedTerms,
    required bool acceptedPrivacy,
    required String deviceId,
  });

  // ── OTP ────────────────────────────────────────────────────────────────
  Future<Either<Failure, bool>> verifyOtp({
    required String userId,
    required String otp,
    required String purpose, // 'login' | 'reset' | 'verify_email'
  });

  Future<Either<Failure, bool>> resendOtp({
    required String userId,
    required String purpose,
  });

  // ── Password Recovery ──────────────────────────────────────────────────
  Future<Either<Failure, bool>> forgotPassword({required String email});

  Future<Either<Failure, bool>> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
  });

  // ── Teacher Linking ────────────────────────────────────────────────────
  Future<Either<Failure, bool>> linkToTeacher({
    required String studentId,
    required String teacherCode,
    required String accessToken,
  });

  // ── Session ────────────────────────────────────────────────────────────
  Future<Either<Failure, SessionEntity>> refreshToken({
    required String refreshToken,
    required String deviceId,
  });

  Future<Either<Failure, bool>> logout({
    required String accessToken,
    required String deviceId,
  });

  Future<Either<Failure, bool>> logoutAllDevices({
    required String accessToken,
  });

  // ── User ───────────────────────────────────────────────────────────────
  Future<Either<Failure, UserEntity>> getCurrentUser({
    required String accessToken,
  });

  Future<Either<Failure, bool>> verifyEmail({
    required String userId,
    required String token,
  });

  // ── Audit ──────────────────────────────────────────────────────────────
  Future<void> logAuditEvent({
    required String action,
    required String deviceId,
    String? userId,
    bool success = true,
    String? failureCode,
    Map<String, dynamic>? metadata,
  });
}
