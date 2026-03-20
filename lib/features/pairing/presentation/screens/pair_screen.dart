import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/presentation/providers/pairing_providers.dart';
import 'package:winebro/shared/widgets/product_card.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pairTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.paprika,
          labelColor: colors.textPrimary,
          unselectedLabelColor: colors.textTertiary,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: l10n.foodToDrink),
            Tab(text: l10n.drinkToFood),
            Tab(text: l10n.occasionTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FoodToDrinkTab(),
          _DrinkToFoodTab(),
          _OccasionTab(),
        ],
      ),
    );
  }
}

class _FoodToDrinkTab extends ConsumerStatefulWidget {
  const _FoodToDrinkTab();

  @override
  ConsumerState<_FoodToDrinkTab> createState() => _FoodToDrinkTabState();
}

class _FoodToDrinkTabState extends ConsumerState<_FoodToDrinkTab> {
  String? _selectedDishId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final grouped = ref.watch(groupedDishesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatAreYouEating,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.pickDishForDrink,
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                entry.key.displayName,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((dish) {
                final isSelected = _selectedDishId == dish.id;
                return ChoiceChip(
                  label: Text(dish.name),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedDishId = dish.id),
                  selectedColor:
                      colors.paprika.withValues(alpha: 0.2),
                  side: BorderSide(
                    color: isSelected
                        ? colors.paprika
                        : colors.borderDefault,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colors.textPrimary
                        : colors.textSecondary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],

          if (_selectedDishId != null) ...[
            const SizedBox(height: 24),
            Divider(color: colors.borderSubtle),
            const SizedBox(height: 16),
            _DrinkResults(dishId: _selectedDishId!),
          ],
        ],
      ),
    );
  }
}

class _DrinkResults extends ConsumerWidget {
  const _DrinkResults({required this.dishId});
  final String dishId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final results = ref.watch(drinkForFoodProvider(dishId));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(l10n.errorGeneric(e.toString())),
      data: (pairings) {
        if (pairings.isEmpty) {
          return Text(
            l10n.noPairingsQuiz,
            style: TextStyle(color: colors.textTertiary),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bestPairings,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...pairings.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(
                product: r.product,
                matchPercent: r.matchPercent,
              ),
            )),
          ],
        );
      },
    );
  }
}

class _DrinkToFoodTab extends ConsumerStatefulWidget {
  const _DrinkToFoodTab();

  @override
  ConsumerState<_DrinkToFoodTab> createState() => _DrinkToFoodTabState();
}

class _DrinkToFoodTabState extends ConsumerState<_DrinkToFoodTab> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final products = ref.watch(allProductsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatAreYouDrinking,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                final isSelected = _selectedProductId == p.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.name),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedProductId = p.id),
                    selectedColor:
                        colors.paprika.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: isSelected
                          ? colors.paprika
                          : colors.borderDefault,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colors.textPrimary
                          : colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              },
            ),
          ),

          if (_selectedProductId != null) ...[
            const SizedBox(height: 24),
            _FoodResults(productId: _selectedProductId!),
          ],
        ],
      ),
    );
  }
}

class _FoodResults extends ConsumerWidget {
  const _FoodResults({required this.productId});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final results = ref.watch(foodForDrinkProvider(productId));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(l10n.errorGeneric(e.toString())),
      data: (pairings) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.goesGreatWith,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...pairings.map((r) => _FoodPairingCard(result: r)),
        ],
      ),
    );
  }
}

class _FoodPairingCard extends StatelessWidget {
  const _FoodPairingCard({required this.result});
  final FoodPairingResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.dish.icon,
                size: 20,
                color: colors.paprikaLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.dish.name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: result.strategy == PairingStrategy.complement
                      ? colors.salem.withValues(alpha: 0.15)
                      : colors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  result.strategy.displayName,
                  style: TextStyle(
                    color: result.strategy == PairingStrategy.complement
                        ? colors.salemLight
                        : colors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${result.matchPercent}%',
                style: TextStyle(
                  color: colors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.explanation,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OccasionTab extends ConsumerStatefulWidget {
  const _OccasionTab();

  @override
  ConsumerState<_OccasionTab> createState() => _OccasionTabState();
}

class _OccasionTabState extends ConsumerState<_OccasionTab> {
  Occasion? _selectedOccasion;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatsTheOccasion,
            style: TextStyle(
              fontFamily: 'PlayfairDisplay',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: Occasion.values.map((occ) {
              final isSelected = _selectedOccasion == occ;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedOccasion = occ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.paprika.withValues(alpha: 0.15)
                        : colors.surface1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? colors.paprika
                          : colors.borderDefault,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(occ.icon, size: 20, color: isSelected ? colors.paprikaLight : colors.textTertiary),
                      const SizedBox(width: 8),
                      Text(
                        occ.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? colors.textPrimary
                              : colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          if (_selectedOccasion != null) ...[
            const SizedBox(height: 24),
            _OccasionResults(occasion: _selectedOccasion!),
          ],
        ],
      ),
    );
  }
}

class _OccasionResults extends ConsumerWidget {
  const _OccasionResults({required this.occasion});
  final Occasion occasion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final results = ref.watch(occasionPairingProvider(occasion));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text(l10n.errorGeneric(e.toString())),
      data: (pairings) {
        if (pairings.isEmpty) {
          return Text(
            l10n.completeQuizSuggestions,
            style: TextStyle(color: colors.textTertiary),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.perfectFor(occasion.displayName),
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...pairings.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(
                product: r.product,
                matchPercent: r.matchPercent,
              ),
            )),
          ],
        );
      },
    );
  }
}

