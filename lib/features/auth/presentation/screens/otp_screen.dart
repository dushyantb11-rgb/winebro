import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/utils/validators.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/shared/widgets/gradient_scaffold.dart';
import 'package:winebro/shared/widgets/loading_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 0) {
        timer.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_otpValue.length == 6) {
      _submit();
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _submit() async {
    final otp = _otpValue;
    final error = Validators.otp(otp);
    if (error != null) return;

    final authState = ref.read(authStateProvider);
    if (authState is! OtpSent) return;

    await ref.read(authStateProvider.notifier).verifyOtp(
      verificationId: authState.verificationId,
      otp: otp,
    );
  }

  Future<void> _resend() async {
    final authState = ref.read(authStateProvider);
    if (authState is! OtpSent) return;

    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    await ref.read(authStateProvider.notifier).sendOtp(authState.phoneNumber);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;
    final phone = authState is OtpSent ? authState.phoneNumber : '';

    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            Text(
              l10n.verifyOtpTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.otpSentTo(phone),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Container(
                  width: 44,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _controllers[i].text.isNotEmpty
                              ? colors.salemLight
                              : colors.borderDefault,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors.paprika,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: colors.surface2,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (v) {
                      if (v.isEmpty) {
                        _onBackspace(i);
                      } else {
                        _onDigitChanged(i, v);
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            LoadingButton(
              onPressed: _submit,
              label: l10n.verify,
              isLoading: isLoading,
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: _resendCountdown <= 0 && !isLoading ? _resend : null,
              child: Text(
                _resendCountdown > 0
                    ? l10n.resendIn(_resendCountdown)
                    : l10n.resendOtp,
                style: TextStyle(
                  color: _resendCountdown > 0
                      ? colors.textTertiary
                      : colors.paprikaLight,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                ref.read(authStateProvider.notifier).signOut();
              },
              child: Text(
                l10n.changeNumber,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

