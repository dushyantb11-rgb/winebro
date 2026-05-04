import 'package:flutter/material.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';

/// Full-bleed cinematic card. Background is either a photo (when
/// [imageUrl] is provided) or a paprika→thunder gradient (fallback
/// before the photography pipeline lands real bottle imagery).
///
/// Always renders a scrim so light text reads, regardless of image
/// brightness. Content sits in [child] at the bottom by default;
/// pass [contentAlignment] to override.
class HeroPhotoCard extends StatelessWidget {
  const HeroPhotoCard({
    required this.child,
    this.imageUrl,
    this.aspectRatio = 16 / 11,
    this.borderRadius = 24,
    this.contentAlignment = Alignment.bottomLeft,
    this.gradientColors,
    this.onTap,
    super.key,
  });

  final Widget child;
  final String? imageUrl;
  final double aspectRatio;
  final double borderRadius;
  final Alignment contentAlignment;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: AppElevation.eHero(dark: isDark),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background — image or gradient fallback
                if (imageUrl != null)
                  Image.asset(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _gradient(colors),
                  )
                else
                  _gradient(colors),
                // Scrim
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        colors.scrim,
                      ],
                      stops: const [0, 0.35, 1],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: contentAlignment,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradient(AppColors colors) {
    final fallback = gradientColors ??
        [colors.thunder, colors.paprikaDark, colors.paprikaDeep];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: fallback,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
