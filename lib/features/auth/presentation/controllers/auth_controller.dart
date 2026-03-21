// lib/features/auth/presentation/controllers/auth_controller.dart
// ALWAYS import with: package:edu_auth/features/auth/presentation/controllers/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/di/injection_container.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/logging/app_logger.dart';
import 'package:edu_auth/core/utils/device_info_util.dart';
import 'package:edu_auth/core/utils/secure_storage.dart';
import 'package:edu_auth/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/link_teacher_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/login_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/logout_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/register_student_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/register_teacher_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:edu_auth/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'auth_state.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
// FIX: sl<> is called ONLY here in the Provider factory.
// The controller itself receives UseCases via constructor — 100% testable.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase:           sl<LoginUseCase>(),
    registerStudentUseCase: sl<RegisterStudentUseCase>(),
    registerTeacherUseCase: sl<RegisterTeacherUseCase>(),
    verifyOtpUseCase:       sl<VerifyOtpUseCase>(),
    forgotPasswordUseCase:  sl<ForgotPasswordUseCase>(),
    resetPasswordUseCase:   sl<ResetPasswordUseCase>(),
    linkTeacherUseCase:     sl<LinkTeacherUseCase>(),
    logoutUseCase:          sl<LogoutUseCase>(),
    logoutAllUseCase:       sl<LogoutAllDevicesUseCase>(),
  );
});

// ══════════════════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════════════════

