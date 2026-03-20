import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/providers/locale_provider.dart';
import 'package:winebro/core/providers/theme_provider.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_icons.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:winebro/features/profile/domain/gamification.dart';
import 'package:winebro/shared/widgets/palate_radar_chart.dart';

final gamificationProvider = StreamProvider<GamificationState>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('gamification')
      .doc('state')
      .snapshots()
      .map((doc) {
    if (!doc.exists) return GamificationState.initial();
    return GamificationState.fromMap(doc.data()!);
  });
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final palate = ref.watch(userPalateProvider);
    final gamification = ref.watch(gamificationProvider);

    final userName = switch (authState) {
      Authenticated(:final user) => user.displayName,
      _ => 'Bro',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(themeProvider) == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: colors.textSecondary,
            ),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
          ),
          PopupMenuButton<Locale>(
            icon: Icon(Icons.language, color: colors.textSecondary),
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
                      Icon(Icons.check, size: 18, color: colors.paprika),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: colors.textSecondary),
            onPressed: () =>
                ref.read(authStateProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            gamification.when(
              loading: () => const SizedBox(height: 120),
              error: (_, __) => const SizedBox(),
              data: (state) => _AvatarSection(
                name: userName,
                state: state,
                colors: colors,
              ),
            ),
            const SizedBox(height: 24),

            gamification.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (state) => _XpBar(state: state, colors: colors),
            ),
            const SizedBox(height: 24),

            gamification.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (state) => _StatsGrid(state: state, colors: colors),
            ),
            const SizedBox(height: 24),

            palate.when(
              loading: () => const SizedBox(height: 260),
              error: (_, __) => const SizedBox(),
              data: (profile) {
                if (profile == null) return const SizedBox();
                return _PalateRadar(profile: profile, colors: colors);
              },
            ),
            const SizedBox(height: 24),

            gamification.when(
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
              data: (state) => _BadgeGrid(state: state, colors: colors),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.name,
    required this.state,
    required this.colors,
  });

  final String name;
  final GamificationState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final levelInfo = state.levelInfo;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [colors.paprika, colors.gold],
            ),
            boxShadow: [
              BoxShadow(
                color: colors.gold.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Center(
            child: Icon(levelInfo.icon, size: 36, color: Colors.white),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(levelInfo.icon, size: 14, color: colors.gold),
            const SizedBox(width: 4),
            Text(levelInfo.name,
          style: TextStyle(
            color: colors.gold,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          )),
          ],
        ),
      ],
    );
  }
}

class _XpBar extends StatelessWidget {
  const _XpBar({required this.state, required this.colors});

  final GamificationState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nextXp = state.xpForNextLevel;
    final label = nextXp != null
        ? l10n.xpProgress(state.xp, nextXp)
        : l10n.xpMax(state.xp);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              l10n.levelLabel(state.level),
              style: TextStyle(
                color: colors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: state.levelProgress,
            minHeight: 8,
            backgroundColor: colors.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.state, required this.colors});

  final GamificationState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = [
      (AppIcons.statTastings, l10n.tastingsLabel, '${state.totalJournalEntries}'),
      (AppIcons.statStreak, l10n.streakLabel, '${state.streak}d'),
      (AppIcons.statBadges, l10n.badgesLabel, '${state.earnedBadgeIds.length}'),
      (AppIcons.statScans, l10n.scansLabel, '${state.totalScans}'),
      (AppIcons.statPairings, l10n.pairingsLabel, '${state.totalPairings}'),
      (AppIcons.statChallenges, l10n.challengesLabel, '${state.totalChallenges}'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: stats.map((s) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s.$1, size: 18, color: colors.gold),
              const SizedBox(height: 4),
              Text(
                s.$3,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                s.$2,
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PalateRadar extends StatelessWidget {
  const _PalateRadar({required this.profile, required this.colors});

  final PalateProfile profile;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.yourPalate,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        PalateRadarChart(profile: profile),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(profile.archetype.icon, size: 16, color: colors.gold),
              const SizedBox(width: 6),
              Text(profile.archetype.displayName,
            style: TextStyle(
              color: colors.gold,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.state, required this.colors});

  final GamificationState state;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.achievements,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: kBadges.map((badge) {
            final earned = state.earnedBadgeIds.contains(badge.id);
            return Container(
              decoration: BoxDecoration(
                color: earned
                    ? colors.gold.withValues(alpha: 0.1)
                    : colors.surface1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: earned ? colors.gold : colors.borderSubtle,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Opacity(
                    opacity: earned ? 1.0 : 0.3,
                    child: Icon(
                      badge.icon,
                      size: 22,
                      color: earned ? colors.gold : colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: earned
                          ? colors.textSecondary
                          : colors.textTertiary,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

