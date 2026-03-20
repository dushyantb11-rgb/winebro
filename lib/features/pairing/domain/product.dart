import 'package:winebro/core/constants/pairing_constants.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.region,
    required this.price,
    required this.fruit,
    required this.acidity,
    required this.body,
    required this.tannin,
    required this.freshness,
    required this.complexity,
    required this.archetypeTags,
    required this.tastingNotes,
    required this.aromas,
    this.imageUrl,
    this.origin,
    this.abv,
    this.grapeVariety,
  })  : assert(fruit >= 0 && fruit <= 10),
        assert(acidity >= 0 && acidity <= 10),
        assert(body >= 0 && body <= 10),
        assert(tannin >= 0 && tannin <= 10),
        assert(freshness >= 0 && freshness <= 10),
        assert(complexity >= 0 && complexity <= 10);

  final String id;
  final String name;
  final DrinkCategory category;
  final String subcategory;
  final String region;
  final double price;
  final double fruit;
  final double acidity;
  final double body;
  final double tannin;
  final double freshness;
  final double complexity;
  final List<PalateArchetype> archetypeTags;
  final String tastingNotes;
  final List<String> aromas;
  final String? imageUrl;
  final String? origin;
  final double? abv;
  final String? grapeVariety;

  double operator [](PalateAxis axis) => switch (axis) {
    PalateAxis.fruit => fruit,
    PalateAxis.acidity => acidity,
    PalateAxis.body => body,
    PalateAxis.tannin => tannin,
    PalateAxis.freshness => freshness,
    PalateAxis.complexity => complexity,
  };

  List<double> get axisValues =>
      PalateAxis.values.map((a) => this[a]).toList();

  Product copyWith({
    String? id,
    String? name,
    DrinkCategory? category,
    String? subcategory,
    String? region,
    double? price,
    double? fruit,
    double? acidity,
    double? body,
    double? tannin,
    double? freshness,
    double? complexity,
    List<PalateArchetype>? archetypeTags,
    String? tastingNotes,
    List<String>? aromas,
    String? imageUrl,
    String? origin,
    double? abv,
    String? grapeVariety,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      region: region ?? this.region,
      price: price ?? this.price,
      fruit: fruit ?? this.fruit,
      acidity: acidity ?? this.acidity,
      body: body ?? this.body,
      tannin: tannin ?? this.tannin,
      freshness: freshness ?? this.freshness,
      complexity: complexity ?? this.complexity,
      archetypeTags: archetypeTags ?? this.archetypeTags,
      tastingNotes: tastingNotes ?? this.tastingNotes,
      aromas: aromas ?? this.aromas,
      imageUrl: imageUrl ?? this.imageUrl,
      origin: origin ?? this.origin,
      abv: abv ?? this.abv,
      grapeVariety: grapeVariety ?? this.grapeVariety,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'subcategory': subcategory,
      'region': region,
      'price': price,
      'fruit': fruit,
      'acidity': acidity,
      'body': body,
      'tannin': tannin,
      'freshness': freshness,
      'complexity': complexity,
      'archetypeTags': archetypeTags.map((a) => a.name).toList(),
      'tastingNotes': tastingNotes,
      'aromas': aromas,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (origin != null) 'origin': origin,
      if (abv != null) 'abv': abv,
      if (grapeVariety != null) 'grapeVariety': grapeVariety,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: DrinkCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => DrinkCategory.redWine,
      ),
      subcategory: map['subcategory'] as String,
      region: map['region'] as String,
      price: (map['price'] as num).toDouble(),
      fruit: (map['fruit'] as num).toDouble(),
      acidity: (map['acidity'] as num).toDouble(),
      body: (map['body'] as num).toDouble(),
      tannin: (map['tannin'] as num).toDouble(),
      freshness: (map['freshness'] as num).toDouble(),
      complexity: (map['complexity'] as num).toDouble(),
      archetypeTags: List.unmodifiable(
        (map['archetypeTags'] as List).map(
          (t) => PalateArchetype.values.firstWhere(
            (a) => a.name == t,
            orElse: () => PalateArchetype.values.first,
          ),
        ),
      ),
      tastingNotes: map['tastingNotes'] as String,
      aromas: List<String>.unmodifiable(map['aromas'] as List),
      imageUrl: map['imageUrl'] as String?,
      origin: map['origin'] as String?,
      abv: (map['abv'] as num?)?.toDouble(),
      grapeVariety: map['grapeVariety'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

