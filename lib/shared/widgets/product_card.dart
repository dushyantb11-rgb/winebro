import 'package:flutter/material.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_icons.dart';
import 'package:winebro/features/pairing/domain/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    this.matchPercent,
    this.compact = false,
    this.onTap,
    super.key,
  });

  final Product product;
  final int? matchPercent;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (compact) {
      return _buildCompact(colors);
    }
    return _buildFull(colors);
  }

  Widget _buildCompact(AppColors colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 70,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _categoryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colors.surface2,
                        child: Icon(_categoryIcon, size: 28, color: colors.paprikaLight),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.subcategory,
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 10,
              ),
            ),
            const Spacer(),
            if (matchPercent != null)
              _MatchBadge(percent: matchPercent!, colors: colors),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(AppColors colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _categoryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colors.surface2,
                        child: Icon(_categoryIcon, size: 24, color: colors.paprikaLight),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.subcategory} · ${product.region}',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (matchPercent != null) ...[
              const SizedBox(width: 8),
              _MatchBadge(percent: matchPercent!, colors: colors),
            ],
          ],
        ),
      ),
    );
  }

  String get _categoryImage => AppIcons.drinkImage(product.category.group);
  IconData get _categoryIcon => AppIcons.forDrinkGroup(product.category.group);
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent, required this.colors});

  final int percent;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 80
        ? colors.salem
        : percent >= 60
            ? colors.gold
            : colors.paprika;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2.5),
      ),
      child: Center(
        child: Text(
          '$percent%',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

