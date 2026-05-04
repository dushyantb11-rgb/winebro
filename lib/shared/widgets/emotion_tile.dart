import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/core/theme/app_elevation.dart';

/// 2:3 portrait card for the "What are you doing tonight?" trio.
/// Replaces the old 4-icon QuickActions row with three larger,
/// emotion-led tiles (Cooking / Hosting / Just sipping).
class EmotionTile extends StatelessWidget {
  const EmotionTile({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppElevation.e2(dark: isDark),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Decorative big icon top-right, faded
                Positioned(
                  top: -10,
                  right: -10,
                  child: Icon(
                    icon,
                    size: 100,
                    color: colors.inkOnHero.withValues(alpha: 0.12),
                  ),
                ),
                // Bottom-left label
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: colors.inkOnHero, size: 20),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colors.inkOnHero,
                          letterSpacing: -0.5,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
