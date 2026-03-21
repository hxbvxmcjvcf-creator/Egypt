// lib/features/auth/presentation/controllers/locale_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_auth/core/constants/app_constants.dart';
import 'package:edu_auth/core/logging/app_logger.dart';

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code  = prefs.getString(AppConstants.kLanguage) ?? AppConstants.defaultLocale;
      if (mounted) state = Locale(code);
      AppLogger.debug('LocaleController: loaded locale → $code');
    } catch (e) {
      AppLogger.warn('LocaleController: failed to load locale, using default');
      if (mounted) state = const Locale('ar');
    }
  }

  Future<void> switchToArabic()  => _setLocale('ar');
  Future<void> switchToEnglish() => _setLocale('en');

  Future<void> toggle() async {
    if (state.languageCode == 'ar') {
      await switchToEnglish();
    } else {
      await switchToArabic();
    }
  }

  Future<void> _setLocale(String code) async {
    if (mounted) state = Locale(code);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.kLanguage, code);
      AppLogger.info('LocaleController: locale → $code');
    } catch (e) {
      AppLogger.warn('LocaleController: failed to persist locale', error: e);
    }
  }

  bool get isArabic  => state.languageCode == 'ar';
  bool get isEnglish => state.languageCode == 'en';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;
}
