import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:winebro/features/friends/data/friend_repository.dart';
import 'package:winebro/features/profile/domain/gamification.dart';
import 'package:winebro/features/profile/presentation/widgets/cross_category_survey_sheet.dart';
import 'package:winebro/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:winebro/shared/widgets/palate_radar_chart.dart';

/// True when the user has logged ≥3 journal entries AND the
/// cross-category survey is not yet recorded. Used to surface
/// the survey CTA on Profile.
final crossCategorySurveyNeededProvider =
    StreamProvider<bool>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(false);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('cross_category')
      .doc('initial')
      .snapshots()
      .map((doc) => !doc.exists);
});

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

/// Redesigned 2026 Profile.
///
/// Replaces the heaviest screen in the app with focus + restraint.
///
/// Hero block      Avatar with circular XP ring drawn around it.
///                 Name in Playfair 32 + archetype in goldWarm small caps.
/// Stats row       Hide tiles that are zero. Show only the 3 meaningful
///                 numbers (Tastings, Streak, Badges) — never six zeros.
/// Palate radar    Gated on totalJournalEntries >= 3. Until then, shows
///                 a "we're learning your palate" prompt with N/3 progress.
/// Achievements    Next 2 unearned badges with progress bars (e.g.,
///                 "Eagle Eye · 0/1 scans · 0%"). "View all" expands sheet.
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
            icon: Icon(Icons.settings_outlined, color: colors.textSecondary),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: gamification.when(
        loading: () => Center(child: CircularProgressIndicator(color: colors.paprika)),
        error: (_, __) => Center(
          child: Text('Something went wrong', style: TextStyle(color: colors.textTertiary)),
        ),
        data: (state) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _HeroBlock(name: userName, state: state),
              const SizedBox(height: 32),
              _StatsRow(state: state),
              const SizedBox(height: 32),
              if (state.totalJournalEntries >= 3) const _CrossCategoryTile(),
              const _FriendsTile(),
              const _WishlistTile(),
              const SizedBox(height: 24),
              _PalateSection(state: state, palate: palate),
              const SizedBox(height: 32),
              _AchievementsSection(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Wishlist tile — entry to saved-for-later list
// ============================================================

class _WishlistTile extends ConsumerWidget {
  const _WishlistTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final wishlist = ref.watch(wishlistProvider).value ?? const [];
    if (wishlist.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: () => context.push('/wishlist'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(Icons.bookmark, color: context.paprikaOnSurface, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.wishlistTitle,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${wishlist.length} bottle${wishlist.length == 1 ? '' : 's'} saved',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Friends tile — entry into friend graph
// ============================================================

class _FriendsTile extends ConsumerWidget {
  const _FriendsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final friends = ref.watch(friendsStreamProvider).value ?? const [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/friends'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: colors.paprika, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.friendsProfileTitle,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      friends.isEmpty
                          ? context.l10n.friendsProfileEmpty
                          : context.l10n
                              .friendsProfileCount(friends.length),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Cross-category survey tile (D5)
// ============================================================

class _CrossCategoryTile extends ConsumerWidget {
  const _CrossCategoryTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final needed =
        ref.watch(crossCategorySurveyNeededProvider).value ?? false;
    if (!needed) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => CrossCategorySurveySheet.show(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.salemOnSurface.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.layers_outlined,
                  color: context.salemOnSurface, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.crossCategoryProfileTitle,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.crossCategoryProfileHint,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Hero block — avatar with circular XP ring
// ============================================================

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({required this.name, required this.state});
  final String name;
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final levelInfo = state.levelInfo;

    return Column(
      children: [
        // Avatar + ring
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated XP ring
              SizedBox(
                width: 120,
                height: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: state.levelProgress),
                  duration: AppMotion.cinematic,
                  curve: AppMotion.standard,
                  builder: (_, value, __) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 6,
                    backgroundColor: colors.surface3,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              // Avatar
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colors.paprika, colors.paprikaLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'B',
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w900,
                      color: colors.inkOnHero,
                      fontSize: 40,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        // Level pill sits on the Profile body surface (cream in light /
        // charcoal in dark). Repainted from goldWarm (=white universally,
        // invisible on cream) to paprika tint — works in both themes
        // because paprika is brand-locked and paprikaOnSurface clears
        // AA on charcoal in dark theme.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colors.paprika.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.paprika.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(levelInfo.icon,
                  size: 14, color: context.paprikaOnSurface),
              const SizedBox(width: 6),
              Text(
                '${levelInfo.name.toUpperCase()} · LV ${state.level + 1}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: context.paprikaOnSurface,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _xpLabel(state),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: colors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _xpLabel(GamificationState state) {
    final next = state.xpForNextLevel;
    if (next == null) return '${state.xp} XP · MAX LEVEL';
    return '${state.xp} / $next XP';
  }
}

// ============================================================
// Stats row — only show non-zero
// ============================================================

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tiles = <({String label, int value, IconData icon})>[
      (label: 'TASTINGS', value: state.totalJournalEntries, icon: Icons.book_outlined),
      (label: 'STREAK', value: state.streak, icon: Icons.local_fire_department_outlined),
      (label: 'BADGES', value: state.earnedBadgeIds.length, icon: Icons.military_tech_outlined),
    ];

    return Row(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 36,
              color: colors.borderSubtle,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
          Expanded(child: _StatTile(tile: tiles[i])),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.tile});
  final ({String label, int value, IconData icon}) tile;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        Icon(tile.icon, color: colors.gold, size: 18),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: tile.value.toDouble()),
          duration: AppMotion.ticker,
          curve: AppMotion.standard,
          builder: (_, v, __) => Text(
            v.round().toString(),
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colors.textPrimary,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tile.label,
          style: context.eyebrow.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

// ============================================================
// Palate section — gated radar
// ============================================================

class _PalateSection extends StatelessWidget {
  const _PalateSection({required this.state, required this.palate});

  final GamificationState state;
  final AsyncValue<PalateProfile?> palate;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasEnoughData = state.totalJournalEntries >= 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: AppElevation.e1(dark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: colors.paprika, size: 16),
              const SizedBox(width: 8),
              Text(
                context.l10n.profileTasteDnaEyebrow,
                style: context.eyebrow.copyWith(color: colors.paprika),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasEnoughData)
            palate.when(
              loading: () => SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: colors.paprika),
                ),
              ),
              error: (_, __) => Text(
                'Could not load your palate.',
                style: TextStyle(color: colors.textTertiary),
              ),
              data: (profile) {
                if (profile == null) {
                  return Text(
                    'Take the quiz to start your palate.',
                    style: TextStyle(color: colors.textTertiary),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Built from ${state.totalJournalEntries} tastings',
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PalateRadarChart(profile: profile),
                    const SizedBox(height: 8),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(profile.archetype.icon, size: 14, color: colors.gold),
                          const SizedBox(width: 6),
                          Text(
                            profile.archetype.displayName.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: colors.gold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
          else
            _PalateLearning(state: state),
        ],
      ),
    );
  }
}

class _PalateLearning extends StatelessWidget {
  const _PalateLearning({required this.state});
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We\'re learning your palate.',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Log ${3 - state.totalJournalEntries} more tasting${state.totalJournalEntries == 2 ? '' : 's'} to unlock your taste DNA radar.',
          style: context.serifQuote.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(3, (i) {
            final earned = i < state.totalJournalEntries;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                height: 8,
                decoration: BoxDecoration(
                  color: earned ? colors.paprika : colors.surface3,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '${state.totalJournalEntries} of 3 logged',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Achievements — next 2 with progress
// ============================================================

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.state});
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final unearned = kBadges
        .where((b) => !state.earnedBadgeIds.contains(b.id))
        .map((b) => (badge: b, progress: _progressFor(b.condition, state)))
        .where((t) => t.progress < 1.0)
        .toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));

    final next = unearned.take(2).toList();
    final earnedRecent = state.earnedBadgeIds
        .map((id) => kBadges.firstWhere((b) => b.id == id, orElse: () => kBadges.first))
        .toList()
        .reversed
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.profileNextToUnlock,
              style: context.eyebrow.copyWith(color: colors.textTertiary),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showAllBadges(context, state),
              child: Text(context.l10n.profileViewAllBadges(kBadges.length)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (next.isEmpty)
          Text(
            'You\'ve earned them all, Bro. Legendary.',
            style: context.serifQuote.copyWith(color: colors.textSecondary),
          )
        else
          ...next.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BadgeProgressCard(
                  badge: t.badge,
                  progress: t.progress,
                  state: state,
                ),
              )),
        if (earnedRecent.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            context.l10n.profileRecentlyEarned,
            style: context.eyebrow.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Row(
            children: earnedRecent
                .map((b) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _EarnedBadgeChip(badge: b),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  void _showAllBadges(BuildContext context, GamificationState state) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  context.l10n.profileAllAchievements,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: ctrl,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: kBadges.length,
                  itemBuilder: (context, i) {
                    final badge = kBadges[i];
                    final earned = state.earnedBadgeIds.contains(badge.id);
                    return Container(
                      decoration: BoxDecoration(
                        color: earned
                            ? colors.gold.withValues(alpha: 0.1)
                            : colors.surface1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: earned ? colors.gold : colors.borderSubtle,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: earned ? 1 : 0.3,
                              child: Icon(
                                badge.icon,
                                size: 24,
                                color: earned ? colors.gold : colors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              badge.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: earned
                                    ? colors.textSecondary
                                    : colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeProgressCard extends StatelessWidget {
  const _BadgeProgressCard({
    required this.badge,
    required this.progress,
    required this.state,
  });

  final Badge badge;
  final double progress;
  final GamificationState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: AppElevation.e1(dark: isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
            ),
            child: Icon(badge.icon, color: colors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badge.name,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badge.description,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    color: colors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.surface3,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: AppMotion.cinematic,
                      curve: AppMotion.standard,
                      builder: (_, v, __) => FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: colors.gold,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _progressLabel(badge.condition, state),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$pct%',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: colors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarnedBadgeChip extends StatelessWidget {
  const _EarnedBadgeChip({required this.badge});
  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.gold.withValues(alpha: 0.4)),
      ),
      child: Icon(badge.icon, color: colors.gold, size: 24),
    );
  }
}

// ============================================================
// Progress helpers
// ============================================================

double _progressFor(BadgeCondition cond, GamificationState s) {
  return switch (cond) {
    ScanCountCondition(:final count) =>
      (s.totalScans / count).clamp(0.0, 1.0),
    JournalCountCondition(:final count) =>
      (s.totalJournalEntries / count).clamp(0.0, 1.0),
    PairingCountCondition(:final count) =>
      (s.totalPairings / count).clamp(0.0, 1.0),
    StreakCondition(:final days) => (s.streak / days).clamp(0.0, 1.0),
    ChallengeCountCondition(:final count) =>
      (s.totalChallenges / count).clamp(0.0, 1.0),
    CategoryExploredCondition(:final category) =>
      ((s.exploredCategories[category] ?? 0) / 5).clamp(0.0, 1.0),
    SpecialCondition() => 0.0,
  };
}

String _progressLabel(BadgeCondition cond, GamificationState s) {
  return switch (cond) {
    ScanCountCondition(:final count) =>
      '${s.totalScans} / $count scans',
    JournalCountCondition(:final count) =>
      '${s.totalJournalEntries} / $count tastings',
    PairingCountCondition(:final count) =>
      '${s.totalPairings} / $count pairings',
    StreakCondition(:final days) =>
      '${s.streak} / $days day streak',
    ChallengeCountCondition(:final count) =>
      '${s.totalChallenges} / $count challenges',
    CategoryExploredCondition(:final category) =>
      '${s.exploredCategories[category] ?? 0} / 5 ${category}s',
    SpecialCondition() => 'Hidden goal',
  };
}
