import 'package:flutter/material.dart';
import 'package:edu_auth/l10n/app_ar.dart';
import 'package:edu_auth/l10n/app_en.dart';

/// Dynamic string resolver — returns AR or EN strings based on current locale.
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isArabic => locale.languageCode == 'ar';

  // ── Proxy all strings ──────────────────────────────────────────────────
  String get appName          => isArabic ? AppStringsAr.appName          : AppStringsEn.appName;
  String get loading          => isArabic ? AppStringsAr.loading          : AppStringsEn.loading;
  String get retry            => isArabic ? AppStringsAr.retry            : AppStringsEn.retry;
  String get cancel           => isArabic ? AppStringsAr.cancel           : AppStringsEn.cancel;
  String get confirm          => isArabic ? AppStringsAr.confirm          : AppStringsEn.confirm;
  String get back             => isArabic ? AppStringsAr.back             : AppStringsEn.back;
  String get next             => isArabic ? AppStringsAr.next             : AppStringsEn.next;
  String get login            => isArabic ? AppStringsAr.login            : AppStringsEn.login;
  String get register         => isArabic ? AppStringsAr.register         : AppStringsEn.register;
  String get logout           => isArabic ? AppStringsAr.logout           : AppStringsEn.logout;
  String get logoutAll        => isArabic ? AppStringsAr.logoutAll        : AppStringsEn.logoutAll;
  String get forgotPassword   => isArabic ? AppStringsAr.forgotPassword   : AppStringsEn.forgotPassword;
  String get resetPassword    => isArabic ? AppStringsAr.resetPassword    : AppStringsEn.resetPassword;
  String get changeLanguage   => isArabic ? AppStringsAr.changeLanguage   : AppStringsEn.changeLanguage;
  String get chooseRole       => isArabic ? AppStringsAr.chooseRole       : AppStringsEn.chooseRole;
  String get student          => isArabic ? AppStringsAr.student          : AppStringsEn.student;
  String get teacher          => isArabic ? AppStringsAr.teacher          : AppStringsEn.teacher;
  String get studentDesc      => isArabic ? AppStringsAr.studentDesc      : AppStringsEn.studentDesc;
  String get teacherDesc      => isArabic ? AppStringsAr.teacherDesc      : AppStringsEn.teacherDesc;
  String get email            => isArabic ? AppStringsAr.email            : AppStringsEn.email;
  String get password         => isArabic ? AppStringsAr.password         : AppStringsEn.password;
  String get confirmPassword  => isArabic ? AppStringsAr.confirmPassword  : AppStringsEn.confirmPassword;
  String get fullName         => isArabic ? AppStringsAr.fullName         : AppStringsEn.fullName;
  String get teacherCode      => isArabic ? AppStringsAr.teacherCode      : AppStringsEn.teacherCode;
  String get enterEmail       => isArabic ? AppStringsAr.enterEmail       : AppStringsEn.enterEmail;
  String get enterPassword    => isArabic ? AppStringsAr.enterPassword    : AppStringsEn.enterPassword;
  String get enterName        => isArabic ? AppStringsAr.enterFullName    : AppStringsEn.enterFullName;
  String get enterConfirmPassword => isArabic ? AppStringsAr.enterConfirmPassword : AppStringsEn.enterConfirmPassword;
  String get enterTeacherCode => isArabic ? AppStringsAr.enterTeacherCode : AppStringsEn.enterTeacherCode;
  String get emailRequired    => isArabic ? AppStringsAr.emailRequired    : AppStringsEn.emailRequired;
  String get emailInvalid     => isArabic ? AppStringsAr.emailInvalid     : AppStringsEn.emailInvalid;
  String get passwordRequired => isArabic ? AppStringsAr.passwordRequired : AppStringsEn.passwordRequired;
  String get passwordTooShort => isArabic ? AppStringsAr.passwordTooShort : AppStringsEn.passwordTooShort;
  String get passwordNeedsUpper   => isArabic ? AppStringsAr.passwordNeedsUpper   : AppStringsEn.passwordNeedsUpper;
  String get passwordNeedsNumber  => isArabic ? AppStringsAr.passwordNeedsNumber  : AppStringsEn.passwordNeedsNumber;
  String get passwordNeedsSpecial => isArabic ? AppStringsAr.passwordNeedsSpecial : AppStringsEn.passwordNeedsSpecial;
  String get passwordsNotMatch    => isArabic ? AppStringsAr.passwordsNotMatch    : AppStringsEn.passwordsNotMatch;
  String get nameRequired     => isArabic ? AppStringsAr.nameRequired     : AppStringsEn.nameRequired;
  String get nameTooShort     => isArabic ? AppStringsAr.nameTooShort     : AppStringsEn.nameTooShort;
  String get teacherCodeRequired => isArabic ? AppStringsAr.teacherCodeRequired : AppStringsEn.teacherCodeRequired;
  String get teacherCodeInvalid  => isArabic ? AppStringsAr.teacherCodeInvalid  : AppStringsEn.teacherCodeInvalid;
  String get strengthWeak     => isArabic ? AppStringsAr.strengthWeak     : AppStringsEn.strengthWeak;
  String get strengthFair     => isArabic ? AppStringsAr.strengthFair     : AppStringsEn.strengthFair;
  String get strengthGood     => isArabic ? AppStringsAr.strengthGood     : AppStringsEn.strengthGood;
  String get strengthStrong   => isArabic ? AppStringsAr.strengthStrong   : AppStringsEn.strengthStrong;
  String get otpTitle         => isArabic ? AppStringsAr.otpTitle         : AppStringsEn.otpTitle;
  String get otpSubtitle      => isArabic ? AppStringsAr.otpSubtitle      : AppStringsEn.otpSubtitle;
  String get otpEnter         => isArabic ? AppStringsAr.otpEnter         : AppStringsEn.otpEnter;
  String get otpResend        => isArabic ? AppStringsAr.otpResend        : AppStringsEn.otpResend;
  String get otpResendIn      => isArabic ? AppStringsAr.otpResendIn      : AppStringsEn.otpResendIn;
  String get otpVerify        => isArabic ? AppStringsAr.otpVerify        : AppStringsEn.otpVerify;
  String get otpSent          => isArabic ? AppStringsAr.otpSent          : AppStringsEn.otpSent;
  String get linkTeacher      => isArabic ? AppStringsAr.linkTeacher      : AppStringsEn.linkTeacher;
  String get linkTeacherTitle    => isArabic ? AppStringsAr.linkTeacherTitle    : AppStringsEn.linkTeacherTitle;
  String get linkTeacherSubtitle => isArabic ? AppStringsAr.linkTeacherSubtitle : AppStringsEn.linkTeacherSubtitle;
  String get linkSuccess      => isArabic ? AppStringsAr.linkSuccess      : AppStringsEn.linkSuccess;
  String get forgotTitle      => isArabic ? AppStringsAr.forgotTitle      : AppStringsEn.forgotTitle;
  String get forgotSubtitle   => isArabic ? AppStringsAr.forgotSubtitle   : AppStringsEn.forgotSubtitle;
  String get sendResetLink    => isArabic ? AppStringsAr.sendResetLink    : AppStringsEn.sendResetLink;
  String get resetSent        => isArabic ? AppStringsAr.resetSent        : AppStringsEn.resetSent;
  String get resetSuccess     => isArabic ? AppStringsAr.resetSuccess     : AppStringsEn.resetSuccess;
  String get registerStudent  => isArabic ? AppStringsAr.registerStudent  : AppStringsEn.registerStudent;
  String get registerTeacher  => isArabic ? AppStringsAr.registerTeacher  : AppStringsEn.registerTeacher;
  String get alreadyHaveAccount => isArabic ? AppStringsAr.alreadyHaveAccount : AppStringsEn.alreadyHaveAccount;
  String get noAccount        => isArabic ? AppStringsAr.noAccount        : AppStringsEn.noAccount;
  String get createAccount    => isArabic ? AppStringsAr.createAccount    : AppStringsEn.createAccount;
  String get registerSuccess  => isArabic ? AppStringsAr.registerSuccess  : AppStringsEn.registerSuccess;
  String get verifyEmailNotice => isArabic ? AppStringsAr.verifyEmailNotice : AppStringsEn.verifyEmailNotice;
  String get errInvalidCredentials => isArabic ? AppStringsAr.errInvalidCredentials : AppStringsEn.errInvalidCredentials;
  String get errAccountNotFound    => isArabic ? AppStringsAr.errAccountNotFound    : AppStringsEn.errAccountNotFound;
  String get errAccountSuspended   => isArabic ? AppStringsAr.errAccountSuspended   : AppStringsEn.errAccountSuspended;
  String get errEmailNotVerified   => isArabic ? AppStringsAr.errEmailNotVerified   : AppStringsEn.errEmailNotVerified;
  String get errEmailExists        => isArabic ? AppStringsAr.errEmailExists        : AppStringsEn.errEmailExists;
  String get errNetwork            => isArabic ? AppStringsAr.errNetwork            : AppStringsEn.errNetwork;
  String get errServer             => isArabic ? AppStringsAr.errServer             : AppStringsEn.errServer;
  String get errTimeout            => isArabic ? AppStringsAr.errTimeout            : AppStringsEn.errTimeout;
  String get errTooManyAttempts    => isArabic ? AppStringsAr.errTooManyAttempts    : AppStringsEn.errTooManyAttempts;
  String get errTeacherCode        => isArabic ? AppStringsAr.errTeacherCode        : AppStringsEn.errTeacherCode;
  String get errSessionExpired     => isArabic ? AppStringsAr.errSessionExpired     : AppStringsEn.errSessionExpired;
  String get errUnknown            => isArabic ? AppStringsAr.errUnknown            : AppStringsEn.errUnknown;
  String get errDeviceNew          => isArabic ? AppStringsAr.errDeviceNew          : AppStringsEn.errDeviceNew;
  String get errMaxDevices         => isArabic ? AppStringsAr.errMaxDevices         : AppStringsEn.errMaxDevices;
  String get acceptTerms      => isArabic ? AppStringsAr.acceptTerms      : AppStringsEn.acceptTerms;
  String get acceptPrivacy    => isArabic ? AppStringsAr.acceptPrivacy    : AppStringsEn.acceptPrivacy;
  String get termsRequired    => isArabic ? AppStringsAr.termsRequired    : AppStringsEn.termsRequired;
  String get sessionExpiredTitle => isArabic ? AppStringsAr.sessionExpiredTitle : AppStringsEn.sessionExpiredTitle;
  String get sessionExpiredMsg   => isArabic ? AppStringsAr.sessionExpiredMsg   : AppStringsEn.sessionExpiredMsg;
  String get emailVerificationTitle => isArabic ? AppStringsAr.emailVerificationTitle : AppStringsEn.emailVerificationTitle;
  String get emailVerificationMsg   => isArabic ? AppStringsAr.emailVerificationMsg   : AppStringsEn.emailVerificationMsg;
  String get resendVerification     => isArabic ? AppStringsAr.resendVerification     : AppStringsEn.resendVerification;
  String get emailVerified          => isArabic ? AppStringsAr.emailVerified          : AppStringsEn.emailVerified;
  String get newPassword      => isArabic ? AppStringsAr.newPassword      : AppStringsEn.newPassword;
}

/// Flutter delegate for AppLocalizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
