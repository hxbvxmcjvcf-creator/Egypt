import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/core/utils/failure_mapper.dart';
import 'package:edu_auth/l10n/app_localizations.dart';
import 'package:edu_auth/routing/app_router.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/ui/widgets/auth_button.dart';
import 'package:edu_auth/ui/widgets/auth_text_field.dart';
import 'package:edu_auth/ui/widgets/glass_card.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_controller.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';

class LinkTeacherScreen extends ConsumerStatefulWidget {
  final String studentId;
  const LinkTeacherScreen({super.key, required this.studentId});
  @override
  ConsumerState<LinkTeacherScreen> createState() => _LinkTeacherScreenState();
}

class _LinkTeacherScreenState extends ConsumerState<LinkTeacherScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() { _codeCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).linkToTeacher(
      studentId:   widget.studentId,
      teacherCode: _codeCtrl.text.trim().toUpperCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next is AuthTeacherLinked) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.linkSuccess), backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.go(AppRoutes.home);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.errTeacherCode), backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ));
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(authControllerProvider) is AuthLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.studentGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 28)],
                  ),
                  child: const Icon(Icons.link_rounded, color: Colors.white, size: 40),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(l.linkTeacherTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text(l.linkTeacherSubtitle,
                  style: const TextStyle(color: AppTheme.onSurfaceSub, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 36),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AuthTextField(
                          label:      l.teacherCode,
                          hint:       l.enterTeacherCode,
                          controller: _codeCtrl,
                          prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.onSurfaceSub),
                          validator:  Validators.teacherCode,
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 24),
                        AuthButton(
                          label: l.linkTeacher, isLoading: isLoading, onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
