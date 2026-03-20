import 'package:flutter/material.dart';
import 'package:winebro/core/theme/app_colors.dart';


class StarRating extends StatelessWidget {
  const StarRating({
    required this.rating,
    this.size = 16,
    this.onChanged,
    super.key,
  });

  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: colors.gold,
          size: size,
        );

        if (onChanged != null) {
          return GestureDetector(
            onTap: () => onChanged!(i + 1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: icon,
            ),
          );
        }

        return icon;
      }),
    );
  }
}
