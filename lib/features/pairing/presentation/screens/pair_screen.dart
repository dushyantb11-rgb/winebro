import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:winebro/shared/widgets/hero_photo_card.dart';

/// Redesigned 2026 Pair.
///
/// Search-first interaction model. Replaces the wall of 27 region-grouped
/// chips with a single tall input + 3 mode pills. Type, voice, or pick
/// one of the trending dishes to start; results swap in below as a hero
/// pairing card with two compact alternates.
///
/// Three modes:
///   Food → Drink     pick a dish, get drink suggestions
///   Drink → Food     pick a drink, get food suggestions
///   Occasion         pick an occasion, get drink suggestions
class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

enum PairMode { foodToDrink, drinkToFood, occasion }

class _PairScreenState extends ConsumerState<PairScreen> {
  PairMode _mode = PairMode.foodToDrink;
  final _searchController = TextEditingController();
  String _query = '';
  Timer? _placeholderTimer;
  int _placeholderIndex = 0;

  Dish? _selectedDish;
  Product? _selectedProduct;
  Occasion? _selectedOccasion;

  static const _placeholders = [
    'butter chicken…',
    'single malt…',
    'anniversary dinner…',
    'pizza margherita…',
    'rainy Friday night…',
    'biryani…',
    'old monk on the rocks…',
  ];

