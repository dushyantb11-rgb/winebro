import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_motion.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/journal/domain/journal_context.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/journal/presentation/screens/journal_screen.dart';
import 'package:winebro/features/journal/presentation/widgets/occasion_chips.dart';
import 'package:winebro/features/profile/data/gamification_service.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/shared/widgets/brand_label_card.dart';

/// Quick-log BroCard — 1-tap journal entry that drops the activation
/// barrier from 90 seconds (Pro 6-step) to ≤15 seconds.
///
/// Required:
///   - Product name (autocomplete from kSeedProducts; OR free-text if
///     scanned/manual entry not in catalogue)
///   - Star rating (1-5)
///
/// Optional:
///   - foodPaired (autocomplete from kSeedDishes) — feeds D1 data asset
///   - buyAgain toggle — feeds D7 data asset
///
/// Save creates a sparse JournalEntry document. Pro mode upgrade CTA
/// at the bottom opens the existing 6-step BroCardSheet pre-filled with
/// the name + rating already collected.
class QuickLogSheet extends ConsumerStatefulWidget {
  const QuickLogSheet({
    this.prefillName,
    this.prefillCategory,
    this.prefillRegion,
    this.prefillProductId,
    super.key,
  });

  /// Optional pre-fills from a scanner match or Pair result. When set,
  /// the search field is populated and a tap straight to the rating
  /// step is the natural flow.
  final String? prefillName;
  final String? prefillCategory;
  final String? prefillRegion;
  final String? prefillProductId;

  static Future<bool?> show(
    BuildContext context, {
    String? prefillName,
    String? prefillCategory,
    String? prefillRegion,
    String? prefillProductId,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickLogSheet(
        prefillName: prefillName,
        prefillCategory: prefillCategory,
        prefillRegion: prefillRegion,
        prefillProductId: prefillProductId,
      ),
    );
  }

