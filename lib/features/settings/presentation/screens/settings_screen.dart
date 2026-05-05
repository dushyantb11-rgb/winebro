import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/providers/locale_provider.dart';
import 'package:winebro/core/providers/theme_provider.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/friends/data/friend_repository.dart';
import 'package:winebro/features/friends/domain/friend.dart';

/// Settings screen — extracted from the AppBar of Profile.
///
/// One scrollable column of grouped sections:
///   Appearance         theme toggle, language picker
///   Account            sign out, delete account
///   About              privacy policy, terms, version
///
/// No nav tab — pushed from a "Settings" row at the bottom of Profile.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileTitle == 'Profile'
            ? 'Settings'
            : 'Settings'), // intentionally hardcoded — "Settings" is universal app term
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(label: context.l10n.settingsAppearance, colors: colors),
          _SettingsTile(
            icon: themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
            title: context.l10n.settingsTheme,
            trailing: _ThemeSwitch(
              value: themeMode == ThemeMode.dark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              colors: colors,
            ),
            colors: colors,
          ),
          _SettingsTile(
            icon: Icons.language,
            title: context.l10n.settingsLanguageRow,
            subtitle: kLocaleNames[locale?.languageCode ?? 'en'] ?? 'English',
            onTap: () => _showLanguageSheet(context, ref),
            colors: colors,
          ),
          const SizedBox(height: 24),

          _SectionHeader(label: context.l10n.settingsPrivacy, colors: colors),
          _PrivacyVisibilityTile(colors: colors),
          const SizedBox(height: 24),

          _SectionHeader(label: context.l10n.settingsAccount, colors: colors),
          _SettingsTile(
            icon: Icons.logout,
            title: context.l10n.settingsSignOut,
            colors: colors,
            onTap: () async {
              final confirmed = await _confirm(
                context,
                context.l10n.settingsSignOutQuestion,
                context.l10n.settingsSignOutConfirm,
                context.l10n.settingsSignOut,
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                await ref.read(authStateProvider.notifier).signOut();
              }
            },
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: context.l10n.settingsDelete,
            isDestructive: true,
            colors: colors,
            onTap: () async {
              final confirmed = await _confirm(
                context,
                context.l10n.settingsDeleteQuestion,
                context.l10n.settingsDeleteConfirm,
                context.l10n.settingsDeleteForever,
                isDestructive: true,
              );
              if (confirmed == true && context.mounted) {
                // TODO: wire to account deletion endpoint when ready
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.settingsDeleteComingSoon),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          _SectionHeader(label: context.l10n.settingsAbout, colors: colors),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: context.l10n.settingsPrivacyPolicy,
            colors: colors,
            onTap: () =>
                _open(Uri.parse('https://winebro.web.app/privacy-policy.html')),
          ),
          _SettingsTile(
            icon: Icons.gavel_outlined,
            title: context.l10n.settingsTerms,
            colors: colors,
            onTap: () => _open(Uri.parse('https://winebro.web.app/terms.html')),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: context.l10n.settingsVersion,
            subtitle: '0.1.0',
            colors: colors,
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              context.l10n.settingsResponsibly,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontStyle: FontStyle.italic,
                color: colors.textTertiary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _open(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final current = ref.read(localeProvider);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                context.l10n.settingsChooseLanguage,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            ...kSupportedLocales.map((locale) {
              final selected = current?.languageCode == locale.languageCode;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? colors.paprika : colors.textTertiary,
                ),
                title: Text(
                  kLocaleNames[locale.languageCode] ?? locale.languageCode,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirm(
    BuildContext context,
    String title,
    String message,
    String confirmLabel, {
    bool isDestructive = false,
  }) async {
    final colors = context.appColors;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? colors.error : colors.paprika,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.colors});
  final String label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: colors.textTertiary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.colors,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final AppColors colors;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? colors.error : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null && !isDestructive)
              Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwitch extends StatelessWidget {
  const _ThemeSwitch({
    required this.value,
    required this.onChanged,
    required this.colors,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.gentle,
      curve: AppMotion.standard,
      width: 56,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value ? colors.paprika : colors.surface3,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: AppMotion.gentle,
              curve: AppMotion.spring,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.dark_mode : Icons.light_mode,
                  size: 16,
                  color: value ? colors.paprika : colors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyVisibilityTile extends ConsumerWidget {
  const _PrivacyVisibilityTile({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibility =
        ref.watch(profileVisibilityProvider).value ?? ProfileVisibility.friendsOnly;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.settingsVisibilityTitle,
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ProfileVisibility.values.map((v) {
              final active = v == visibility;
              return ChoiceChip(
                label: Text(_label(context, v)),
                selected: active,
                onSelected: (_) => ref
                    .read(friendRepositoryProvider)
                    .setVisibility(v),
                selectedColor: colors.paprika,
                labelStyle: TextStyle(
                  color: active ? colors.inkOnHero : colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                backgroundColor: colors.surface1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: active ? colors.paprika : colors.borderSubtle,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            _hint(context, visibility),
            style: TextStyle(color: colors.textTertiary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _label(BuildContext context, ProfileVisibility v) {
    final l10n = context.l10n;
    return switch (v) {
      ProfileVisibility.public => l10n.settingsVisibilityPublic,
      ProfileVisibility.friendsOnly => l10n.settingsVisibilityFriends,
      ProfileVisibility.private => l10n.settingsVisibilityPrivate,
    };
  }

  String _hint(BuildContext context, ProfileVisibility v) {
    final l10n = context.l10n;
    return switch (v) {
      ProfileVisibility.public => l10n.settingsVisibilityPublicHint,
      ProfileVisibility.friendsOnly => l10n.settingsVisibilityFriendsHint,
      ProfileVisibility.private => l10n.settingsVisibilityPrivateHint,
    };
  }
}
