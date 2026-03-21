// lib/routing/app_router.dart
// FIX: GoRouter uses refreshListenable to watch authControllerProvider.
// When state → AuthUnauthenticated, the router re-evaluates redirect()
// and pushes to /role-select automatically — no manual context.push() needed.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/utils/secure_storage.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';
import 'package:edu_auth/features/auth/presentation/screens/splash_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/role_select_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/login_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/register_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/otp_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/link_teacher_screen.dart';
import 'package:edu_auth/features/auth/presentation/screens/email_verify_screen.dart';

class AppRoutes {
  static const splash      = '/';
  static const roleSelect  = '/role-select';
  static const login       = '/login';
  static const register    = '/register';
  static const otp         = '/otp';
  static const forgotPw    = '/forgot-password';
  static const resetPw     = '/reset-password';
  static const linkTeacher = '/link-teacher';
  static const emailVerify = '/email-verify';
  static const home        = '/home';
}

// ── FIX: Listenable wrapper so GoRouter refreshes on AuthState changes ────────
// When AuthController emits AuthUnauthenticated, GoRouter re-runs redirect()
// and immediately sends the user to /role-select.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }
  final Ref _ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthStateListenable(ref);

  return GoRouter(
    initialLocation:    AppRoutes.splash,
    debugLogDiagnostics: false,
    // FIX: refreshListenable triggers re-evaluation of redirect() on every
    // AuthState change — this is how logout navigates without BuildContext.
    refreshListenable: listenable,
    redirect: (context, state) async {
      final path        = state.matchedLocation;
      final isAuthRoute = _authRoutes.contains(path);

      // ── Zero-Trust: re-validate token on every navigation ──────────────
      final token     = await SecureStorage.read(AppConstants.kAccessToken);
      final expiryRaw = await SecureStorage.read(AppConstants.kSessionExpiry);

      bool sessionValid = false;
      if (token != null && expiryRaw != null) {
        // FIX: safe parse with tryParse + null-check
        final exp = DateTime.tryParse(expiryRaw);
        sessionValid = exp != null && DateTime.now().isBefore(exp);
      }

      // Splash always passes through
      if (path == AppRoutes.splash) return null;

      // Unauthenticated → send to role select
      if (!isAuthRoute && !sessionValid) return AppRoutes.roleSelect;

      // Already authenticated → redirect away from auth screens
      if (isAuthRoute &&
          path != AppRoutes.otp &&
          path != AppRoutes.emailVerify &&
          sessionValid) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash,     builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.roleSelect, builder: (_, __) => const RoleSelectScreen()),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return LoginScreen(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return OtpScreen(
            userId:  extra['userId']  ?? '',
            email:   extra['email']   ?? '',
            purpose: extra['purpose'] ?? OtpPurpose.login.value,
          );
        },
      ),
      GoRoute(path: AppRoutes.forgotPw, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: AppRoutes.resetPw,
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return OtpScreen(
            userId:  extra['userId'] ?? '',
            email:   extra['email']  ?? '',
            purpose: OtpPurpose.resetPassword.value,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.linkTeacher,
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return LinkTeacherScreen(studentId: extra['studentId'] ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.emailVerify,
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return EmailVerifyScreen(
            email:  extra['email']  ?? '',
            userId: extra['userId'] ?? '',
          );
        },
      ),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const _HomeStub()),
    ],
  );
});

const _authRoutes = {
  AppRoutes.roleSelect,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPw,
  AppRoutes.resetPw,
  AppRoutes.otp,
  AppRoutes.emailVerify,
};

class _HomeStub extends ConsumerWidget {
  const _HomeStub();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 72),
            const SizedBox(height: 16),
            const Text('تم تسجيل الدخول بنجاح',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('تسجيل الخروج / Logout',
                  style: TextStyle(color: Color(0xFF1A73E8))),
            ),
          ],
        ),
      ),
    );
  }
}
