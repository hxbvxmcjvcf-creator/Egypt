import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_auth/core/errors/failures.dart';
import 'package:edu_auth/core/utils/failure_mapper.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/l10n/app_localizations.dart';
import 'package:edu_auth/routing/app_router.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/ui/widgets/auth_button.dart';
import 'package:edu_auth/ui/widgets/auth_text_field.dart';
import 'package:edu_auth/ui/widgets/glass_card.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';
import 'package:edu_auth/features/auth/presentation/controllers/locale_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _isTeacher => widget.role == 'teacher';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
      email:    _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
  }

  String _mapFailure(Failure f, AppLocalizations l) {
    if (f is InvalidCredentialsFailure) return l.errInvalidCredentials;
    if (f is AccountSuspendedFailure)   return l.errAccountSuspended;
    if (f is AccountNotFoundFailure)    return l.errAccountNotFound;
    if (f is EmailNotVerifiedFailure)   return l.errEmailNotVerified;
    if (f is RateLimitFailure)          return l.errTooManyAttempts;
    if (f is NetworkFailure)            return l.errNetwork;
    if (f is TimeoutFailure)            return l.errTimeout;
    return l.errUnknown;
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);
    final isAr   = locale.languageCode == 'ar';

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthRequiresOtp) {
        context.push(AppRoutes.otp, extra: {
          'userId':  next.userId,
          'email':   next.email,
          'purpose': next.purpose,
        });
      } else if (next is AuthAuthenticated) {
        context.go(AppRoutes.home);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:          Text(FailureMapper.toMessage(context, next.failure)),
          backgroundColor:  AppTheme.error,
          behavior:         SnackBarBehavior.floating,
        ));
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    final gradient = _isTeacher ? AppTheme.teacherGradient : AppTheme.studentGradient;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Header ────────────────────────────────────────────────
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => ref.read(localeControllerProvider.notifier).toggle(),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        borderRadius: 10,
                        child: Text(isAr ? 'EN' : 'عربي',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Icon ──────────────────────────────────────────────────
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(
                      color: (_isTeacher ? const Color(0xFF7B1FA2) : AppTheme.primary).withOpacity(0.4),
                      blurRadius: 28,
                    )],
                  ),
                  child: Icon(
                    _isTeacher ? Icons.cast_for_education_rounded : Icons.person_rounded,
                    color: Colors.white, size: 40,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                const SizedBox(height: 20),

                Text(
                  l.login,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 6),
                Text(
                  isAr
                    ? (_isTeacher ? 'تسجيل دخول المعلم' : 'تسجيل دخول الطالب')
                    : (_isTeacher ? 'Teacher Sign In'    : 'Student Sign In'),
                  style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 14),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 36),

                // ── Form ──────────────────────────────────────────────────
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          label:       l.email,
                          hint:        l.enterEmail,
                          controller:  _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon:  const Icon(Icons.email_outlined, color: AppTheme.onSurfaceSub),
                          validator:   Validators.email,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label:      l.password,
                          hint:       l.enterPassword,
                          controller: _passCtrl,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.onSurfaceSub),
                          validator:  (v) => v == null || v.isEmpty ? l.passwordRequired : null,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push(AppRoutes.forgotPw),
                            child: Text(l.forgotPassword,
                              style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthButton(
                          label:     l.login,
                          isLoading: isLoading,
                          gradient:  gradient,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Register link ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.noAccount,
                      style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 14)),
                    TextButton(
                      onPressed: () => context.push('${AppRoutes.register}?role=${widget.role}'),
                      child: Text(l.createAccount,
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
