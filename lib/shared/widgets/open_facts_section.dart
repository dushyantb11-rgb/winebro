import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:winebro/core/l10n/l10n_extension.dart';
import 'package:winebro/core/theme/app_colors.dart';
import 'package:winebro/features/home/presentation/providers/home_providers.dart';
import 'package:winebro/features/pairing/domain/open_facts.dart';
import 'package:winebro/features/pairing/domain/product.dart';

/// Openly licensed product photo with its required credit line.
/// Tapping it opens the full image. Renders nothing if the image fails.
class OpenPhotoHeader extends StatelessWidget {
  const OpenPhotoHeader({required this.photo, super.key});
  final OpenPhoto photo;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final credit = context.l10n.productPhotoCredit(photo.credit);
    return Semantics(
      button: true,
      image: true,
      label: credit,
      child: GestureDetector(
        onTap: () => _openFullImage(context, photo),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.inkOnHero,
                                ),
                              ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.scrim,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.open_in_full,
                                size: 16, color: colors.inkOnHero),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _CreditBar(text: credit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreditBar extends StatelessWidget {
  const _CreditBar({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.scrim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            color: colors.inkOnHero.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

void _openFullImage(BuildContext context, OpenPhoto photo) {
  HapticFeedback.selectionClick();
  showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (dialogContext) {
      final colors = dialogContext.appColors;
      return Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      photo.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image_outlined,
                        color: colors.inkOnHero,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(Icons.close, color: colors.inkOnHero, size: 28),
                  tooltip: MaterialLocalizations.of(dialogContext)
                      .closeButtonTooltip,
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CreditBar(
                  text: dialogContext.l10n.productPhotoCredit(photo.credit),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// "Facts from open sources" box. Each row names its source; a tag says
/// whether the open value agrees with ours.
class OpenFactsSection extends StatelessWidget {
  const OpenFactsSection({required this.facts, super.key});
  final List<OpenFact> facts;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    String label(OpenFactKind k) => switch (k) {
          OpenFactKind.alcohol => l10n.productOpenFactAlcohol,
          OpenFactKind.producer => l10n.productOpenFactProducer,
          OpenFactKind.brand => l10n.productOpenFactBrand,
          OpenFactKind.beerStyle => l10n.productOpenFactBeerStyle,
          OpenFactKind.pairsWith => l10n.productOpenFactPairsWith,
        };

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productOpenFactsTitle,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: context.paprikaOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < facts.length; i++)
            _FactRow(
              label: label(facts[i].kind),
              fact: facts[i],
              showDivider: i > 0,
            ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.label,
    required this.fact,
    required this.showDivider,
  });
  final String label;
  final OpenFact fact;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: colors.borderDefault))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: colors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fact.value.isNotEmpty)
                  Text(
                    fact.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                if (fact.chips.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in fact.chips)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: colors.borderDefault),
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                if (fact.agreement != null) ...[
                  const SizedBox(height: 4),
                  _AgreementTag(agreement: fact.agreement!),
                ],
                const SizedBox(height: 3),
                Text(
                  fact.source,
                  style: TextStyle(fontSize: 10.5, color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementTag extends StatelessWidget {
  const _AgreementTag({required this.agreement});
  final FactAgreement agreement;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final matches = agreement == FactAgreement.matchesOurs;
    // Icon carries the colour; text stays on a text token so it is
    // readable in both themes.
    final accent = matches ? context.salemOnSurface : colors.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          matches ? Icons.check_circle : Icons.error_outline,
          size: 13,
          color: accent,
        ),
        const SizedBox(width: 4),
        Text(
          matches
              ? context.l10n.productOpenFactMatches
              : context.l10n.productOpenFactDiffers,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Honest label on our own hand-authored content.
class OwnContentNote extends StatelessWidget {
  const OwnContentNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${context.l10n.productOwnContentLabel} ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.textSecondary,
            ),
          ),
          TextSpan(text: context.l10n.productOwnContentNote),
        ],
      ),
      style: TextStyle(fontSize: 11.5, color: colors.textTertiary),
    );
  }
}

/// Real Bro Circle line for one drink, from `community_signals` (CF-11).
/// Shows nothing until at least one bro logged the drink this week.
class ProductBroCircleLine extends ConsumerWidget {
  const ProductBroCircleLine({required this.product, super.key});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signals = ref.watch(communitySignalsProvider).valueOrNull;
    final signal =
        signals?.where((s) => s.productId == product.id).firstOrNull;
    if (signal == null || signal.tastersThisWeek <= 0) {
      return const SizedBox.shrink();
    }
    final colors = context.appColors;
    final l10n = context.l10n;
    final topPairing = signal.topPairing;
    final lines = [
      l10n.productBroCircleTasters(signal.tastersThisWeek),
      if (topPairing != null &&
          topPairing.isNotEmpty &&
          signal.topPairingShare > 0)
        l10n.productBroCircleTopPairing(
          topPairing,
          (signal.topPairingShare * 100).round(),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: context.salemOnSurface, width: 3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline, size: 18, color: context.salemOnSurface),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lines.join('\n'),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
