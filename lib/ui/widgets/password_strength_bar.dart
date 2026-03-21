import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/core/utils/validators.dart';

/// Strength config tuple — using a class instead of Records
/// for Dart 3.1 compatibility (Records require Dart 3.0+).
class _StrengthConfig {
  final Color color;
  final String labelEn;
  final String labelAr;
  const _StrengthConfig(this.color, this.labelEn, this.labelAr);
}

class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final score = Validators.passwordStrength(password);
    if (password.isEmpty) return const SizedBox.shrink();

    // ── Config per strength level ─────────────────────────────────────────
    // Dart 3.1 compatible — no Records destructuring
    final configs = const <_StrengthConfig>[
      _StrengthConfig(AppTheme.error,   'Weak',   'ضعيفة'),
      _StrengthConfig(AppTheme.warning, 'Fair',   'مقبولة'),
      _StrengthConfig(AppTheme.warning, 'Good',   'جيدة'),
      _StrengthConfig(AppTheme.success, 'Strong', 'قوية'),
    ];

    final config  = configs[(score - 1).clamp(0, 3)];
    final color   = config.color;
    final labelEn = config.labelEn;
    final labelAr = config.labelAr;
    final isRtl   = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) {
            final filled = i < score;
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: filled ? color : AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate(target: filled ? 1 : 0).scaleX(duration: 200.ms),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          isRtl ? labelAr : labelEn,
          style: TextStyle(
            color:      color,
            fontSize:   12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
