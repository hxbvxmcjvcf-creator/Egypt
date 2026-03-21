import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:edu_auth/l10n/app_localizations.dart';
import 'package:edu_auth/core/utils/failure_mapper.dart';
import 'package:edu_auth/routing/app_router.dart';
import 'package:edu_auth/ui/theme/app_theme.dart';
import 'package:edu_auth/ui/widgets/auth_button.dart';
import 'package:edu_auth/ui/widgets/glass_card.dart';
import 'package:edu_auth/features/auth/presentation/controllers/otp_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String userId, email, purpose;
  const OtpScreen({
    super.key,
    required this.userId,
    required this.email,
    required this.purpose,
  });
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  // FIX: otp must live in state, not in build() local var
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final l  = AppLocalizations.of(context);
    final st = ref.watch(otpControllerProvider);

    ref.listen(otpControllerProvider, (_, next) {
      if (next.isVerified) {
        context.go(AppRoutes.home);
      }
      if (next.failure != null && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text(FailureMapper.toMessage(context, next.failure!)),
          backgroundColor: AppTheme.error,
          behavior:        SnackBarBehavior.floating,
        ));
        ref.read(otpControllerProvider.notifier).clearError();
      }
    });

    final pinTheme = PinTheme(
      width: 52, height: 60,
      textStyle: const TextStyle(
        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
      decoration: BoxDecoration(
        color: AppTheme.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
    );

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 28,
                      )
                    ],
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 40),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(l.otpTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 8),
                Text('${l.otpSubtitle} ${widget.email}',
                  style: const TextStyle(
                      color: AppTheme.onSurfaceSub, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 40),
                GlassCard(
                  child: Column(
                    children: [
                      Pinput(
                        length: 6,
                        defaultPinTheme: pinTheme,
                        focusedPinTheme: pinTheme.copyWith(
                          decoration: pinTheme.decoration!.copyWith(
                            border: Border.all(color: AppTheme.primary, width: 2),
                          ),
                        ),
                        errorPinTheme: pinTheme.copyWith(
                          decoration: pinTheme.decoration!.copyWith(
                            border: Border.all(color: AppTheme.error, width: 2),
                          ),
                        ),
                        // FIX: update _otp state on every change
                        onChanged:   (v) => setState(() => _otp = v),
                        onCompleted: (v) => setState(() => _otp = v),
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                      const SizedBox(height: 28),
                      AuthButton(
                        label:     l.otpVerify,
                        isLoading: st.isLoading,
                        onPressed: () => ref
                            .read(otpControllerProvider.notifier)
                            .verify(
                              userId:  widget.userId,
                              otp:     _otp,
                              purpose: widget.purpose,
                            ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: st.canResend
                          ? TextButton(
                              onPressed: () => ref
                                  .read(otpControllerProvider.notifier)
                                  .resend(
                                    userId:  widget.userId,
                                    purpose: widget.purpose,
                                  ),
                              child: Text(l.otpResend,
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w700)),
                            )
                          : Text(
                              '${l.otpResendIn} ${st.resendCooldownSec}s',
                              style: const TextStyle(
                                  color: AppTheme.onSurfaceSub, fontSize: 13),
                            ),
                      ),
                    ],
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
