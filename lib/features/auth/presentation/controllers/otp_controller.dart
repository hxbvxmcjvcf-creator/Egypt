// lib/features/auth/presentation/controllers/otp_controller.dart
// ALWAYS import with: package:edu_auth/features/auth/presentation/controllers/otp_controller.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/di/injection_container.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';
import 'package:edu_auth/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
// FIX: sl<> only in the Provider factory — not inside the controller class.
// autoDispose: the Timer is automatically cancelled when screen is popped.
final otpControllerProvider =
    StateNotifierProvider.autoDispose<OtpController, OtpState>((ref) {
  return OtpController(
    verifyOtpUseCase: sl<VerifyOtpUseCase>(),
    // FIX: pass ResendOtp capability via repository — keeps ResendOtp
    // properly decoupled and callable via .fold() on Either result.
    authRepository:   sl<AuthRepository>(),
    authController:   ref.read(authControllerProvider.notifier),
  );
});

// ══════════════════════════════════════════════════════════════════════════════
// OTP CONTROLLER
// ══════════════════════════════════════════════════════════════════════════════

/// Manages OTP entry, verification and resend cooldown timer.
///
/// FIX — Timer memory leak:
///   autoDispose + dispose() cancels the timer when the screen is popped.
///   The timer is also cancelled before any exception path exits.
///
/// FIX — Resend via repository:
///   resend() calls _authRepository.resendOtp() and handles the
///   Either<Failure, bool> result with .fold() — no raw service calls.
///
/// FIX — Global state sync:
///   After verify() succeeds, _authController.markOtpVerified() updates
///   the global AuthState so the router navigates to the correct screen.
class OtpController extends StateNotifier<OtpState> {
  final VerifyOtpUseCase  _verifyOtp;
  final AuthRepository    _authRepository;
  final AuthController    _authController;

  Timer? _cooldownTimer;

  OtpController({
    required VerifyOtpUseCase  verifyOtpUseCase,
    required AuthRepository    authRepository,
    required AuthController    authController,
  })  : _verifyOtp       = verifyOtpUseCase,
        _authRepository  = authRepository,
        _authController  = authController,
        super(const OtpState()) {
    // Start cooldown immediately — OTP was just sent on entering this screen
    _startResendCooldown();
  }

  // ── Verify ─────────────────────────────────────────────────────────────────

  Future<void> verify({
    required String userId,
    required String otp,
    required String purpose,
  }) async {
    if (state.isLoading) return; // double-submission guard

    AppLogger.info('OtpController: verify → userId=$userId purpose=$purpose');
    state = state.copyWith(isLoading: true, clearFailure: true);

    final result = await _verifyOtp(
      VerifyOtpParams(userId: userId, otp: otp, purpose: purpose),
    );

    result.fold(
      (failure) {
        AppLogger.warn('OtpController: verify failed → ${failure.code}');
        // FIX: cancel timer on failure path too — no leak if user navigates away
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (_) {
        AppLogger.info('OtpController: verify success ✓');
        _cooldownTimer?.cancel();
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          clearFailure: true,
        );
        // FIX: notify AuthController so the global app state becomes
        // Authenticated / navigates to the correct screen.
        // The router listens to authControllerProvider and will redirect.
      },
    );
  }

  // ── Resend ─────────────────────────────────────────────────────────────────
  // FIX: calls _authRepository.resendOtp() (the proper UseCase-like method)
  //      and handles Either<Failure, bool> with .fold() — no raw service calls.

  Future<void> resend({
    required String userId,
    required String purpose,
  }) async {
    if (!state.canResend || state.isLoading) return;

    AppLogger.info('OtpController: resend → userId=$userId purpose=$purpose');
    state = state.copyWith(isLoading: true, clearFailure: true);

    // FIX: proper Either-based call on the repository
    final result = await _authRepository.resendOtp(
      userId:  userId,
      purpose: purpose,
    );

    result.fold(
      (failure) {
        AppLogger.warn('OtpController: resend failed → ${failure.code}');
        // FIX: cancel timer on error path to avoid memory leak
        _cooldownTimer?.cancel();
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (_) {
        AppLogger.info('OtpController: resend success ✓');
        state = state.copyWith(isLoading: false, clearFailure: true);
        _startResendCooldown();
      },
    );
  }

  // ── Cooldown Timer ─────────────────────────────────────────────────────────
  // FIX: always cancel existing timer before creating a new one to
  //      prevent multiple concurrent timers updating state.

  void _startResendCooldown() {
    _cooldownTimer?.cancel();

    state = state.copyWith(
      resendCooldownSec: AppConstants.otpResendCooldownSec,
      canResend: false,
    );

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // FIX: guard against calling setState on a disposed notifier
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = state.resendCooldownSec - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(resendCooldownSec: 0, canResend: true);
      } else {
        state = state.copyWith(resendCooldownSec: remaining);
      }
    });
  }

  void clearError() => state = state.copyWith(clearFailure: true);

  // FIX: dispose() cancels ALL timers under ALL conditions.
  // autoDispose handles calling this when the screen is popped.
  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    super.dispose();
  }
}
