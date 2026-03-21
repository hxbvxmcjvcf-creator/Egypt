import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_auth/l10n/app_localizations.dart';
import 'package:edu_auth/core/utils/failure_mapper.dart';
import 'package:edu_auth/routing/app_router.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/ui/widgets/auth_button.dart';
import 'package:edu_auth/ui/widgets/glass_card.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';

class EmailVerifyScreen extends ConsumerWidget {
  final String email, userId;
  const EmailVerifyScreen({super.key, required this.email, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FailureMapper.toMessage(context, next.failure)), backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 32)],
                  ),
                  child: const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 52),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 32),
                Text(l.emailVerificationTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                Text('${l.emailVerificationMsg}\n$email',
                  style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 15, height: 1.6),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 48),
                GlassCard(
                  child: Column(
                    children: [
                      AuthButton(
                        label: l.resendVerification,
                        icon:  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.roleSelect),
                        child: Text(l.login,
                          style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 14)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
