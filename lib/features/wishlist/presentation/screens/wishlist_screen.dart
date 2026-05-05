import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/affiliate/affiliate_url_resolver.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:winebro/shared/widgets/product_action_row.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.wishlistTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
      ),
      body: wishlist.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.paprika)),
        error: (_, __) => Center(
          child: Text('Could not load wishlist',
              style: TextStyle(color: colors.textTertiary)),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 64, color: colors.textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.wishlistTitle,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.wishlistEmptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
              // Try to resolve full Product from catalogue; fall back
              // to a synthetic Product if it was saved from a non-seed
              // source (Quick log custom name, future scan corrections).
              final product = kSeedProducts.firstWhere(
                (p) => p.id == e.productId,
                orElse: () => kSeedProducts.first.copyWith(
                  id: e.productId,
                  name: e.productName,
                  region: e.region,
                  price: e.priceInr ?? 0,
                ),
              );
              return _WishlistRow(product: product, colors: colors);
            },
          );
        },
      ),
    );
  }
}

class _WishlistRow extends StatelessWidget {
  const _WishlistRow({required this.product, required this.colors});
  final Product product;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.paprika, colors.paprikaDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.wine_bar, color: colors.inkOnHero, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.subcategory} · ${product.region}',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProductActionRow(
            product: product,
            source: AffiliateSource.wishlist,
          ),
        ],
      ),
    );
  }
}
