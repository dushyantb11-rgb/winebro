import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/pairing/data/seed_products.dart';
import 'package:winebro/features/pairing/domain/product.dart';

/// Pre-quiz seed — "Which of these have you tried?"
///
/// Sits between OnboardingIntro and Quiz. Shows 6 anchor products
/// spanning category + style range. Multi-select. The selections
/// write to `users/{uid}/pre_quiz_seed/initial` so:
///   1. The quiz engine can warm-start with non-zero priors
///   2. We get D8 "Discovery sequences" data from session 0
///   3. New users feel the app already knows them
///
/// Skippable — that lands the user straight into the standard
/// 7-question quiz with empty priors, same as today.
class PreQuizSeedScreen extends StatefulWidget {
  const PreQuizSeedScreen({super.key});

  @override
  State<PreQuizSeedScreen> createState() => _PreQuizSeedScreenState();
}

class _PreQuizSeedScreenState extends State<PreQuizSeedScreen> {
  final _selected = <String>{};
  bool _saving = false;

  /// Hand-picked anchors — one from each broad style cluster so the
  /// selection is genuinely informative rather than redundant. Only
  /// 6 because UX testing of the original onboarding said cards >7
  /// caused users to bail back to the quiz route.
  static const _anchorIds = <String>[
    'sula-sauvignon-blanc',
    'sula-shiraz',
    'grover-zampa-la-reserve',
    'fratelli-sette',
    'krsma-cabernet-sauvignon',
    'fratelli-tilt-rose',
  ];

  List<Product> get _anchors {
    return _anchorIds
        .map((id) => kSeedProducts.firstWhere(
              (p) => p.id == id,
              orElse: () => kSeedProducts.first,
            ))
        .toList();
  }

  Future<void> _continue({required bool persist}) async {
    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    if (persist && _selected.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('pre_quiz_seed')
              .doc('initial')
              .set({
            'productIds': _selected.toList(),
            'completedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          // Silent — pre-quiz seed is best-effort, never block quiz.
        }
      }
    }

    if (!mounted) return;
    context.go('/quiz');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.charcoal,
      appBar: AppBar(
        backgroundColor: colors.charcoal,
        elevation: 0,
        leading: const SizedBox(),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _continue(persist: false),
            child: Text(
              l10n.preQuizSkip,
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.preQuizEyebrow,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.preQuizHeadline,
                    style: TextStyle(
                      fontFamily: 'PlayfairDisplay',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.preQuizSubhead,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _anchors.length,
                itemBuilder: (_, i) {
                  final product = _anchors[i];
                  final active = _selected.contains(product.id);
                  return _AnchorCard(
                    product: product,
                    active: active,
                    colors: colors,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (active) {
                          _selected.remove(product.id);
                        } else {
                          _selected.add(product.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _continue(persist: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.paprika,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _selected.isEmpty
                        ? l10n.preQuizContinueEmpty
                        : l10n.preQuizContinueWithCount(_selected.length),
                    style: TextStyle(
                      color: colors.inkOnHero,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnchorCard extends StatelessWidget {
  const _AnchorCard({
    required this.product,
    required this.active,
    required this.colors,
    required this.onTap,
  });

  final Product product;
  final bool active;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? colors.paprika : colors.borderSubtle,
            width: active ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  active ? Icons.check_circle : Icons.circle_outlined,
                  color: active ? colors.paprika : colors.textTertiary,
                  size: 20,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surface2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    product.subcategory,
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              product.name,
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              product.region,
              style: TextStyle(
                color: colors.textTertiary,
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
