// lib/features/auth/presentation/controllers/register_form_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edu_auth/core/utils/validators.dart';
import 'package:edu_auth/features/auth/presentation/controllers/auth_state.dart';

final registerFormControllerProvider =
    StateNotifierProvider.autoDispose<RegisterFormController, RegisterFormState>(
  (_) => RegisterFormController(),
);

class RegisterFormController extends StateNotifier<RegisterFormState> {
  RegisterFormController() : super(const RegisterFormState());

  void onPasswordChanged(String password) {
    final strength = Validators.passwordStrength(password);
    if (mounted) state = state.copyWith(passwordStrength: strength, clearFailure: true);
  }

  void toggleTerms(bool value) {
    if (mounted) state = state.copyWith(acceptedTerms: value, clearFailure: true);
  }

  void togglePrivacy(bool value) {
    if (mounted) state = state.copyWith(acceptedPrivacy: value, clearFailure: true);
  }

  void setLoading(bool v) { if (mounted) state = state.copyWith(isLoading: v); }

  void clearError() { if (mounted) state = state.copyWith(clearFailure: true); }
}
