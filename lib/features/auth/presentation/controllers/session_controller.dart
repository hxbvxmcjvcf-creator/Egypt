// lib/features/auth/presentation/controllers/session_controller.dart
// ALWAYS import with: package:edu_auth/features/auth/presentation/controllers/session_controller.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/di/injection_container.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/core/utils/secure_storage.dart';
import 'package:edu_auth/features/auth/domain/entities/session_entity.dart';
import 'package:edu_auth/features/auth/domain/repositories/auth_repository.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
// FIX: sl<> only in the Provider factory — not inside the controller class.
final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) {
  return SessionController(
    authRepository: sl<AuthRepository>(),
    authController: ref.read(authControllerProvider.notifier),
  );
});

// ══════════════════════════════════════════════════════════════════════════════
// SESSION CONTROLLER
// ══════════════════════════════════════════════════════════════════════════════

/// Manages:
///   - Inactivity timer (auto-logout after N minutes of no interaction)
///   - Token refresh (auto-renew before expiry)
///   - Session validation (Zero-Trust: re-check on every protected screen)
///   - Concurrent session helpers
class SessionController extends StateNotifier<SessionState> {
  final AuthRepository _authRepo;
  final AuthController _authController;

  Timer? _inactivityTimer;
  Timer? _tokenRefreshTimer;

  static const int _inactivityWarningMinutes  = 2;
  static const int _tokenRefreshBufferMinutes = 5;

  SessionController({
    required AuthRepository authRepository,
    required AuthController authController,
  })  : _authRepo       = authRepository,
        _authController = authController,
        super(const SessionState());

  // ══════════════════════════════════════════════════════════════════════════
  // START SESSION
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> startSession(SessionEntity session) async {
    AppLogger.info('SessionController: session started → userId=${session.userId}');

    state = const SessionState(
      status:          SessionStatus.active,
      lastActivityAt:  null,
      inactiveSeconds: 0,
    );

    _scheduleInactivityTimer();
    _scheduleTokenRefresh(session);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTIVITY HEARTBEAT
  // ══════════════════════════════════════════════════════════════════════════

  void recordActivity() {
    if (state.status == SessionStatus.expired ||
        state.status == SessionStatus.loggedOut) return;

    state = state.copyWith(
      status:          SessionStatus.active,
      lastActivityAt:  DateTime.now(),
      inactiveSeconds: 0,
    );
    _scheduleInactivityTimer();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INACTIVITY TIMER
  // FIX: cancel existing timer before creating a new one.
  // ══════════════════════════════════════════════════════════════════════════

  void _scheduleInactivityTimer() {
    _inactivityTimer?.cancel();

    final totalSeconds = AppConstants.inactivityMinutes * 60;
    final warningAt    = totalSeconds - (_inactivityWarningMinutes * 60);

    _inactivityTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now()
          .difference(state.lastActivityAt ?? DateTime.now())
          .inSeconds;

      state = state.copyWith(inactiveSeconds: elapsed);

      if (elapsed >= totalSeconds) {
        timer.cancel();
        _onInactivityTimeout();
      } else if (elapsed >= warningAt &&
          state.status != SessionStatus.inactivityWarning) {
        AppLogger.warn('SessionController: inactivity warning');
        state = state.copyWith(status: SessionStatus.inactivityWarning);
      }
    });
  }

  Future<void> _onInactivityTimeout() async {
    AppLogger.security('Inactivity timeout — forcing logout');
    state = state.copyWith(status: SessionStatus.expired);
    await _authController.logout();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TOKEN AUTO-REFRESH
  // FIX: cancel existing refresh timer before scheduling a new one.
  // ══════════════════════════════════════════════════════════════════════════

  void _scheduleTokenRefresh(SessionEntity session) {
    _tokenRefreshTimer?.cancel();

    final refreshIn = session.accessTokenExpiry
        .subtract(Duration(minutes: _tokenRefreshBufferMinutes))
        .difference(DateTime.now());

    if (refreshIn.isNegative) {
      _doRefreshToken();
      return;
    }

    AppLogger.info(
        'SessionController: token refresh in ${refreshIn.inMinutes} min');
    _tokenRefreshTimer = Timer(refreshIn, _doRefreshToken);
  }

  Future<void> _doRefreshToken() async {
    if (!mounted) return;

    AppLogger.info('SessionController: refreshing token');

    final rt       = await SecureStorage.read(AppConstants.kRefreshToken);
    final deviceId = await SecureStorage.read(AppConstants.kDeviceId) ?? 'unknown';

    if (rt == null) {
      AppLogger.warn('SessionController: no refresh token — logging out');
      await _authController.logout();
      return;
    }

    final result = await _authRepo.refreshToken(
      refreshToken: rt,
      deviceId:     deviceId,
    );

    result.fold(
      (failure) async {
        AppLogger.warn('SessionController: refresh failed → ${failure.code}');
        if (failure is RefreshTokenExpiredFailure) {
          if (mounted) state = state.copyWith(status: SessionStatus.expired);
          await _authController.logout();
        }
      },
      (newSession) {
        AppLogger.info('SessionController: token refreshed ✓');
        if (mounted) _scheduleTokenRefresh(newSession);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SESSION VALIDATION (Zero-Trust)
  // FIX: DateTime.tryParse() + null-check
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> isSessionValid() async {
    final token     = await SecureStorage.read(AppConstants.kAccessToken);
    final expiryRaw = await SecureStorage.read(AppConstants.kSessionExpiry);

    if (token == null) {
      AppLogger.debug('SessionController: no access token');
      return false;
    }

    // FIX: safe parse with tryParse + null-check
    final expiryDt = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
    if (expiryDt == null || DateTime.now().isAfter(expiryDt)) {
      AppLogger.warn('SessionController: access token expired');
      return false;
    }

    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // END SESSION
  // ══════════════════════════════════════════════════════════════════════════

  void endSession() {
    _inactivityTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    if (mounted) state = state.copyWith(status: SessionStatus.loggedOut);
    AppLogger.info('SessionController: session ended');
  }

  // FIX: dispose() cancels ALL timers under ALL conditions.
  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    super.dispose();
  }
}
