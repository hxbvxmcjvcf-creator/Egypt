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
import 'package:edu_auth/ui/widgets/password_strength_bar.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';
import 'package:edu_auth/features/auth/presentation/controllers/locale_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/register_form_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _password   = ''; // FIX: tracked for PasswordStrengthBar rebuild

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isTeacher => widget.role == 'teacher';

  String _mapFailure(Failure f, AppLocalizations l) {
    if (f is EmailAlreadyExistsFailure) return l.errEmailExists;
    if (f is TermsNotAcceptedFailure)   return l.termsRequired;
    if (f is NetworkFailure)            return l.errNetwork;
    if (f is ValidationFailure)         return f.message;
    return l.errUnknown;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final form = ref.read(registerFormControllerProvider);
    if (!form.acceptedTerms || !form.acceptedPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(AppLocalizations.of(context).termsRequired),
        backgroundColor: AppTheme.error,
        behavior:        SnackBarBehavior.floating,
      ));
      return;
    }

    if (_isTeacher) {
      await ref.read(authControllerProvider.notifier).registerTeacher(
        email:           _emailCtrl.text.trim(),
        password:        _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
        fullName:        _nameCtrl.text.trim(),
        acceptedTerms:   form.acceptedTerms,
        acceptedPrivacy: form.acceptedPrivacy,
      );
    } else {
      await ref.read(authControllerProvider.notifier).registerStudent(
        email:           _emailCtrl.text.trim(),
        password:        _passCtrl.text,
        confirmPassword: _confirmCtrl.text,
        fullName:        _nameCtrl.text.trim(),
        acceptedTerms:   form.acceptedTerms,
        acceptedPrivacy: form.acceptedPrivacy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context);
    final locale   = ref.watch(localeControllerProvider);
    final isAr     = locale.languageCode == 'ar';
    final form     = ref.watch(registerFormControllerProvider);
    final gradient = _isTeacher ? AppTheme.teacherGradient : AppTheme.studentGradient;

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthRequiresOtp) {
        context.push(AppRoutes.otp, extra: {
          'userId': next.userId, 'email': next.email, 'purpose': next.purpose,
        });
      } else if (next is AuthEmailVerificationPending) {
        context.push(AppRoutes.emailVerify, extra: {
          'email': next.user.email, 'userId': next.user.id,
        });
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text(FailureMapper.toMessage(context, next.failure)),
          backgroundColor: AppTheme.error,
          behavior:        SnackBarBehavior.floating,
        ));
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(authControllerProvider) is AuthLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: (_isTeacher ? const Color(0xFF7B1FA2) : AppTheme.primary).withOpacity(0.4),
                      blurRadius: 24,
                    )],
                  ),
                  child: Icon(
                    _isTeacher ? Icons.cast_for_education_rounded : Icons.person_add_rounded,
                    color: Colors.white, size: 36,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(
                  _isTeacher ? (isAr ? 'تسجيل معلم' : 'Teacher Registration')
                             : (isAr ? 'تسجيل طالب'  : 'Student Registration'),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 28),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          label:      l.fullName,
                          hint:       l.enterName,
                          controller: _nameCtrl,
                          prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.onSurfaceSub),
                          validator:  Validators.fullName,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          label:        l.email,
                          hint:         l.enterEmail,
                          controller:   _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon:   const Icon(Icons.email_outlined, color: AppTheme.onSurfaceSub),
                          validator:    Validators.email,
                        ),
                        const SizedBox(height: 14),
                        AuthTextField(
                          label:      l.password,
                          hint:       l.enterPassword,
                          controller: _passCtrl,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.onSurfaceSub),
                          validator:  Validators.password,
                          // FIX: update both local state (for bar) and provider (for strength score)
                          onChanged: (v) {
                            setState(() => _password = v);
                            ref.read(registerFormControllerProvider.notifier).onPasswordChanged(v);
                          },
                        ),
                        // FIX: use _password local state so bar rebuilds on every keystroke
                        PasswordStrengthBar(password: _password),
                        const SizedBox(height: 14),
                        AuthTextField(
                          label:      l.confirmPassword,
                          hint:       l.enterConfirmPassword,
                          controller: _confirmCtrl,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppTheme.onSurfaceSub),
                          validator:  (v) => Validators.confirmPassword(v, _passCtrl.text),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 20),
                        _CheckRow(
                          value:     form.acceptedTerms,
                          label:     isAr ? 'أوافق على الشروط والأحكام' : 'I accept the Terms & Conditions',
                          onChanged: (v) => ref.read(registerFormControllerProvider.notifier).toggleTerms(v!),
                        ),
                        const SizedBox(height: 10),
                        _CheckRow(
                          value:     form.acceptedPrivacy,
                          label:     isAr ? 'أوافق على سياسة الخصوصية' : 'I accept the Privacy Policy',
                          onChanged: (v) => ref.read(registerFormControllerProvider.notifier).togglePrivacy(v!),
                        ),
                        const SizedBox(height: 24),
                        AuthButton(
                          label:     _isTeacher ? l.registerTeacher : l.registerStudent,
                          isLoading: isLoading,
                          gradient:  gradient,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.alreadyHaveAccount,
                      style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 14)),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(l.login,
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

class _CheckRow extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;
  const _CheckRow({required this.value, required this.label, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Checkbox(
        value:       value,
        onChanged:   onChanged,
        activeColor: AppTheme.primary,
        checkColor:  Colors.white,
        side:        const BorderSide(color: AppTheme.onSurfaceSub),
        shape:       RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      Expanded(child: Text(label, style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 13))),
    ],
  );
}
