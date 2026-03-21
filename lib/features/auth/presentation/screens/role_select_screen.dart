import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/ui/widgets/glass_card.dart';
import 'package:edu_auth/routing/app_router.dart';
import 'package:edu_auth/features/auth/presentation/controllers/locale_controller.dart';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale  = ref.watch(localeControllerProvider);
    final isAr    = locale.languageCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // ── Language Toggle ───────────────────────────────────────
                Align(
                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => ref.read(localeControllerProvider.notifier).toggle(),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      borderRadius: 12,
                      child: Text(isAr ? 'EN' : 'عربي',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const Spacer(),

                // ── Logo ──────────────────────────────────────────────────
                Container(
                  width: 88, height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 32)],
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 46),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),

                Text(
                  isAr ? 'مرحباً بك' : 'Welcome',
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  isAr ? 'اختر دورك للمتابعة' : 'Choose your role to continue',
                  style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 15),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 48),

                // ── Role Cards ────────────────────────────────────────────
                _RoleCard(
                  title:    isAr ? 'طالب'  : 'Student',
                  subtitle: isAr ? 'انضم إلى الفصول وتعلّم' : 'Join classes and learn',
                  icon:     Icons.person_rounded,
                  gradient: AppTheme.studentGradient,
                  delay:    400,
                  onTap:    () => context.push('${AppRoutes.login}?role=student'),
                ),
                const SizedBox(height: 16),
                _RoleCard(
                  title:    isAr ? 'معلم'  : 'Teacher',
                  subtitle: isAr ? 'أدِر فصولك وطلابك' : 'Manage your classes',
                  icon:     Icons.cast_for_education_rounded,
                  gradient: AppTheme.teacherGradient,
                  delay:    500,
                  onTap:    () => context.push('${AppRoutes.login}?role=teacher'),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final int delay;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title, required this.subtitle, required this.icon,
    required this.gradient, required this.delay, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.onSurfaceSub, size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.1, end: 0);
  }
}
