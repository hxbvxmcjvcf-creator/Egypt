import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding        = const EdgeInsets.all(24),
    this.borderRadius   = 24,
    this.blurSigma      = 20,
    this.opacity        = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width:   width,
          height:  height,
          padding: padding,
          decoration: AppTheme.glassCard(radius: borderRadius, opacity: opacity),
          child: child,
        ),
      ),
    );
  }
}