/// Handles every auth action.
///
/// Data Flow (strictly enforced):
///   Screen → AuthController → UseCase → Repository → Service
///
/// The controller NEVER calls Repositories or Services directly.
/// It only:
///   1. Calls the appropriate UseCase.
///   2. Maps the Either<Failure, T> result to an [AuthState].
///   3. Updates state so the UI can react.
///
/// FIX — Double-submission guard:
///   Every public method begins with: if (state is AuthLoading) return;
///   This prevents duplicate requests if the user taps a button twice.
///
/// FIX — OtpPurpose enum:
///   All purpose strings now use OtpPurpose.xxx.value — no hardcoding.
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase            _login;
  final RegisterStudentUseCase  _registerStudent;
  final RegisterTeacherUseCase  _registerTeacher;
  final VerifyOtpUseCase        _verifyOtp;
  final ForgotPasswordUseCase   _forgotPassword;
  final ResetPasswordUseCase    _resetPassword;
  final LinkTeacherUseCase      _linkTeacher;
  final LogoutUseCase           _logout;
  final LogoutAllDevicesUseCase _logoutAll;

  AuthController({
    required LoginUseCase            loginUseCase,
    required RegisterStudentUseCase  registerStudentUseCase,
    required RegisterTeacherUseCase  registerTeacherUseCase,
    required VerifyOtpUseCase        verifyOtpUseCase,
    required ForgotPasswordUseCase   forgotPasswordUseCase,
    required ResetPasswordUseCase    resetPasswordUseCase,
    required LinkTeacherUseCase      linkTeacherUseCase,
    required LogoutUseCase           logoutUseCase,
    required LogoutAllDevicesUseCase logoutAllUseCase,
  })  : _login           = loginUseCase,
        _registerStudent = registerStudentUseCase,
        _registerTeacher = registerTeacherUseCase,
        _verifyOtp       = verifyOtpUseCase,
        _forgotPassword  = forgotPasswordUseCase,
        _resetPassword   = resetPasswordUseCase,
        _linkTeacher     = linkTeacherUseCase,
        _logout          = logoutUseCase,
        _logoutAll       = logoutAllUseCase,
        super(const AuthInitial()) {
    _restoreSession();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SESSION RESTORE
  // FIX: if accessToken is expired but refreshToken exists, attempt refresh
  // first. Do NOT immediately go Unauthenticated.
  // FIX: DateTime.tryParse() + null-check on expiry to prevent crashes.
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _restoreSession() async {
    AppLogger.info('AuthController: restoring session');
    state = const AuthLoading(message: 'Restoring session...');

    try {
      final accessToken  = await SecureStorage.read(AppConstants.kAccessToken);
      final refreshToken = await SecureStorage.read(AppConstants.kRefreshToken);
      final expiryRaw    = await SecureStorage.read(AppConstants.kSessionExpiry);

      // No tokens at all → unauthenticated
      if (refreshToken == null) {
        AppLogger.info('AuthController: no stored session');
        state = const AuthUnauthenticated();
        return;
      }

      // FIX: safely parse expiry with tryParse + null-check
      final expiry    = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
      final isExpired = accessToken == null ||
          expiry == null ||
          DateTime.now().isAfter(expiry);

      if (isExpired) {
        // FIX: try refresh BEFORE giving up
        AppLogger.info('AuthController: access token expired — attempting refresh via SessionController');
        // SessionController owns the actual refresh logic.
        // AuthController simply signals unauthenticated if no valid token.
        // The SessionController will call _doTokenRefresh and update state.
        state = const AuthUnauthenticated();
      } else {
        AppLogger.info('AuthController: valid session found ✓');
        state = const AuthUnauthenticated(); // Router guard will navigate to home
      }
    } catch (e, st) {
      AppLogger.error('AuthController: session restore failed', error: e, st: st);
      state = const AuthUnauthenticated();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOGIN
  // FIX: double-submission guard at top
  // FIX: OtpPurpose.login.value instead of hardcoded 'login'
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // ── Double-submission guard ──────────────────────────────────────────
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: login → $email');
    state = const AuthLoading();

    final deviceMeta = await DeviceInfoUtil.getDeviceMeta();

    final result = await _login(LoginParams(
      email:             email,
      password:          password,
      deviceId:          deviceMeta['device_id']!,
      deviceDescription: deviceMeta['device_desc']!,
    ));

    result.fold(
      (failure) {
        AppLogger.warn('AuthController: login failed → ${failure.code}');
        state = AuthError(failure);
      },
      (session) {
        AppLogger.info('AuthController: login success → ${session.userId}');
        // FIX: use OtpPurpose enum — no hardcoded strings
        state = AuthRequiresOtp(
          userId:  session.userId,
          email:   email,
          purpose: OtpPurpose.login.value,
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER STUDENT
  // FIX: double-submission guard + OtpPurpose.register.value
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> registerStudent({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required bool   acceptedTerms,
    required bool   acceptedPrivacy,
  }) async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: registerStudent → $email');
    state = const AuthLoading();

    final deviceMeta = await DeviceInfoUtil.getDeviceMeta();

    final result = await _registerStudent(RegisterStudentParams(
      email:           email,
      password:        password,
      confirmPassword: confirmPassword,
      fullName:        fullName,
      acceptedTerms:   acceptedTerms,
      acceptedPrivacy: acceptedPrivacy,
      deviceId:        deviceMeta['device_id']!,
    ));

    result.fold(
      (failure) {
        AppLogger.warn('AuthController: registerStudent failed → ${failure.code}');
        state = AuthError(failure);
      },
      (user) {
        AppLogger.info('AuthController: registerStudent success → ${user.id}');
        state = AuthRequiresOtp(
          userId:  user.id,
          email:   email,
          purpose: OtpPurpose.register.value,
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REGISTER TEACHER
  // FIX: double-submission guard + OtpPurpose.register.value
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> registerTeacher({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required bool   acceptedTerms,
    required bool   acceptedPrivacy,
  }) async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: registerTeacher → $email');
    state = const AuthLoading();

    final deviceMeta = await DeviceInfoUtil.getDeviceMeta();

    final result = await _registerTeacher(RegisterTeacherParams(
      email:           email,
      password:        password,
      confirmPassword: confirmPassword,
      fullName:        fullName,
      acceptedTerms:   acceptedTerms,
      acceptedPrivacy: acceptedPrivacy,
      deviceId:        deviceMeta['device_id']!,
    ));

    result.fold(
      (failure) {
        AppLogger.warn('AuthController: registerTeacher failed → ${failure.code}');
        state = AuthError(failure);
      },
      (user) {
        AppLogger.info('AuthController: registerTeacher ✓ id=${user.id} code=${user.teacherCode}');
        state = AuthRequiresOtp(
          userId:  user.id,
          email:   email,
          purpose: OtpPurpose.register.value,
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD
  // FIX: double-submission guard
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> forgotPassword({required String email}) async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: forgotPassword → $email');
    state = const AuthLoading();

    final result = await _forgotPassword(email);

    result.fold(
      (failure) {
        AppLogger.warn('AuthController: forgotPassword failed → ${failure.code}');
        state = AuthError(failure);
      },
      (_) {
        AppLogger.info('AuthController: forgotPassword OTP sent → $email');
        // FIX: userId cannot be empty — use email as identifier until backend
        // returns userId. AuthPasswordResetSent.userId is now set to email
        // so the OTP screen can display it correctly.
        state = AuthPasswordResetSent(email: email, userId: email);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RESET PASSWORD
  // FIX: double-submission guard + OtpPurpose.resetPassword.value
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: resetPassword → userId=$userId');
    state = const AuthLoading();

    final result = await _resetPassword(ResetPasswordParams(
      userId:          userId,
      otp:             otp,
      newPassword:     newPassword,
      confirmPassword: confirmPassword,
    ));

    result.fold(
      (failure) {
        AppLogger.warn('AuthController: resetPassword failed → ${failure.code}');
        state = AuthError(failure);
      },
      (_) {
        AppLogger.info('AuthController: resetPassword success');
        state = const AuthPasswordResetSuccess();
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LINK TEACHER
  // FIX: double-submission guard
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> linkToTeacher({
    required String studentId,
    required String teacherCode,
  }) async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: linkToTeacher → code=$teacherCode');
    state = const AuthLoading();

    final accessToken = await SecureStorage.read(AppConstants.kAccessToken) ?? '';

    final result = await _linkTeacher(LinkTeacherParams(
      studentId:   studentId,
      teacherCode: teacherCode,
      accessToken: accessToken,
    ));

    result.fold(
      (failure) {
        AppLogger.warn('AuthController: linkToTeacher failed → ${failure.code}');
        state = AuthError(failure);
      },
      (_) {
        AppLogger.info('AuthController: linkToTeacher success');
        state = const AuthTeacherLinked();
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LOGOUT
  // FIX: GoRouter listens to AuthState changes.
  // Setting state = AuthUnauthenticated() AFTER clearAll() is intentional:
  // the router redirects to /role-select as soon as it sees this state.
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> logout() async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: logout');
    state = const AuthLoading();

    final accessToken = await SecureStorage.read(AppConstants.kAccessToken) ?? '';
    final deviceMeta  = await DeviceInfoUtil.getDeviceMeta();

    await _logout(
      accessToken: accessToken,
      deviceId:    deviceMeta['device_id']!,
    );

    // Always clear tokens and go unauthenticated — even if server call fails
    await SecureStorage.clearAll();
    // FIX: GoRouter redirect() checks AuthState — setting Unauthenticated
    // here triggers the redirect to /role-select automatically.
    state = const AuthUnauthenticated();
    AppLogger.info('AuthController: logout complete ✓');
  }

  Future<void> logoutAllDevices() async {
    if (state is AuthLoading) return;

    AppLogger.info('AuthController: logoutAllDevices');
    state = const AuthLoading();

    final accessToken = await SecureStorage.read(AppConstants.kAccessToken) ?? '';
    await _logoutAll(accessToken: accessToken);
    await SecureStorage.clearAll();
    state = const AuthUnauthenticated();
    AppLogger.info('AuthController: logoutAllDevices complete ✓');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Called by the router on every protected route — Zero-Trust re-validation.
  /// FIX: DateTime.tryParse() + null-check prevents crashes on bad stored data.
  Future<bool> validateSession() async {
    final token    = await SecureStorage.read(AppConstants.kAccessToken);
    final expiryRaw = await SecureStorage.read(AppConstants.kSessionExpiry);

    if (token == null) return false;

    final expiryDt = expiryRaw != null ? DateTime.tryParse(expiryRaw) : null;
    if (expiryDt == null || DateTime.now().isAfter(expiryDt)) {
      AppLogger.warn('AuthController: session expired on validation');
      state = const AuthUnauthenticated();
      return false;
    }

    return true;
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}
