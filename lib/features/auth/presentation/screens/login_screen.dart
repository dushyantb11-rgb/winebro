import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/providers/locale_provider.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/utils/validators.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/shared/widgets/gradient_scaffold.dart';
import 'package:winebro/shared/widgets/loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isAgeVerified = false;
  bool _hasValidPhone = false;
  bool _otpTriggered = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final valid = Validators.phoneNumber(_phoneController.text) == null;
    if (valid != _hasValidPhone) {
      setState(() => _hasValidPhone = valid);
    }
    _tryAutoSubmit();
  }

  void _tryAutoSubmit() {
    if (_hasValidPhone && _isAgeVerified && !_otpTriggered) {
      _otpTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _submitPhone());
    }
  }

  void _onAgeChanged(bool? value) {
    setState(() => _isAgeVerified = value ?? false);
    _otpTriggered = false;
    _tryAutoSubmit();
  }

  bool get _canSubmit => _hasValidPhone && _isAgeVerified;

  Future<void> _submitPhone() async {
    if (!_canSubmit) return;
    final phone = Validators.normalizePhone(_phoneController.text);
    await ref.read(authStateProvider.notifier).sendOtp(phone);
  }

  Future<void> _signInWithGoogle() async {
    if (!_isAgeVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ageVerificationRequired)),
      );
      return;
    }

    await ref.read(authStateProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next is AuthError) {
        _otpTriggered = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: colors.error,
          ),
        );
      }
    });

    return GradientScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: PopupMenuButton<Locale>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language, size: 18, color: colors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        kLocaleNames[ref.watch(localeProvider)?.languageCode ?? 'en'] ?? 'English',
                        style: TextStyle(fontSize: 12, color: colors.textTertiary),
                      ),
                    ],
                  ),
                  onSelected: (locale) =>
                      ref.read(localeProvider.notifier).setLocale(locale),
                  itemBuilder: (_) => kSupportedLocales.map((locale) {
                    final name = kLocaleNames[locale.languageCode] ?? locale.languageCode;
                    final current = ref.read(localeProvider);
                    return PopupMenuItem(
                      value: locale,
                      child: Row(
                        children: [
                          Text(name),
                          if (current?.languageCode == locale.languageCode) ...[
                            const Spacer(),
                            Icon(Icons.check, size: 16, color: colors.paprika),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 220,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.enterPhoneNumber,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.findPerfectPairing,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: '98765 43210',
                  prefixText: '+91  ',
                  prefixStyle: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _isAgeVerified,
                    onChanged: _onAgeChanged,
                    activeColor: colors.paprika,
                    side: BorderSide(color: colors.borderStrong),
                  ),
                  Expanded(
                    child: Text(
                      l10n.ageConfirmation,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              LoadingButton(
                onPressed: _canSubmit ? _submitPhone : null,
                label: l10n.sendOtp,
                isLoading: isLoading,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Divider(color: colors.borderDefault)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.orContinueWith,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.borderDefault)),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  icon: SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(painter: _GoogleLogoPainter()),
                  ),
                  label: Text(
                    l10n.signInWithGoogle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w * 0.45;

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);

    final path = Path()
      ..moveTo(cx + r, cy)
      ..arcToPoint(Offset(cx, cy - r), radius: Radius.circular(r))
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(path, bluePaint);

    final path2 = Path()
      ..moveTo(cx, cy - r)
      ..arcToPoint(Offset(cx - r, cy), radius: Radius.circular(r))
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(path2, redPaint);

    final path3 = Path()
      ..moveTo(cx - r, cy)
      ..arcToPoint(Offset(cx, cy + r), radius: Radius.circular(r))
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(path3, yellowPaint);

    final path4 = Path()
      ..moveTo(cx, cy + r)
      ..arcToPoint(Offset(cx + r, cy), radius: Radius.circular(r))
      ..lineTo(cx, cy)
      ..close();
    canvas.drawPath(path4, greenPaint);

    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.55,
      Paint()..color = Colors.white,
    );

    final barRect = RRect.fromLTRBR(
      cx - r * 0.1, cy - r * 0.25,
      cx + r, cy + r * 0.25,
      const Radius.circular(2),
    );
    canvas.drawRRect(barRect, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