  @override
  void initState() {
    super.initState();
    _placeholderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _query.isEmpty) {
        setState(() => _placeholderIndex =
            (_placeholderIndex + 1) % _placeholders.length);
      }
    });
  }

  @override
  void dispose() {
    _placeholderTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _switchMode(PairMode m) {
    setState(() {
      _mode = m;
      _selectedDish = null;
      _selectedProduct = null;
      _selectedOccasion = null;
      _searchController.clear();
      _query = '';
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedDish = null;
      _selectedProduct = null;
      _selectedOccasion = null;
      _searchController.clear();
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasSelection = _selectedDish != null ||
        _selectedProduct != null ||
        _selectedOccasion != null;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Pair',
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(
                  hasSelection
                      ? 'Bro\'s recommendations are below.'
                      : 'What are you eating, drinking, or celebrating?',
                  style: context.serifQuote.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ),

            // ====== Search input (or selection breadcrumb) ======
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: AppMotion.gentle,
                child: hasSelection
                    ? _SelectionBreadcrumb(
                        key: const ValueKey('selection'),
                        label: _selectedDish?.name ??
                            _selectedProduct?.name ??
                            _selectedOccasion?.displayName ??
                            '',
                        onClear: _clearSelection,
                      )
                    : Padding(
                        key: const ValueKey('search'),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: _hintFor(_mode),
                            prefixIcon: Icon(Icons.search,
                                color: colors.textTertiary),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.mic_none,
                                  color: colors.textSecondary),
                              tooltip: 'Voice (coming soon)',
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Voice coming in v1.1, Bro.'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            // ====== Mode pills ======
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ModePill(
                        label: 'Food → Drink',
                        icon: Icons.restaurant_menu,
                        active: _mode == PairMode.foodToDrink,
                        onTap: () => _switchMode(PairMode.foodToDrink),
                      ),
                      const SizedBox(width: 8),
                      _ModePill(
                        label: 'Drink → Food',
                        icon: Icons.wine_bar,
                        active: _mode == PairMode.drinkToFood,
                        onTap: () => _switchMode(PairMode.drinkToFood),
                      ),
                      const SizedBox(width: 8),
                      _ModePill(
                        label: 'Occasion',
                        icon: Icons.nightlife,
                        active: _mode == PairMode.occasion,
                        onTap: () => _switchMode(PairMode.occasion),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ====== Body — empty state OR live search OR results ======
            if (hasSelection)
              SliverToBoxAdapter(child: _ResultsBody(
                mode: _mode,
                dish: _selectedDish,
                product: _selectedProduct,
                occasion: _selectedOccasion,
              ))
            else if (_query.isNotEmpty)
              SliverToBoxAdapter(child: _LiveSearchResults(
                mode: _mode,
                query: _query,
                onPickDish: (d) =>
                    setState(() => _selectedDish = d),
                onPickProduct: (p) =>
                    setState(() => _selectedProduct = p),
              ))
            else
              SliverToBoxAdapter(child: _EmptyState(
                mode: _mode,
                onPickDish: (d) => setState(() => _selectedDish = d),
                onPickProduct: (p) =>
                    setState(() => _selectedProduct = p),
                onPickOccasion: (o) =>
                    setState(() => _selectedOccasion = o),
              )),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  String _hintFor(PairMode m) {
    return switch (m) {
      PairMode.foodToDrink =>
        'What are you eating? Try ${_placeholders[_placeholderIndex]}',
      PairMode.drinkToFood => 'What are you drinking?',
      PairMode.occasion => 'What\'s the occasion?',
    };
  }
}

// ============================================================
// Mode pill
// ============================================================

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: active ? colors.paprika : colors.surface1,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? colors.paprika : colors.borderDefault,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? colors.inkOnHero : colors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? colors.inkOnHero : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Selection breadcrumb (replaces search when something is picked)
// ============================================================

class _SelectionBreadcrumb extends StatelessWidget {
  const _SelectionBreadcrumb({
    super.key,
    required this.label,
    required this.onClear,
  });

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: colors.paprika.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.paprika.withValues(alpha: 0.4)),
          boxShadow: AppElevation.e1(dark: isDark),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 18, color: colors.paprika),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: colors.textSecondary),
              tooltip: 'Clear',
              onPressed: () {
                HapticFeedback.lightImpact();
                onClear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Live search results (typed but nothing selected yet)
// ============================================================

class _LiveSearchResults extends ConsumerWidget {
  const _LiveSearchResults({
    required this.mode,
    required this.query,
    required this.onPickDish,
    required this.onPickProduct,
  });

  final PairMode mode;
  final String query;
  final ValueChanged<Dish> onPickDish;
  final ValueChanged<Product> onPickProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    if (mode == PairMode.foodToDrink) {
      final dishes = ref.read(allDishesProvider);
      final matches = dishes
          .map((d) => (
                d,
                StringSimilarity.compareTwoStrings(
                    query.toLowerCase(), d.name.toLowerCase()),
              ))
          .where((t) =>
              t.$2 > 0.2 ||
              t.$1.name.toLowerCase().contains(query.toLowerCase()))
          .toList()
        ..sort((a, b) => b.$2.compareTo(a.$2));

      if (matches.isEmpty) {
        return _NoMatch(query: query, colors: colors);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: matches.take(8).map((t) {
            return _SearchRow(
              icon: t.$1.icon,
              label: t.$1.name,
              subtitle: t.$1.category.displayName,
              onTap: () => onPickDish(t.$1),
            );
          }).toList(),
        ),
      );
    }

    if (mode == PairMode.drinkToFood) {
      final products = ref.read(allProductsProvider);
      final matches = products
          .map((p) => (
                p,
                StringSimilarity.compareTwoStrings(
                    query.toLowerCase(), p.name.toLowerCase()),
              ))
          .where((t) =>
              t.$2 > 0.2 ||
              t.$1.name.toLowerCase().contains(query.toLowerCase()))
          .toList()
        ..sort((a, b) => b.$2.compareTo(a.$2));

      if (matches.isEmpty) {
        return _NoMatch(query: query, colors: colors);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: matches.take(8).map((t) {
            return _SearchRow(
              icon: Icons.wine_bar,
              label: t.$1.name,
              subtitle: '${t.$1.subcategory} · ${t.$1.region}',
              onTap: () => onPickProduct(t.$1),
            );
          }).toList(),
        ),
      );
    }

    // Occasion mode — fuzzy match against Occasion enum
    final matches = Occasion.values
        .where((o) => o.displayName
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    if (matches.isEmpty) {
      return _NoMatch(query: query, colors: colors);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: matches.map((o) {
          return _SearchRow(
            icon: o.icon,
            label: o.displayName,
            subtitle: 'Occasion',
            onTap: () {
              // Caller doesn't accept occasion; cheat via parent state
              // by closing the keyboard and asking parent to select.
              Navigator.of(context, rootNavigator: false).maybePop();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colors.paprika),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, size: 18, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _NoMatch extends StatelessWidget {
  const _NoMatch({required this.query, required this.colors});
  final String query;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48, color: colors.textTertiary),
          const SizedBox(height: 12),
          Text(
            'Nothing matches "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a popular dish, drink, or occasion below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 13,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty state — trending dishes, drinks, occasions
// ============================================================

class _EmptyState extends ConsumerWidget {
  const _EmptyState({
    required this.mode,
    required this.onPickDish,
    required this.onPickProduct,
    required this.onPickOccasion,
  });

  final PairMode mode;
  final ValueChanged<Dish> onPickDish;
  final ValueChanged<Product> onPickProduct;
  final ValueChanged<Occasion> onPickOccasion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    if (mode == PairMode.occasion) {
      final occasions = Occasion.values;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: occasions
              .map((o) => _OccasionTile(occasion: o, onTap: () => onPickOccasion(o)))
              .toList(),
        ),
      );
    }

    final isFood = mode == PairMode.foodToDrink;
    final dishes = ref.read(allDishesProvider).take(8).toList();
    final products = ref.read(allProductsProvider).take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            isFood ? 'TRENDING DISHES' : 'TRENDING POURS',
            style: context.eyebrow.copyWith(color: colors.textTertiary),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            itemCount: isFood ? dishes.length : products.length,
            itemBuilder: (context, i) {
              if (isFood) {
                final d = dishes[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _TrendingDishCard(dish: d, onTap: () => onPickDish(d)),
                );
              }
              final p = products[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _TrendingDrinkCard(
                  product: p,
                  onTap: () => onPickProduct(p),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OccasionTile extends StatelessWidget {
  const _OccasionTile({required this.occasion, required this.onTap});
  final Occasion occasion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.borderSubtle),
          boxShadow: AppElevation.e1(dark: isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(occasion.icon, color: colors.paprikaLight, size: 24),
            Text(
              occasion.displayName,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingDishCard extends StatelessWidget {
  const _TrendingDishCard({required this.dish, required this.onTap});
  final Dish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 140,
      child: HeroPhotoCard(
        aspectRatio: 7 / 9,
        borderRadius: 18,
        gradientColors: [colors.paprikaDeep, colors.paprika, colors.paprikaDark],
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(dish.icon, color: colors.inkOnHero, size: 18),
            const SizedBox(height: 6),
            Text(
              dish.name,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colors.inkOnHero,
                height: 1.05,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingDrinkCard extends StatelessWidget {
  const _TrendingDrinkCard({required this.product, required this.onTap});
  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: 160,
      child: HeroPhotoCard(
        aspectRatio: 8 / 9,
        borderRadius: 18,
        imageUrl: product.imageUrl,
        gradientColors: [colors.thunder, colors.paprikaDeep],
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.name,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.inkOnHero,
                height: 1.05,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              product.subcategory,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.inkOnHero.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Results body — Bro's Pick + alternates
// ============================================================

class _ResultsBody extends ConsumerWidget {
  const _ResultsBody({
    required this.mode,
    this.dish,
    this.product,
    this.occasion,
  });

  final PairMode mode;
  final Dish? dish;
  final Product? product;
  final Occasion? occasion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    if (mode == PairMode.foodToDrink && dish != null) {
      return ref.watch(drinkForFoodProvider(dish!.id)).when(
            loading: () => _Loading(colors: colors),
            error: (e, _) => _Error(message: '$e', colors: colors),
            data: (results) => _DrinkResults(results: results),
          );
    }

    if (mode == PairMode.drinkToFood && product != null) {
      return ref.watch(foodForDrinkProvider(product!.id)).when(
            loading: () => _Loading(colors: colors),
            error: (e, _) => _Error(message: '$e', colors: colors),
            data: (results) => _FoodResults(results: results),
          );
    }

    if (mode == PairMode.occasion && occasion != null) {
      return ref.watch(occasionPairingProvider(occasion!)).when(
            loading: () => _Loading(colors: colors),
            error: (e, _) => _Error(message: '$e', colors: colors),
            data: (results) => _DrinkResults(results: results),
          );
    }

    return const SizedBox();
  }
}

class _DrinkResults extends StatelessWidget {
  const _DrinkResults({required this.results});
  final List<PairingResult> results;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Complete the quiz first to unlock personalized pairings.',
          style: TextStyle(color: colors.textTertiary),
        ),
      );
    }
    final hero = results.first;
    final alternates = results.skip(1).take(3).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _BrosPickPairingCard(result: hero),
        ),
        const SizedBox(height: 24),
        if (alternates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ALSO TRY',
                style: context.eyebrow.copyWith(color: colors.textTertiary),
              ),
            ),
          ),
        const SizedBox(height: 12),
        ...alternates.map((r) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _AlternateCard(result: r),
            )),
      ],
    );
  }
}

class _FoodResults extends StatelessWidget {
  const _FoodResults({required this.results});
  final List<FoodPairingResult> results;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No pairings found. Try another drink.',
          style: TextStyle(color: colors.textTertiary),
        ),
      );
    }
    final hero = results.first;
    final alternates = results.skip(1).take(3).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _BrosPickFoodCard(result: hero),
        ),
        const SizedBox(height: 24),
        if (alternates.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ALSO TRY',
                style: context.eyebrow.copyWith(color: colors.textTertiary),
              ),
            ),
          ),
        const SizedBox(height: 12),
        ...alternates.map((r) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _AlternateFoodCard(result: r),
            )),
      ],
    );
  }
}

