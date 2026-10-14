import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/affiliate/affiliate_url_resolver.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/core/utils/formatters.dart';
import 'package:winebro/features/journal/presentation/widgets/quick_log_sheet.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/shared/widgets/open_facts_section.dart';
import 'package:winebro/shared/widgets/product_action_row.dart';

/// The drink detail sheet used by Home, Pair and Scan — and rendered as-is
/// by the console's mobile preview.
class ProductDetailSheet extends ConsumerWidget {
  const ProductDetailSheet({required this.product, this.controller, super.key});

  final Product product;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final openFacts = product.openFacts;
    return Container(
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
    );
  }
}

/// Opens [ProductDetailSheet] as a draggable bottom sheet.
void showProductDetailSheet(BuildContext context, Product product) {
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
      builder: (_, controller) => ProductDetailSheet(product: product, controller: controller),
    ),
  );
}
