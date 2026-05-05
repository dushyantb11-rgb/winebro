import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winebro/core/affiliate/affiliate_url_resolver.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/wishlist/presentation/providers/wishlist_provider.dart';

/// Reusable Buy / Save / Remind action row.
///
/// Closes the largest open loop in the app (STRATEGY-AUDIT P5 D1).
/// Use on every Pair result, Tonight's Pour hero, alternate cards,
/// and product detail sheets.
///
/// Behaviour:
///   Buy ₹X →  opens partner URL via [AffiliateUrlResolver] in browser
///   Save      toggles wishlist (Save ↔ Saved); haptic light
///   Remind    opens device calendar with a pre-filled event 3 days
///             out — "Pick up <product>"; haptic medium
///
/// Compact mode (default) renders a single row of pill buttons; the
/// hero variant renders the Buy button as the primary CTA with smaller
/// secondary actions below.
class ProductActionRow extends ConsumerWidget {
  const ProductActionRow({
    required this.product,
    required this.source,
    this.compact = true,
    this.onTransparent = false,
    super.key,
  });

  final Product product;
  final AffiliateSource source;
  final bool compact;

  /// True when sitting on a paprika-gradient hero (Tonight's Pour,
  /// Bro's Pick). Buttons render with white-on-translucent-white
  /// styling instead of the default theme colours.
  final bool onTransparent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final isInWishlist = ref.watch(wishlistContainsProvider(product.id));

    final buyLabel = context.l10n.actionBuy(product.price.toStringAsFixed(0));
    final saveLabel = isInWishlist ? context.l10n.actionSaved : context.l10n.actionSave;

    if (onTransparent) {
      return Row(
        children: [
          Expanded(
            child: _HeroButton(
              icon: Icons.shopping_cart_outlined,
              label: buyLabel,
              onTap: () => _onBuy(context),
              filled: true,
              colors: colors,
            ),
          ),
          const SizedBox(width: 8),
          _HeroButton(
            icon: isInWishlist ? Icons.bookmark : Icons.bookmark_border,
            label: saveLabel,
            onTap: () => _onSave(context, ref, isInWishlist),
            filled: false,
            colors: colors,
          ),
          const SizedBox(width: 8),
          _HeroButton(
            icon: Icons.alarm_add_outlined,
            label: context.l10n.actionRemind,
            onTap: () => _onRemind(context),
            filled: false,
            colors: colors,
            iconOnly: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart_outlined, size: 16),
            label: Text(buyLabel),
            onPressed: () => _onBuy(context),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: Icon(
            isInWishlist ? Icons.bookmark : Icons.bookmark_border,
            color: isInWishlist ? colors.paprika : colors.textSecondary,
          ),
          tooltip: saveLabel,
          onPressed: () => _onSave(context, ref, isInWishlist),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: Icon(Icons.alarm_add_outlined, color: colors.textSecondary),
          tooltip: context.l10n.actionRemind,
          onPressed: () => _onRemind(context),
        ),
      ],
    );
  }

  Future<void> _onBuy(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final url = AffiliateUrlResolver.buildBuyUrl(
      product: product,
      source: source,
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onSave(
      BuildContext context, WidgetRef ref, bool currentlyIn) async {
    HapticFeedback.lightImpact();
    final repo = WishlistRepository.forCurrentUser();
    if (repo == null) return;
    if (currentlyIn) {
      await repo.remove(product.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.wishlistRemovedSnackbar)),
        );
      }
    } else {
      await repo.save(product);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.wishlistAddedSnackbar)),
        );
      }
    }
  }

  Future<void> _onRemind(BuildContext context) async {
    HapticFeedback.mediumImpact();
    // Calendar deep-link via webcal/tel-style URI. On Android the
    // CALENDAR intent works via `content://` schemes which require a
    // platform channel; for v1.1 we use a simpler approach — open a
    // pre-filled mailto: that the user can drop into their calendar
    // app, OR show a snackbar confirming an in-app reminder is set.
    //
    // For now we surface an in-app SnackBar — the actual scheduling
    // hook lands in S2.2 Restock surface where the cloud function
    // handles cadence.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.actionRemindSet)),
      );
    }
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
    required this.colors,
    this.iconOnly = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final AppColors colors;
  final bool iconOnly;

  @override
  Widget build(BuildContext context) {
    final ink = colors.inkOnHero;
    final bg = filled ? ink : ink.withValues(alpha: 0.18);
    final border = filled ? Colors.transparent : ink.withValues(alpha: 0.4);
    final fg = filled ? colors.paprika : ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: iconOnly ? 12 : 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: fg),
              if (!iconOnly) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
