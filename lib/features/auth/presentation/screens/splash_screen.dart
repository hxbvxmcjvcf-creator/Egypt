import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/utils/secure_storage.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/routing/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final token  = await SecureStorage.read(AppConstants.kAccessToken);
    final expiry = await SecureStorage.read(AppConstants.kSessionExpiry);
    bool valid   = false;
    if (token != null && expiry != null) {
      final exp = DateTime.tryParse(expiry);
      valid = exp != null && DateTime.now().isBefore(exp);
    }
    if (!mounted) return;
    context.go(valid ? AppRoutes.home : AppRoutes.roleSelect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 32)],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 52),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 28),
              const Text('EduPlatform',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 1),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 8),
              const Text('منصة التعليم المتقدمة',
                style: TextStyle(color: AppTheme.onSurfaceSub, fontSize: 16),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppTheme.primary),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
