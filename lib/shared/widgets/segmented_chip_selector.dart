import 'package:flutter/material.dart';
import 'package:winebro/core/theme/app_colors.dart';


class SegmentedChipSelector extends StatelessWidget {
  const SegmentedChipSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options.map((opt) {
        final isActive = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? colors.paprika : colors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? colors.paprika : colors.borderDefault,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isActive ? Colors.white : colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
