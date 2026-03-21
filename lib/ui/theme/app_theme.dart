import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1A73E8);
  static const Color primaryDark  = Color(0xFF0D47A1);
  static const Color secondary    = Color(0xFF00BCD4);
  static const Color accent       = Color(0xFF00E5FF);
  static const Color success      = Color(0xFF4CAF50);
  static const Color warning      = Color(0xFFFFC107);
  static const Color error        = Color(0xFFE53935);
  static const Color surface      = Color(0xFF0A0E21);
  static const Color surfaceCard  = Color(0xFF1D2135);
  static const Color onSurface    = Color(0xFFFFFFFF);
  static const Color onSurfaceSub = Color(0xFF8F9BB3);
  static const Color divider      = Color(0xFF2A2D3E);
  static const Color inputFill    = Color(0xFF151929);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E21), Color(0xFF111530), Color(0xFF0D1B3E)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF00BCD4)],
  );

  static const LinearGradient studentGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF0288D1)],
  );

  static const LinearGradient teacherGradient = LinearGradient(
    colors: [Color(0xFF7B1FA2), Color(0xFFAD1457)],
  );

  // ── Glass decoration ──────────────────────────────────────────────────────
  static BoxDecoration glassCard({double radius = 20, double opacity = 0.08}) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: Colors.white.withOpacity(opacity),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary:   primary,
        secondary: secondary,
        surface:   surfaceCard,
        error:     error,
      ),
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme).apply(
        bodyColor:    onSurface,
        displayColor: onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:          true,
        fillColor:       inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:   const BorderSide(color: error, width: 2),
        ),
        labelStyle: const TextStyle(color: onSurfaceSub),
        hintStyle:  const TextStyle(color: onSurfaceSub),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  primary,
          foregroundColor:  Colors.white,
          minimumSize:      const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      dividerColor: divider,
    );
  }
}
