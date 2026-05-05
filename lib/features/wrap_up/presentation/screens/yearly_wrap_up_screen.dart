import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/wrap_up/domain/yearly_wrap_up.dart';

/// Pulls all user journal entries for the active calendar year and
/// returns the derived YearlyWrapUp. Recomputed each visit — no
/// caching since the 5-card pageview is rare-use.
final yearlyWrapUpProvider = FutureProvider<YearlyWrapUp>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    return YearlyWrapUp.fromEntries(const [], DateTime.now().year);
  }
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('journal')
      .get();
  final entries = snap.docs
      .map((d) => JournalEntry.fromMap(d.data()))
      .toList();
  return YearlyWrapUp.fromEntries(entries, DateTime.now().year);
});

class YearlyWrapUpScreen extends ConsumerStatefulWidget {
  const YearlyWrapUpScreen({super.key});

  @override
  ConsumerState<YearlyWrapUpScreen> createState() =>
      _YearlyWrapUpScreenState();
}

class _YearlyWrapUpScreenState extends ConsumerState<YearlyWrapUpScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(int total) {
    HapticFeedback.lightImpact();
    if (_index < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final wrapAsync = ref.watch(yearlyWrapUpProvider);

    return Scaffold(
      backgroundColor: colors.charcoal,
      body: SafeArea(
        child: wrapAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.paprika),
          ),
          error: (_, __) => _ErrorState(colors: colors),
          data: (wrap) {
            if (wrap.isEmpty) return _EmptyState(year: wrap.year, colors: colors);
            final cards = _buildCards(context, colors, wrap);
            return Column(
              children: [
                _ProgressBar(
                  index: _index,
                  total: cards.length,
                  colors: colors,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${wrap.year} ${context.l10n.wrapUpYearSuffix}',
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colors.textSecondary),
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _index = i),
                    children: cards,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _next(cards.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.paprika,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _index < cards.length - 1
                            ? context.l10n.wrapUpNext
                            : context.l10n.wrapUpDone,
                        style: TextStyle(
                          color: colors.inkOnHero,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildCards(
    BuildContext context,
    AppColors colors,
    YearlyWrapUp wrap,
  ) {
    final l10n = context.l10n;
    return [
      _WrapCard(
        eyebrow: l10n.wrapUpYourYearEyebrow,
        bigStat: '${wrap.totalTastings}',
        bigLabel: l10n.wrapUpTastingsLabel,
        body: l10n.wrapUpYourYearBody(wrap.uniqueProducts),
        accent: colors.paprika,
        ink: colors.inkOnHero,
      ),
      if (wrap.topProduct != null)
        _WrapCard(
          eyebrow: l10n.wrapUpMostPouredEyebrow,
          headline: wrap.topProduct!,
          body: l10n.wrapUpMostPouredBody,
          accent: colors.paprikaDark,
          ink: colors.inkOnHero,
        ),
      if (wrap.topRegion != null)
        _WrapCard(
          eyebrow: l10n.wrapUpFavoriteRegionEyebrow,
          headline: wrap.topRegion!,
          body: l10n.wrapUpFavoriteRegionBody,
          accent: colors.thunder,
          ink: colors.inkOnHero,
        ),
      if (wrap.topPairing != null)
        _WrapCard(
          eyebrow: l10n.wrapUpTopPairingEyebrow,
          headline: wrap.topPairing!,
          body: l10n.wrapUpTopPairingBody,
          accent: colors.salem,
          ink: colors.inkOnHero,
        ),
      _WrapCard(
        eyebrow: l10n.wrapUpStreakEyebrow,
        bigStat: '${wrap.longestStreak}',
        bigLabel: l10n.wrapUpStreakLabel,
        body: l10n.wrapUpStreakBody(wrap.bottlesYouLoved),
        accent: colors.paprikaDeep,
        ink: colors.inkOnHero,
      ),
    ];
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.index,
    required this.total,
    required this.colors,
  });

  final int index;
  final int total;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
              height: 3,
              decoration: BoxDecoration(
                color: i <= index ? colors.paprika : colors.borderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _WrapCard extends StatelessWidget {
  const _WrapCard({
    required this.eyebrow,
    required this.body,
    required this.accent,
    required this.ink,
    this.headline,
    this.bigStat,
    this.bigLabel,
  });

  final String eyebrow;
  final String body;
  final String? headline;
  final String? bigStat;
  final String? bigLabel;
  final Color accent;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, accent.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow,
              style: TextStyle(
                color: ink.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            if (bigStat != null) ...[
              Text(
                bigStat!,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: ink,
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              if (bigLabel != null)
                Text(
                  bigLabel!,
                  style: TextStyle(
                    color: ink.withValues(alpha: 0.85),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ] else if (headline != null)
              Text(
                headline!,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  color: ink,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              body,
              style: TextStyle(
                color: ink.withValues(alpha: 0.92),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.year, required this.colors});

  final int year;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: colors.paprika, size: 48),
            const SizedBox(height: 16),
            Text(
              context.l10n.wrapUpEmptyTitle(year),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.wrapUpEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/journal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.paprika,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
              child: Text(
                context.l10n.wrapUpEmptyCta,
                style: TextStyle(color: colors.inkOnHero),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Something went wrong.',
        style: TextStyle(color: colors.textTertiary),
      ),
    );
  }
}
