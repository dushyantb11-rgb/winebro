import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/utils/validators.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/shared/widgets/gradient_scaffold.dart';
import 'package:winebro/shared/widgets/loading_button.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _ageConfirmed = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_ageConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.ageGateRequired)),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authStateProvider.notifier).saveProfile(
      displayName: _nameController.text.trim(),
      isAgeVerified: _ageConfirmed,
    );

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _openLegal(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: colors.error),
        );
      }
    });

    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Text(
                l10n.whatShouldWeCallYou,
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
                l10n.firstNameNeeded,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: l10n.yourNameHint,
                ),
                validator: Validators.displayName,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 28),
              _AgeGateRow(
                value: _ageConfirmed,
                colors: colors,
                onChanged: (v) =>
                    setState(() => _ageConfirmed = v ?? false),
                onTapPrivacy: () => _openLegal(
                  Uri.parse('https://winebro.web.app/privacy-policy.html'),
                ),
                onTapTerms: () => _openLegal(
                  Uri.parse('https://winebro.web.app/terms.html'),
                ),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                onPressed: _submit,
                label: l10n.continueButton,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgeGateRow extends StatelessWidget {
  const _AgeGateRow({
    required this.value,
    required this.colors,
    required this.onChanged,
    required this.onTapPrivacy,
    required this.onTapTerms,
  });

  final bool value;
  final AppColors colors;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTapPrivacy;
  final VoidCallback onTapTerms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final linkStyle = TextStyle(
      color: colors.paprika,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: colors.paprika,
          checkColor: colors.inkOnHero,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
                children: [
                  TextSpan(text: l10n.ageGateLeading),
                  TextSpan(
                    text: l10n.ageGatePrivacy,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()..onTap = onTapPrivacy,
                  ),
                  TextSpan(text: l10n.ageGateAnd),
                  TextSpan(
                    text: l10n.ageGateTerms,
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()..onTap = onTapTerms,
                  ),
                  TextSpan(text: l10n.ageGateTrailing),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

