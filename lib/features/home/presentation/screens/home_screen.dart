import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_icons.dart';
import 'package:winebro/features/auth/domain/auth_state.dart';
import 'package:winebro/features/auth/presentation/providers/auth_provider.dart';
import 'package:winebro/features/home/presentation/providers/home_providers.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/journal/presentation/screens/journal_screen.dart';
import 'package:winebro/shared/widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final userName = authState is Authenticated
        ? authState.user.displayName
        : 'Bro';
    final brosPick = ref.watch(brosPickProvider);
    final trending = ref.watch(trendingProductsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            floating: true,
            backgroundColor: colors.charcoal,
            title: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: 'Wine',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Bro',
                    style: TextStyle(color: colors.salemLight),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                l10n.greeting(userName),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: brosPick.when(
              loading: () => const _PlaceholderCard(),
              error: (_, __) => const SizedBox(),
              data: (product) => product != null
                  ? GestureDetector(
                      onTap: () => _showProductDetail(context, product),
                      child: _BrosPickCard(product: product),
                    )
                  : const SizedBox(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                l10n.quickActions,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _QuickAction(
                    icon: Icons.restaurant_menu,
                    label: l10n.pairAction,
                    color: colors.paprika,
                    onTap: () => context.go('/pair'),
                  ),
                  _QuickAction(
                    icon: Icons.qr_code_scanner,
                    label: l10n.scanAction,
                    color: colors.salem,
                    onTap: () => context.go('/scan'),
                  ),
                  _QuickAction(
                    icon: Icons.donut_large,
                    label: l10n.aromaAction,
                    color: colors.gold,
                    onTap: () => context.push('/aroma'),
                  ),
                  _QuickAction(
                    icon: Icons.school,
                    label: l10n.learnAction,
                    color: colors.info,
                    onTap: () => context.push('/aroma'),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                l10n.trendingNow,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.textTertiary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: trending.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProductCard(
                    product: trending[index],
                    compact: true,
                    onTap: () => _showProductDetail(context, trending[index]),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(
                    left: BorderSide(color: colors.paprika, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppIcons.broTip, size: 14, color: colors.gold),
                        const SizedBox(width: 6),
                        Text(l10n.broTip,
                      style: TextStyle(
                        color: colors.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.broTipContent,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _showProductDetail(BuildContext context, Product product) {
    final colors = context.appColors;
    final l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.charcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.surface4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              product.name,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.subcategory} · ${product.region}',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            if (product.abv != null) ...[
              const SizedBox(height: 2),
              Text(
                '${product.abv}% ABV',
                style: TextStyle(color: colors.textTertiary, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              product.tastingNotes,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: product.aromas.take(6).map((aroma) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.borderDefault),
                ),
                child: Text(aroma, style: TextStyle(color: colors.textSecondary, fontSize: 11)),
              )).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      BroCardSheet.show(
                        context,
                        productName: product.name,
                        category: product.category.group,
                        region: product.region,
                      );
                    },
                    icon: const Icon(Icons.book, size: 16),
                    label: Text(l10n.addToJournal),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/pair');
                    },
                    icon: const Icon(Icons.restaurant_menu, size: 16),
                    label: Text(l10n.findPairingsButton),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _BrosPickCard extends StatelessWidget {
  const _BrosPickCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.thunder, colors.paprikaDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.brosPick, size: 12, color: colors.gold),
                      const SizedBox(width: 4),
                      Text(l10n.brosPick,
                    style: TextStyle(
                      color: colors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${product.subcategory} · ${product.region}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.tastingNotes,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

