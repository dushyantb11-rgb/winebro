import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/journal/domain/journal_context.dart';

/// Horizontal scroller of context chips used by Quick-log + BroCard.
/// Single-select; tapping the active one clears the selection so the
/// user can opt out without an explicit "none" tile.
class OccasionChips extends StatelessWidget {
  const OccasionChips({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final JournalContext? selected;
  final void Function(JournalContext?) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final ctx in JournalContext.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _ContextChip(
                ctx: ctx,
                active: selected == ctx,
                colors: colors,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(selected == ctx ? null : ctx);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({
    required this.ctx,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final JournalContext ctx;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = _labelFor(context, ctx);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? colors.paprika : colors.surface1,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? colors.paprika : colors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ctx.icon,
              size: 16,
              color: active ? colors.inkOnHero : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? colors.inkOnHero : colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _labelFor(BuildContext context, JournalContext c) {
    final l10n = context.l10n;
    return switch (c) {
      JournalContext.home => l10n.contextHome,
      JournalContext.restaurant => l10n.contextRestaurant,
      JournalContext.bar => l10n.contextBar,
      JournalContext.party => l10n.contextParty,
      JournalContext.travel => l10n.contextTravel,
      JournalContext.other => l10n.contextOther,
    };
  }
}
