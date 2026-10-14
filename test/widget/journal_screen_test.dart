import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/theme/app_theme.dart';
import 'package:winebro/features/journal/domain/journal_entry.dart';
import 'package:winebro/features/journal/presentation/screens/journal_screen.dart';
import 'package:winebro/l10n/generated/app_localizations.dart';

/// Entries exactly as Firestore holds them: a full BroCard entry and a
/// quick-log entry (no tasting fields).
final _entries = [
  JournalEntry.fromMap({
    'id': '1790072383643', 'userId': 'u1', 'productId': '1790072383643',
    'productName': 'Glenfiddich 12 Year Old', 'category': 'Whisky',
    'region': 'Speyside, Scotland', 'rating': 3,
    'createdAt': '2026-09-22T15:49:43.643071',
    'appearance': {'intensity': 'Medium', 'colour': 'Ruby', 'clarity': 'Clear'},
    'noseIntensity': 'medium', 'palateSweetness': 'dry', 'palateAcidity': 'medium',
    'palateTannin': 'medium', 'palateBody': 'medium', 'finishLength': 'medium',
    'isFavorite': false, 'isWishlist': false, 'buyAgain': false,
  }),
  JournalEntry.fromMap({
    'id': '1791000000000', 'userId': 'u1', 'productId': 'sula-shiraz',
    'productName': 'Sula Shiraz', 'category': 'Red Wine', 'region': '',
    'rating': 4, 'createdAt': '2026-10-14T10:20:30.123456',
    'occasion': 'dinner', 'isFavorite': false, 'isWishlist': false,
    'buyAgain': true,
  }),
];

void main() {
  test('JS-02: reader accepts Timestamp dates and missing fields', () {
    final e = JournalEntry.fromMap({
      'id': 'x1', 'productName': 'Old entry', 'rating': 4.0,
      'createdAt': Timestamp.fromMillisecondsSinceEpoch(1790000000000),
    });
    expect(e.rating, 4);
    expect(e.region, '');
    expect(e.productId, 'x1');
    expect(e.createdAt.year, 2026);
  });

  test('JS-03: Bro Tip rotates daily and is stable within a day', () {
    final home = HomeConfig.fromMap({
      'tips': [
        {'text': 'A'},
        {'text': 'B', 'note': 'n'},
        {'text': '  '},
      ],
    });
    expect(home.tips.length, 2);
    final d = DateTime(2026, 10, 14, 8);
    expect(home.tipFor(d)!.text, home.tipFor(DateTime(2026, 10, 14, 23))!.text);
    expect(home.tipFor(d)!.text, isNot(home.tipFor(DateTime(2026, 10, 15))!.text));
    expect(HomeConfig.fromMap(const {}).tipFor(d), isNull);
  });

  testWidgets('JS-01: journal list renders saved entries', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        journalEntriesProvider.overrideWith((ref) => Stream.value(_entries)),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const JournalScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sula Shiraz'), findsOneWidget);
  });
}