  @override
  ConsumerState<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<QuickLogSheet> {
  final _searchController = TextEditingController();
  final _foodController = TextEditingController();
  final _searchFocus = FocusNode();

  Product? _selectedProduct;
  String? _customName;
  int _rating = 0;
  Dish? _selectedDish;
  String? _customDish;
  bool _buyAgain = false;
  bool _saving = false;
  JournalContext? _context;

  @override
  void initState() {
    super.initState();
    if (widget.prefillName != null) {
      _searchController.text = widget.prefillName!;
      _customName = widget.prefillName;
      // Try to match an existing product first
      _selectedProduct = kSeedProducts.firstWhere(
        (p) => p.id == widget.prefillProductId ||
            p.name.toLowerCase() == widget.prefillName!.toLowerCase(),
        orElse: () => kSeedProducts.first,
      );
      if (_selectedProduct?.name.toLowerCase() !=
          widget.prefillName!.toLowerCase()) {
        _selectedProduct = null;
      }
    } else {
      // Auto-focus search when no prefill
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _foodController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _rating > 0 &&
      ((_selectedProduct != null) ||
          (_customName != null && _customName!.trim().isNotEmpty));

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final productId = _selectedProduct?.id ?? id;
    final productName = _selectedProduct?.name ?? _customName!.trim();
    final category = _selectedProduct?.category.group ??
        widget.prefillCategory ??
        'Wine';
    final region =
        _selectedProduct?.region ?? widget.prefillRegion ?? '';
    final foodPaired = _selectedDish?.name ??
        (_customDish?.trim().isNotEmpty == true ? _customDish!.trim() : null);

    final entry = JournalEntry(
      id: id,
      userId: uid,
      productId: productId,
      productName: productName,
      category: category,
      region: region,
      rating: _rating,
      createdAt: DateTime.now(),
      foodPaired: foodPaired,
      buyAgain: _buyAgain,
      occasion: _context?.code,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('journal')
          .doc(id)
          .set(entry.toMap());

      // Streak / XP / badge fire — independent of the journal write
      // so a gamification failure never blocks the user's note.
      // ignore: discarded_futures
      ref.read(gamificationServiceProvider).recordAction(
            GamificationAction.journalEntry,
            category: category,
            withFoodPairing: foodPaired != null,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.quickLogSavedSnackbar)),
        );
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _upgradeToPro() {
    HapticFeedback.lightImpact();
    Navigator.pop(context, false);
    BroCardSheet.show(
      context,
      productName: _selectedProduct?.name ?? _customName,
      category: _selectedProduct?.category.group ?? widget.prefillCategory,
      region: _selectedProduct?.region ?? widget.prefillRegion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: colors.charcoal,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.quickLogTitle,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SearchField(
                controller: _searchController,
                focusNode: _searchFocus,
                colors: colors,
                hint: context.l10n.quickLogSearchHint,
                onChanged: (v) {
                  setState(() {
                    _customName = v;
                    _selectedProduct = null;
                  });
                },
                onProductTap: (p) {
                  setState(() {
                    _selectedProduct = p;
                    _customName = null;
                    _searchController.text = p.name;
                  });
                  _searchFocus.unfocus();
                },
              ),
              const SizedBox(height: 28),
              Text(
                context.l10n.quickLogRatingPrompt,
                style: context.eyebrow.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: 12),
              _StarRow(
                rating: _rating,
                colors: colors,
                onTap: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _rating = v);
                },
              ),
              const SizedBox(height: 28),
              Text(
                context.l10n.quickLogFoodOptional,
                style: context.eyebrow.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: 10),
              _DishField(
                controller: _foodController,
                colors: colors,
                onChanged: (v) {
                  setState(() {
                    _customDish = v;
                    _selectedDish = null;
                  });
                },
                onDishTap: (d) {
                  setState(() {
                    _selectedDish = d;
                    _customDish = null;
                    _foodController.text = d.name;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.occasionPrompt,
                style: context.eyebrow.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: 12),
              OccasionChips(
                selected: _context,
                onChanged: (c) => setState(() => _context = c),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                value: _buyAgain,
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  setState(() => _buyAgain = v);
                },
                title: Text(
                  context.l10n.quickLogBuyAgainPrompt,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                activeColor: colors.paprika,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave && !_saving ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(context.l10n.quickLogSave),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _canSave ? _upgradeToPro : null,
                  child: Text(context.l10n.quickLogProUpgrade),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Sub-widgets
// ============================================================

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.colors,
    required this.hint,
    required this.onChanged,
    required this.onProductTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final AppColors colors;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim();
    final showSuggestions = focusNode.hasFocus && query.length >= 2;
    final matches = showSuggestions
        ? _matchProducts(query).take(5).toList()
        : <Product>[];

    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.search, color: colors.textTertiary),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: colors.textTertiary),
                    tooltip: 'Clear',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
          style: TextStyle(
            fontSize: 16,
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...matches.map((p) => InkWell(
                onTap: () => onProductTap(p),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      BrandLabelCard(
                        productId: p.id,
                        productName: p.name,
                        category: p.category.group,
                        size: BrandLabelSize.compact,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                fontFamily: 'PlayfairDisplay',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${p.subcategory} · ${p.region}',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                color: colors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.add,
                          color: colors.textTertiary, size: 18),
                    ],
                  ),
                ),
              )),
        ],
      ],
    );
  }

  List<Product> _matchProducts(String query) {
    final q = query.toLowerCase();
    final scored = kSeedProducts
        .map((p) => (
              p,
              StringSimilarity.compareTwoStrings(q, p.name.toLowerCase()) +
                  (p.name.toLowerCase().contains(q) ? 0.5 : 0),
            ))
        .where((t) => t.$2 > 0.2)
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((t) => t.$1).toList();
  }
}

class _DishField extends StatelessWidget {
  const _DishField({
    required this.controller,
    required this.colors,
    required this.onChanged,
    required this.onDishTap,
  });

  final TextEditingController controller;
  final AppColors colors;
  final ValueChanged<String> onChanged;
  final ValueChanged<Dish> onDishTap;

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim();
    final matches = query.length >= 2 ? _matchDishes(query).take(4).toList() : <Dish>[];

    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. butter chicken',
            prefixIcon: Icon(Icons.restaurant_outlined,
                color: colors.textTertiary),
          ),
          style: TextStyle(
            fontSize: 14,
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (matches.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: matches
                .map((d) => GestureDetector(
                      onTap: () => onDishTap(d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.paprika.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: colors.paprika.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          d.name,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.paprikaOnSurface,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  List<Dish> _matchDishes(String query) {
    final q = query.toLowerCase();
    return kSeedDishes
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            StringSimilarity.compareTwoStrings(q, d.name.toLowerCase()) > 0.3)
        .toList();
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.rating,
    required this.colors,
    required this.onTap,
  });

  final int rating;
  final AppColors colors;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () => onTap(i + 1),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            curve: AppMotion.spring,
            padding: const EdgeInsets.all(8),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 44,
              color: filled ? colors.paprika : colors.borderStrong,
            ),
          ),
        );
      }),
    );
  }
}