class _BrosPickPairingCard extends StatelessWidget {
  const _BrosPickPairingCard({required this.result});
  final PairingResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final p = result.product;

    return HeroPhotoCard(
      imageUrl: p.imageUrl,
      gradientColors: [colors.paprika, colors.paprikaDeep, colors.thunder],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.goldWarm,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 14, color: colors.thunder),
                const SizedBox(width: 6),
                Text(
                  'BRO\'S PICK',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w800,
                    color: colors.thunder,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text('· ${result.matchPercent}% match',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w700,
                      color: colors.thunder,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            p.name,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: colors.inkOnHero,
              height: 1.05,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${p.subcategory} · ${p.region} · ₹${p.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.inkOnHero.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrosPickFoodCard extends StatelessWidget {
  const _BrosPickFoodCard({required this.result});
  final FoodPairingResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = result.dish;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.goldWarm,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'BRO\'S PICK · ${result.matchPercent}% match',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w800,
                color: colors.thunder,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(d.icon, color: colors.inkOnHero, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  d.name,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colors.inkOnHero,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.explanation,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontStyle: FontStyle.italic,
              fontSize: 16,
              color: colors.inkOnHero.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternateCard extends StatelessWidget {
  const _AlternateCard({required this.result});
  final PairingResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final p = result.product;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.paprika.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.wine_bar, color: colors.paprika, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${p.subcategory} · ₹${p.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.salem.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${result.matchPercent}%',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: colors.salem,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternateFoodCard extends StatelessWidget {
  const _AlternateFoodCard({required this.result});
  final FoodPairingResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final d = result.dish;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(d.icon, color: colors.paprika, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        d.name,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${result.matchPercent}%',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: colors.salem,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  result.explanation,
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(color: colors.paprika),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.colors});
  final String message;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        message,
        style: TextStyle(color: colors.error),
      ),
    );
  }
}
