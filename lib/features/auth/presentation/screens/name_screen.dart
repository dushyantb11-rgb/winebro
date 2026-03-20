import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await ref.read(authStateProvider.notifier).saveProfile(
      displayName: _nameController.text.trim(),
      isAgeVerified: true,
    );

    if (mounted) setState(() => _isLoading = false);
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
              const SizedBox(height: 32),
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

