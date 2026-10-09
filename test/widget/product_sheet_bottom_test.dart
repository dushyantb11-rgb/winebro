import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/core/affiliate/affiliate_url_resolver.dart';
import 'package:winebro/features/home/presentation/providers/home_providers.dart';
import 'package:winebro/features/pairing/domain/product.dart';
import 'package:winebro/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:winebro/l10n/generated/app_localizations.dart';
import 'package:winebro/shared/widgets/open_facts_section.dart';
import 'package:winebro/shared/widgets/product_action_row.dart';

/// A published pilot drink as stored in Firestore: no price, no region.
final _amrut = Product.fromMap({
  'id': 'amrut-indian-single-malt', 'name': 'Amrut Indian Single Malt Whisky',
  'category': 'whisky', 'subcategory': 'Whisky', 'region': '', 'price': 0,
  'fruit': 6, 'acidity': 3, 'body': 7, 'tannin': 4, 'freshness': 3, 'complexity': 7,
  'archetypeTags': <String>[], 'tastingNotes': 'Bold Indian single malt.',
  'aromas': ['malt', 'honey'], 'abv': 46.0,
  'estimate': {'confidence': 'medium'},
});

void main() {
  testWidgets('SB-01: product sheet bottom builds without errors', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        communitySignalsProvider.overrideWith((ref) => Stream.value(const [])),
        wishlistContainsProvider.overrideWith((ref, id) => false),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(children: [
            OwnContentNote(product: _amrut),
            const SizedBox(height: 20),
            ProductBroCircleLine(product: _amrut),
            ProductActionRow(product: _amrut, source: AffiliateSource.detail),
          ]),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Retail availability soon'), findsOneWidget);
  });
}
