import 'package:flutter/material.dart';
import 'package:winebro/core/brand/brand_identity.dart';
import 'package:winebro/shared/widgets/bottle_silhouette.dart';

/// Stylized brand-color label card. Renders a bottle silhouette in
/// the brand's accent color behind a bold serif label. This is the
/// commercial-grade interim replacement for the Material icon
/// placeholder used across all product cards until real
/// photography lands.
///
/// Sizes:
///   `tile`   — 56-72px square (search rows, alternates list)
///   `card`   — full hero (Tonight's Pour, Pair top result)
///   `compact` — 44px (Wishlist row, Bro Circle scroller)
enum BrandLabelSize {
  compact,
  tile,
  card,
}

class BrandLabelCard extends StatelessWidget {
  const BrandLabelCard({
    required this.productId,
    required this.productName,
    required this.category,
    this.size = BrandLabelSize.tile,
    this.showTagline = false,
    super.key,
  });

  final String productId;
  final String productName;
  final String category;
  final BrandLabelSize size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final brand = BrandRegistry.forProduct(
      productId: productId,
      category: category,
    );
    final shape = bottleShapeForCategory(category);

    final dim = switch (size) {
      BrandLabelSize.compact => const _CardDims(
          cardWidth: 56, cardHeight: 72, bottleSize: 36,
          fontSize: 9, taglineSize: 0, padding: 4,
        ),
      BrandLabelSize.tile => const _CardDims(
          cardWidth: 92, cardHeight: 124, bottleSize: 52,
          fontSize: 12, taglineSize: 9, padding: 8,
        ),
      BrandLabelSize.card => const _CardDims(
          cardWidth: double.infinity, cardHeight: 220, bottleSize: 100,
          fontSize: 22, taglineSize: 12, padding: 18,
        ),
    };

    return Container(
      width: dim.cardWidth,
      height: dim.cardHeight,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: brand.primary,
        borderRadius:
            BorderRadius.circular(size == BrandLabelSize.card ? 22 : 12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Accent stripe at the top — looks like a real label band.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size == BrandLabelSize.compact ? 5 : 8,
              color: brand.accent,
            ),
          ),
          // Bottle silhouette, low-opacity, behind the label.
          Positioned.fill(
            child: Align(
              alignment: size == BrandLabelSize.card
                  ? Alignment.centerRight
                  : Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  right: size == BrandLabelSize.card ? 18 : 0,
                  bottom: size == BrandLabelSize.card ? 0 : 4,
                ),
                child: Opacity(
                  opacity: size == BrandLabelSize.compact ? 0.18 : 0.22,
                  child: BottleSilhouette(
                    shape: shape,
                    fill: brand.accent,
                    size: dim.bottleSize,
                  ),
                ),
              ),
            ),
          ),
          // Brand label text
          Padding(
            padding: EdgeInsets.all(dim.padding.toDouble()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: size == BrandLabelSize.card
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (size != BrandLabelSize.compact)
                  const SizedBox(height: 2),
                Text(
                  brand.label,
                  style: TextStyle(
                    fontFamily: brand.fontFamily,
                    fontSize: dim.fontSize.toDouble(),
                    fontWeight: brand.serifWeight,
                    color: brand.ink,
                    letterSpacing: size == BrandLabelSize.compact ? 0.5 : 1.5,
                    height: 1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showTagline &&
                    brand.tagline != null &&
                    size != BrandLabelSize.compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    brand.tagline!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: dim.taglineSize.toDouble(),
                      fontStyle: FontStyle.italic,
                      color: brand.ink.withValues(alpha: 0.78),
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDims {
  const _CardDims({
    required this.cardWidth,
    required this.cardHeight,
    required this.bottleSize,
    required this.fontSize,
    required this.taglineSize,
    required this.padding,
  });

  final double cardWidth;
  final double cardHeight;
  final double bottleSize;
  final num fontSize;
  final num taglineSize;
  final num padding;
}
