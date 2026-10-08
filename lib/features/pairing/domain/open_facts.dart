/// Facts about a product taken from open datasets (X-Wines, Open Food
/// Facts, Wikidata, Wikimedia Commons, BJCP). Written to Firestore
/// `products/{id}.openData` by functions/scripts/enrich-open-data.js.
///
/// Every fact keeps the name of its source so the UI can show where it
/// came from. Nothing here overrides our own hand-authored fields.
class OpenPhoto {
  const OpenPhoto({
    required this.imageUrl,
    required this.credit,
    this.pageUrl,
  });

  final String imageUrl;

  /// Attribution line required by the image licence, e.g.
  /// "DYVER · CC BY-SA 4.0 · Wikimedia Commons".
  final String credit;
  final String? pageUrl;
}

enum FactAgreement { matchesOurs, differs }

class OpenFact {
  const OpenFact({
    required this.kind,
    required this.value,
    required this.source,
    this.agreement,
    this.chips = const [],
  });

  final OpenFactKind kind;
  final String value;
  final String source;
  final FactAgreement? agreement;

  /// List values (e.g. food types a wine is often paired with).
  final List<String> chips;
}

enum OpenFactKind { alcohol, producer, brand, beerStyle, pairsWith }

class OpenFacts {
  const OpenFacts({this.photo, this.facts = const []});

  /// Reads `openData` as stored in Firestore. [ourAbv] is our own ABV,
  /// used to say whether the open sources agree with it.
  factory OpenFacts.fromOpenData(
    Map<String, dynamic>? openData, {
    double? ourAbv,
  }) {
    if (openData == null || openData.isEmpty) return const OpenFacts();
    Map<String, dynamic>? sub(Map<String, dynamic>? m, String key) =>
        m?[key] is Map ? Map<String, dynamic>.from(m![key] as Map) : null;

    final xwines = sub(openData, 'xwines');
    final off = sub(openData, 'openFoodFacts');
    final wikidata = sub(openData, 'wikidata');
    final bjcp = sub(openData, 'bjcpStyle');
    final bottle = sub(openData, 'bottlePhoto');
    final facts = <OpenFact>[];

    // Alcohol: every open value next to ours.
    final abvs = <(String, double)>[
      if (xwines?['abv'] is num) ('X-Wines', (xwines!['abv'] as num).toDouble()),
      if (off?['abv'] is num) ('Open Food Facts', (off!['abv'] as num).toDouble()),
      if (sub(wikidata, 'product')?['abv'] is num)
        ('Wikidata', (sub(wikidata, 'product')!['abv'] as num).toDouble()),
    ];
    if (abvs.isNotEmpty) {
      String pct(double v) => '${v % 1 == 0 ? v.toInt() : v}%';
      final differing = ourAbv == null
          ? <(String, double)>[]
          : abvs.where((a) => (a.$2 - ourAbv).abs() >= 0.5).toList();
      final sources = abvs.map((a) => a.$1).toSet().join(', ');
      if (ourAbv != null && differing.isNotEmpty) {
        facts.add(OpenFact(
          kind: OpenFactKind.alcohol,
          value: [
            '${pct(ourAbv)} ours',
            for (final d in differing) '${pct(d.$2)} ${d.$1}',
          ].join(' · '),
          source: sources,
          agreement: FactAgreement.differs,
        ));
      } else {
        facts.add(OpenFact(
          kind: OpenFactKind.alcohol,
          value: pct(abvs.first.$2),
          source: sources,
          agreement: ourAbv == null ? null : FactAgreement.matchesOurs,
        ));
      }
    }

    // Producer (or brand when only the product itself is on Wikidata).
    String describe(Map<String, dynamic> e) => [
          e['name'],
          e['country'],
          if (e['founded'] is num) 'since ${e['founded']}',
        ].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final producer = sub(wikidata, 'producer');
    final brand = sub(wikidata, 'product');
    if (producer != null) {
      facts.add(OpenFact(
        kind: OpenFactKind.producer,
        value: describe(producer),
        source: 'Wikidata (CC0)',
      ));
    } else if (brand != null && brand['founded'] is num) {
      facts.add(OpenFact(
        kind: OpenFactKind.brand,
        value: describe(brand),
        source: 'Wikidata (CC0)',
      ));
    }

    if (bjcp != null) {
      String range(Object? r, String unit) {
        if (r is! Map) return '';
        final min = r['min'], max = r['max'];
        return min is num && max is num ? '$min–$max$unit' : '';
      }

      facts.add(OpenFact(
        kind: OpenFactKind.beerStyle,
        value: [
          '${bjcp['name']} (BJCP ${bjcp['styleId']})',
          range(bjcp['abv'], '% ABV'),
          range(bjcp['ibu'], ' IBU'),
        ].where((s) => s.isNotEmpty).join(' · '),
        source: 'BJCP 2021 names this beer as an example',
      ));
    }

    final pairs = (xwines?['pairsWith'] as List?)?.whereType<String>().toList();
    if (pairs != null && pairs.isNotEmpty) {
      facts.add(OpenFact(
        kind: OpenFactKind.pairsWith,
        value: '',
        chips: pairs,
        source: 'X-Wines (CC0), general food types',
      ));
    }

    // Photo: a Commons bottle photo first, else the Open Food Facts one.
    OpenPhoto? photo;
    if (bottle?['imageUrl'] is String) {
      photo = OpenPhoto(
        imageUrl: bottle!['imageUrl'] as String,
        pageUrl: bottle['pageUrl'] as String?,
        credit: [
          bottle['author'],
          bottle['licence'],
          bottle['source'] ?? 'Wikimedia Commons',
        ].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
      );
    } else if (off?['imageUrl'] is String) {
      photo = OpenPhoto(
        imageUrl: off!['imageUrl'] as String,
        pageUrl: off['url'] as String?,
        credit: 'Open Food Facts contributors · '
            '${off['imageLicence'] ?? 'CC BY-SA 3.0'}',
      );
    }

    return OpenFacts(photo: photo, facts: facts);
  }

  final OpenPhoto? photo;
  final List<OpenFact> facts;

  bool get isEmpty => photo == null && facts.isEmpty;
}
