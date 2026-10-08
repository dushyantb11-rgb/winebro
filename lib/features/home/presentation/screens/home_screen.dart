import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/utils/formatters.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/affiliate/affiliate_url_resolver.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/home/presentation/providers/home_providers.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/journal/presentation/widgets/quick_log_sheet.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/shared/widgets/open_facts_section.dart';
import 'package:winebro/shared/widgets/brand_label_card.dart';
import 'package:winebro/shared/widgets/catalog_state_banner.dart';
import 'package:winebro/shared/widgets/emotion_tile.dart';
import 'package:winebro/shared/widgets/hero_photo_card.dart';
import 'package:winebro/shared/widgets/product_action_row.dart';

/// Redesigned 2026 Home.
///
/// Five blocks, each earning its space:
///   1. Sticky header — logo PNG, avatar circle right
///   2. Time-aware greeting + serif-italic byline
///   3. Tonight's Pour — full-bleed cinematic hero card
///   4. Three emotion tiles — Cooking / Hosting / Just sipping
///   5. Continue your story (only if user has journal entries)
///   6. Bro Circle — community signals strip
///   7. Bro Tip — full-bleed paprika card with serif quote
///
/// No 4-icon QuickActions row (functions live in nav + emotion tiles).
/// No region-grouped chip wall (lives on Pair).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final authState = ref.watch(authStateProvider);
    final firstName = switch (authState) {
      Authenticated(:final user) => user.displayName.split(' ').first,
      _ => 'Bro',
    };
    final tonight = ref.watch(tonightsPourProvider);
    final continueStory = ref.watch(continueStoryProvider);
    final restock = ref.watch(restockProvider);
    final circle = ref.watch(broCircleProvider);
    final hasHistory = continueStory.valueOrNull != null ||
        restock.valueOrNull != null;
    final hour = DateTime.now().hour;

    return Scaffold(
      body: RefreshIndicator(
        color: colors.paprika,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(tonightsPourProvider);
          ref.invalidate(continueStoryProvider);
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ====== Sticky header — official logo asset ======
            SliverAppBar(
              floating: true,
              backgroundColor: colors.background,
              elevation: 0,
              centerTitle: true,
              title: Image.asset(
                'assets/images/logo.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _AvatarButton(
                    initial: firstName.isNotEmpty ? firstName[0] : 'B',
                    onTap: () => context.go('/profile'),
                  ),
                ),
              ],
            ),

            // ====== Home's primary job: start a real decision ======
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _DecisionLauncher(
                  onScanBottle: () => context.push('/scan'),
                  onChooseMeal: () => context.go('/pair'),
                  onTypeMenu: () => _showMenuPrompt(context),
                  onDish: (dishId) => context.go(
                    Uri(
                      path: '/pair',
                      queryParameters: {'dish': dishId},
                    ).toString(),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: CatalogStateBanner()),

            // ====== Greeting ======
            if (hasHistory)
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greetingFor(context, hour),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.textTertiary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstName,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _bylineFor(context, hour),
                      style: context.serifQuote.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====== Tonight's Pour — hero card ======
            if (hasHistory)
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: tonight.when(
                  loading: () => _HeroSkeleton(colors: colors),
                  error: (_, __) => const SizedBox(),
                  data: (product) {
                    if (product == null) return const SizedBox();
                    return _TonightsPourCard(
                      product: product,
                      onTap: () => _showProductDetail(context, product),
                    );
                  },
                ),
              ),
            ),

            // ====== Section eyebrow ======
            if (hasHistory)
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  context.l10n.homeEmotionEyebrow,
                  style: context.eyebrow.copyWith(color: colors.textTertiary),
                ),
              ),
            ),

            // ====== Three emotion tiles ======
            if (hasHistory)
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Row(
                  children: [
                    for (final (i, tile)
                        in AppConfig.current.home.emotionTiles.indexed) ...[
                      if (i > 0) const SizedBox(width: 12),
                      Expanded(
                        child: EmotionTile(
                          label: _emotionLabel(context, tile),
                          icon: tile.icon,
                          gradient: [
                            for (final t in tile.gradient) _paletteToken(colors, t),
                          ],
                          onTap: () => context.go(tile.route),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ====== Continue Your Story (gated on journal data) ======
            SliverToBoxAdapter(
              child: continueStory.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (data) {
                  if (data == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: _ContinueStoryCard(
                      lastTasted: data.last.productName,
                      lastDate: data.last.createdAt,
                      next: data.next,
                      onTap: () => _showProductDetail(context, data.next),
                    ),
                  );
                },
              ),
            ),

            // ====== Restock — buy-again 28-35 days ago ======
            SliverToBoxAdapter(
              child: restock.when(
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
                data: (entry) {
                  if (entry == null) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    child: _RestockCard(
                      entry: entry,
                      onTap: () => _showRestockProduct(context, entry),
                    ),
                  );
                },
              ),
            ),

            // ====== Bro Circle — community signals ======
            if (hasHistory && circle.isNotEmpty)
              SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  context.l10n.homeBroCircleEyebrow,
                  style: context.eyebrow.copyWith(color: colors.textTertiary),
                ),
              ),
            ),
            if (hasHistory && circle.isNotEmpty)
              SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                  itemCount: circle.length,
                  itemBuilder: (context, i) {
                    final signal = circle[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _BroCircleCard(
                        signal: signal,
                        onTap: () =>
                            _showProductDetail(context, signal.product),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  String _bylineFor(BuildContext context, int hour) {
    if (hour < 12) return context.l10n.homeBylineMorning;
    if (hour < 17) return context.l10n.homeBylineAfternoon;
    if (hour < 22) return context.l10n.homeBylineEvening;
    return context.l10n.homeBylineLate;
  }

  String _greetingFor(BuildContext context, int hour) {
    if (hour < 12) return context.l10n.homeGreetingMorning;
    if (hour < 17) return context.l10n.homeGreetingAfternoon;
    if (hour < 22) return context.l10n.homeGreetingEvening;
    return context.l10n.homeGreetingLate;
  }

  Future<void> _showMenuPrompt(BuildContext context) async {
    final controller = TextEditingController();
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.homeTypeDishTitle,
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.homeTypeDishHint),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (text) => Navigator.pop(sheetContext, text),
              decoration: InputDecoration(
                hintText: context.l10n.homeTypeDishExample,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, controller.text),
                child: Text(context.l10n.homeFindPairing),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    final query = value?.trim();
    if (query == null || query.isEmpty || !context.mounted) return;
    context.go(Uri(path: '/pair', queryParameters: {'query': query}).toString());
  }

  void _showRestockProduct(BuildContext context, JournalEntry entry) {
    // Match the restocked product back to a seed product (by name).
    // If we no longer carry that exact product, fall back to a same-
    // category alternative.
    final catalog =
        ProviderScope.containerOf(context, listen: false).read(allProductsProvider);
    final matched = catalog.firstWhere(
      (p) => p.name.toLowerCase() == entry.productName.toLowerCase(),
      orElse: () => catalog.firstWhere(
        (p) => p.category.group == entry.category,
        orElse: () => catalog.first,
      ),
    );
    _showProductDetail(context, matched);
  }

  void _showProductDetail(BuildContext context, Product product) {
    final colors = context.appColors;
    final openFacts = product.openFacts;

    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (openFacts.photo != null) ...[
                OpenPhotoHeader(photo: openFacts.photo!),
                const SizedBox(height: 16),
              ],
              Text(
                product.name,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                  height: 1.05,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                product.subtitle,
                style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              if (product.abv != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${formatAbv(product.abv!)} ABV',
                  style: TextStyle(color: colors.textTertiary, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                product.tastingNotes,
                style: context.serifQuote.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.aromas
                    .take(8)
                    .map((aroma) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border:
                                Border.all(color: colors.borderDefault),
                            color: colors.surface1,
                          ),
                          child: Text(aroma,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              )),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              if (openFacts.facts.isNotEmpty) ...[
                OpenFactsSection(facts: openFacts.facts),
                const SizedBox(height: 12),
              ],
              OwnContentNote(product: product),
              const SizedBox(height: 20),
              ProductBroCircleLine(product: product),
              ProductActionRow(
                product: product,
                source: AffiliateSource.detail,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        QuickLogSheet.show(
                          context,
                          prefillName: product.name,
                          prefillCategory: product.category.group,
                          prefillRegion: product.region,
                          prefillProductId: product.id,
                        );
                      },
                      icon: const Icon(Icons.book_outlined, size: 18),
                      label: Text(context.l10n.actionAddToJournal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/pair');
                      },
                      icon: const Icon(Icons.restaurant_menu_outlined,
                          size: 18),
                      label: Text(context.l10n.actionPair),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Home decision launcher
// ============================================================

class _DecisionLauncher extends ConsumerWidget {
  const _DecisionLauncher({
    required this.onScanBottle,
    required this.onChooseMeal,
    required this.onTypeMenu,
    required this.onDish,
  });

  final VoidCallback onScanBottle;
  final VoidCallback onChooseMeal;
  final VoidCallback onTypeMenu;
  final ValueChanged<String> onDish;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    // Quick-start dishes come from config/home and are shown only when
    // the dish exists in the loaded catalogue, so a chip never dead-ends.
    final dishes = ref.watch(allDishesProvider);
    final shortcuts = [
      for (final id in AppConfig.current.home.quickStartDishIds)
        if (dishes.where((d) => d.id == id).firstOrNull case final dish?) dish,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.paprika, colors.paprikaDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppElevation.eHero(dark: isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.homeLauncherEyebrow,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w800,
              color: colors.inkOnHero.withValues(alpha: 0.78),
              fontSize: 11,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.homeLauncherTitle,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w800,
              color: colors.inkOnHero,
              fontSize: 25,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.homeLauncherSubtitle,
            style: TextStyle(
              color: colors.inkOnHero.withValues(alpha: 0.82),
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScanBottle,
              icon: const Icon(Icons.document_scanner_outlined),
              label: Text(context.l10n.homeScanBottle),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.inkOnHero,
                foregroundColor: colors.paprika,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChooseMeal,
                  icon: const Icon(Icons.restaurant_menu_outlined),
                  label: Text(context.l10n.homeChooseMeal),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.inkOnHero,
                    side: BorderSide(
                      color: colors.inkOnHero.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTypeMenu,
                  icon: const Icon(Icons.edit_note_outlined),
                  label: Text(context.l10n.homeTypeDish),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.inkOnHero,
                    side: BorderSide(
                      color: colors.inkOnHero.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (shortcuts.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            context.l10n.homeQuickStart,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colors.inkOnHero.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final dish in shortcuts)
                ActionChip(
                  avatar: Icon(dish.category.icon, size: 16, color: colors.paprika),
                  label: Text(dish.name),
                  onPressed: () => onDish(dish.id),
                  backgroundColor: colors.inkOnHero,
                  labelStyle: TextStyle(
                    color: colors.paprika,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Tonight's Pour card
// ============================================================

class _TonightsPourCard extends StatelessWidget {
  const _TonightsPourCard({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return HeroPhotoCard(
      imageUrl: product.displayImageUrl,
      onTap: onTap,
      gradientColors: [
        colors.paprikaDeep,
        colors.paprikaDark,
        colors.thunder,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.inkOnHero,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 14, color: colors.thunder),
                const SizedBox(width: 6),
                Text(
                  context.l10n.homeTonightsPourEyebrow,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    color: colors.thunder,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.name,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colors.inkOnHero,
              letterSpacing: -0.5,
              height: 1.05,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            product.subtitle,
            style: TextStyle(
              color: colors.inkOnHero.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.inkOnHero.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: colors.inkOnHero.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.homeWhyThisTonight,
                  style: TextStyle(
                    color: colors.inkOnHero,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    size: 12, color: colors.inkOnHero),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ProductActionRow(
            product: product,
            source: AffiliateSource.tonightsPour,
            onTransparent: true,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Continue your story card
// ============================================================

class _ContinueStoryCard extends StatelessWidget {
  const _ContinueStoryCard({
    required this.lastTasted,
    required this.lastDate,
    required this.next,
    required this.onTap,
  });

  final String lastTasted;
  final DateTime lastDate;
  final Product next;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ago = _ago(lastDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Text(
              context.l10n.homeContinueStoryEyebrow,
              style: context.eyebrow.copyWith(color: colors.highlight),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'You logged '),
                  TextSpan(
                    text: lastTasted,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' $ago. Try this next →'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                BrandLabelCard(
                  productId: next.id,
                  productName: next.name,
                  category: next.category.group,
                  size: BrandLabelSize.compact,
                  photoUrl: next.displayImageUrl,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        next.name,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        next.subtitle,
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.salem.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    context.l10n.homeMatchPercent(78),
                    style: TextStyle(
                      color: context.salemOnSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 7) return '${diff.inDays ~/ 7} weeks ago';
    if (diff.inDays >= 1) return '${diff.inDays} days ago';
    if (diff.inHours >= 1) return '${diff.inHours} hours ago';
    return 'just now';
  }
}

// ============================================================
// Restock card — buy-again, 28-35 days ago
// ============================================================

class _RestockCard extends StatelessWidget {
  const _RestockCard({required this.entry, required this.onTap});

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysAgo = DateTime.now().difference(entry.createdAt).inDays;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.salemOnSurface.withValues(alpha: 0.4)),
          boxShadow: AppElevation.e1(dark: isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.replay_circle_filled_rounded,
                    color: context.salemOnSurface, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.homeRestockEyebrow,
                  style: context.eyebrow.copyWith(
                    color: context.salemOnSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'You loved '),
                  TextSpan(
                    text: entry.productName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' $daysAgo days ago. Time to restock?'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.paprika,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          color: colors.inkOnHero, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.homeRestockReorder,
                        style: TextStyle(
                          color: colors.inkOnHero,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Bro Circle card
// ============================================================

class _BroCircleCard extends StatelessWidget {
  const _BroCircleCard({required this.signal, required this.onTap});
  final BroCircleSignal signal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.borderSubtle),
          boxShadow: AppElevation.e1(dark: isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_outline,
                    size: 16, color: context.salemOnSurface),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    signal.headline,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: context.salemOnSurface,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                signal.subline,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.arrow_forward,
                    size: 16, color: colors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Skeleton + avatar helpers
// ============================================================

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 11,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.initial, required this.onTap});
  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: 36,
        height: 36,
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
            initial.toUpperCase(),
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.w900,
              color: colors.inkOnHero,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

String _emotionLabel(BuildContext context, EmotionTileConfig tile) =>
    switch (tile.labelKey) {
      'homeEmotionCooking' => context.l10n.homeEmotionCooking,
      'homeEmotionHosting' => context.l10n.homeEmotionHosting,
      'homeEmotionJustSipping' => context.l10n.homeEmotionJustSipping,
      _ => tile.labelKey,
    };

Color _paletteToken(AppColors c, String token) => switch (token) {
      'paprika' => c.paprika,
      'paprikaLight' => c.paprikaLight,
      'paprikaDark' => c.paprikaDark,
      'paprikaDeep' => c.paprikaDeep,
      'thunder' => c.thunder,
      'thunderLight' => c.thunderLight,
      'salem' => c.salem,
      'salemLight' => c.salemLight,
      _ => c.paprika,
    };
