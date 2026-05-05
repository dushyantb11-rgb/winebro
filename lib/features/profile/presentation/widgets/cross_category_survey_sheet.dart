import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';

/// Cross-category drink survey. Triggered from Profile after the
/// 3rd journal entry (or via a Settings entry-point). One screen,
/// 5 categories + Other, multi-select, ~10 seconds to complete.
///
/// D5 "Cross-category preference graph" — Year-1 target 5,000 users
/// with ≥3 categories declared. Powers brand-side B2B insights:
/// "62% of red-wine drinkers also tried craft beer" — the intel
/// nobody else has on the Indian market.
///
/// Persisted at `users/{uid}/cross_category/initial`.
class CrossCategorySurveySheet extends ConsumerStatefulWidget {
  const CrossCategorySurveySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CrossCategorySurveySheet(),
    );
  }

  @override
  ConsumerState<CrossCategorySurveySheet> createState() =>
      _CrossCategorySurveySheetState();
}

class _CrossCategorySurveySheetState
    extends ConsumerState<CrossCategorySurveySheet> {
  final _selected = <String>{};
  bool _saving = false;

  static const _categories = <({String code, IconData icon})>[
    (code: 'wine', icon: Icons.wine_bar),
    (code: 'whisky', icon: Icons.local_bar),
    (code: 'beer', icon: Icons.sports_bar),
    (code: 'cocktails', icon: Icons.local_drink),
    (code: 'gin_rum_vodka', icon: Icons.liquor),
    (code: 'non_alcoholic', icon: Icons.local_cafe),
  ];

  Future<void> _submit() async {
    if (_saving || _selected.isEmpty) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      Navigator.pop(context);
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cross_category')
          .doc('initial')
          .set({
        'categories': _selected.toList(),
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Silent — survey is best-effort.
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.crossCategoryThanks)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.charcoal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.crossCategoryEyebrow,
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.crossCategoryHeadline,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                letterSpacing: -0.5,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.crossCategorySubhead,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((c) {
                final active = _selected.contains(c.code);
                return _Chip(
                  label: _labelFor(context, c.code),
                  icon: c.icon,
                  active: active,
                  colors: colors,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (active) {
                        _selected.remove(c.code);
                      } else {
                        _selected.add(c.code);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected.isEmpty || _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.paprika,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n.crossCategorySubmit,
                        style: TextStyle(
                          color: colors.inkOnHero,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _labelFor(BuildContext context, String code) {
    final l10n = context.l10n;
    return switch (code) {
      'wine' => l10n.categoryWine,
      'whisky' => l10n.categoryWhisky,
      'beer' => l10n.categoryBeer,
      'cocktails' => l10n.categoryCocktails,
      'gin_rum_vodka' => l10n.categoryGinRumVodka,
      'non_alcoholic' => l10n.categoryNonAlcoholic,
      _ => code,
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? colors.paprika : colors.surface1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? colors.paprika : colors.borderSubtle,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? colors.inkOnHero : colors.textSecondary,
            ),
            const SizedBox(width: 8),
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
}
