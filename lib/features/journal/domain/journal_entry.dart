
enum NoseIntensity {
  light, medium, pronounced;

  static NoseIntensity? fromDisplay(String? s) {
    if (s == null) return null;
    return NoseIntensity.values.firstWhere(
      (e) => e.name == s.toLowerCase(),
      orElse: () => NoseIntensity.medium,
    );
  }
}

enum Sweetness {
  dry, offDry, medium, sweet, luscious;

  static Sweetness? fromDisplay(String? s) {
    if (s == null) return null;
    final normalized = s.toLowerCase().replaceAll('-', '');
    return Sweetness.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => Sweetness.medium,
    );
  }
}

enum AcidityLevel {
  low, medium, high;

  static AcidityLevel? fromDisplay(String? s) {
    if (s == null) return null;
    return AcidityLevel.values.firstWhere(
      (e) => e.name == s.toLowerCase(),
      orElse: () => AcidityLevel.medium,
    );
  }
}

enum TanninLevel {
  low, medium, high;

  static TanninLevel? fromDisplay(String? s) {
    if (s == null) return null;
    return TanninLevel.values.firstWhere(
      (e) => e.name == s.toLowerCase(),
      orElse: () => TanninLevel.medium,
    );
  }
}

enum BodyLevel {
  light, medium, full;

  static BodyLevel? fromDisplay(String? s) {
    if (s == null) return null;
    return BodyLevel.values.firstWhere(
      (e) => e.name == s.toLowerCase(),
      orElse: () => BodyLevel.medium,
    );
  }
}

enum FinishLength {
  short, medium, long;

  static FinishLength? fromDisplay(String? s) {
    if (s == null) return null;
    return FinishLength.values.firstWhere(
      (e) => e.name == s.toLowerCase(),
      orElse: () => FinishLength.medium,
    );
  }
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.category,
    required this.region,
    required this.rating,
    required this.createdAt,
    this.appearance,
    this.noseIntensity,
    this.noseAromas = const [],
    this.palateSweetness,
    this.palateAcidity,
    this.palateTannin,
    this.palateBody,
    this.finishLength,
    this.notes,
    this.foodPaired,
    this.pairingRating,
    this.occasion,
    this.isFavorite = false,
    this.isWishlist = false,
    this.buyAgain = false,
    this.bottlePhotoUrl,
    this.labelPhotoUrl,
  });

  final String id;
  final String userId;
  final String productId;
  final String productName;
  final String category;
  final String region;
  final int rating;
  final DateTime createdAt;

  final AppearanceData? appearance;
  final NoseIntensity? noseIntensity;
  final List<String> noseAromas;
  final Sweetness? palateSweetness;
  final AcidityLevel? palateAcidity;
  final TanninLevel? palateTannin;
  final BodyLevel? palateBody;
  final FinishLength? finishLength;
  final String? notes;
  final String? foodPaired;
  final int? pairingRating;
  final String? occasion;
  final bool isFavorite;
  final bool isWishlist;
  final bool buyAgain;
  final String? bottlePhotoUrl;
  final String? labelPhotoUrl;

  bool get isDetailed =>
      appearance != null ||
      noseAromas.isNotEmpty ||
      palateSweetness != null;

  static const _sentinel = Object();

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? productId,
    String? productName,
    String? category,
    String? region,
    int? rating,
    DateTime? createdAt,
    AppearanceData? appearance,
    Object? noseIntensity = _sentinel,
    List<String>? noseAromas,
    Object? palateSweetness = _sentinel,
    Object? palateAcidity = _sentinel,
    Object? palateTannin = _sentinel,
    Object? palateBody = _sentinel,
    Object? finishLength = _sentinel,
    String? notes,
    String? foodPaired,
    int? pairingRating,
    String? occasion,
    bool? isFavorite,
    bool? isWishlist,
    bool? buyAgain,
    String? bottlePhotoUrl,
    String? labelPhotoUrl,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      region: region ?? this.region,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      appearance: appearance ?? this.appearance,
      noseIntensity: identical(noseIntensity, _sentinel)
          ? this.noseIntensity
          : noseIntensity as NoseIntensity?,
      noseAromas: noseAromas ?? this.noseAromas,
      palateSweetness: identical(palateSweetness, _sentinel)
          ? this.palateSweetness
          : palateSweetness as Sweetness?,
      palateAcidity: identical(palateAcidity, _sentinel)
          ? this.palateAcidity
          : palateAcidity as AcidityLevel?,
      palateTannin: identical(palateTannin, _sentinel)
          ? this.palateTannin
          : palateTannin as TanninLevel?,
      palateBody: identical(palateBody, _sentinel)
          ? this.palateBody
          : palateBody as BodyLevel?,
      finishLength: identical(finishLength, _sentinel)
          ? this.finishLength
          : finishLength as FinishLength?,
      notes: notes ?? this.notes,
      foodPaired: foodPaired ?? this.foodPaired,
      pairingRating: pairingRating ?? this.pairingRating,
      occasion: occasion ?? this.occasion,
      isFavorite: isFavorite ?? this.isFavorite,
      isWishlist: isWishlist ?? this.isWishlist,
      buyAgain: buyAgain ?? this.buyAgain,
      bottlePhotoUrl: bottlePhotoUrl ?? this.bottlePhotoUrl,
      labelPhotoUrl: labelPhotoUrl ?? this.labelPhotoUrl,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'productId': productId,
    'productName': productName,
    'category': category,
    'region': region,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
    if (appearance != null) 'appearance': appearance!.toMap(),
    if (noseIntensity != null) 'noseIntensity': noseIntensity!.name,
    if (noseAromas.isNotEmpty) 'noseAromas': noseAromas,
    if (palateSweetness != null) 'palateSweetness': palateSweetness!.name,
    if (palateAcidity != null) 'palateAcidity': palateAcidity!.name,
    if (palateTannin != null) 'palateTannin': palateTannin!.name,
    if (palateBody != null) 'palateBody': palateBody!.name,
    if (finishLength != null) 'finishLength': finishLength!.name,
    if (notes != null) 'notes': notes,
    if (foodPaired != null) 'foodPaired': foodPaired,
    if (pairingRating != null) 'pairingRating': pairingRating,
    if (occasion != null) 'occasion': occasion,
    'isFavorite': isFavorite,
    'isWishlist': isWishlist,
    'buyAgain': buyAgain,
    if (bottlePhotoUrl != null) 'bottlePhotoUrl': bottlePhotoUrl,
    if (labelPhotoUrl != null) 'labelPhotoUrl': labelPhotoUrl,
  };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
    id: map['id'] as String,
    userId: map['userId'] as String,
    productId: map['productId'] as String,
    productName: map['productName'] as String,
    category: map['category'] as String,
    region: map['region'] as String,
    rating: map['rating'] as int,
    createdAt: DateTime.parse(map['createdAt'] as String),
    appearance: map['appearance'] != null
        ? AppearanceData.fromMap(map['appearance'] as Map<String, dynamic>)
        : null,
    noseIntensity: map['noseIntensity'] != null
        ? NoseIntensity.values.firstWhere(
            (e) => e.name == map['noseIntensity'],
            orElse: () => NoseIntensity.medium,
          )
        : null,
    noseAromas: map['noseAromas'] != null
        ? List<String>.from(map['noseAromas'] as List)
        : const [],
    palateSweetness: map['palateSweetness'] != null
        ? Sweetness.values.firstWhere(
            (e) => e.name == map['palateSweetness'],
            orElse: () => Sweetness.medium,
          )
        : null,
    palateAcidity: map['palateAcidity'] != null
        ? AcidityLevel.values.firstWhere(
            (e) => e.name == map['palateAcidity'],
            orElse: () => AcidityLevel.medium,
          )
        : null,
    palateTannin: map['palateTannin'] != null
        ? TanninLevel.values.firstWhere(
            (e) => e.name == map['palateTannin'],
            orElse: () => TanninLevel.medium,
          )
        : null,
    palateBody: map['palateBody'] != null
        ? BodyLevel.values.firstWhere(
            (e) => e.name == map['palateBody'],
            orElse: () => BodyLevel.medium,
          )
        : null,
    finishLength: map['finishLength'] != null
        ? FinishLength.values.firstWhere(
            (e) => e.name == map['finishLength'],
            orElse: () => FinishLength.medium,
          )
        : null,
    notes: map['notes'] as String?,
    foodPaired: map['foodPaired'] as String?,
    pairingRating: map['pairingRating'] as int?,
    occasion: map['occasion'] as String?,
    isFavorite: map['isFavorite'] as bool? ?? false,
    isWishlist: map['isWishlist'] as bool? ?? false,
    buyAgain: map['buyAgain'] as bool? ?? false,
    bottlePhotoUrl: map['bottlePhotoUrl'] as String?,
    labelPhotoUrl: map['labelPhotoUrl'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is JournalEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}


class AppearanceData {
  const AppearanceData({
    required this.colour,
    required this.clarity,
    required this.intensity,
  });

  final String colour;
  final String clarity;
  final String intensity;

  Map<String, dynamic> toMap() => {
    'colour': colour,
    'clarity': clarity,
    'intensity': intensity,
  };

  factory AppearanceData.fromMap(Map<String, dynamic> map) => AppearanceData(
    colour: map['colour'] as String,
    clarity: map['clarity'] as String,
    intensity: map['intensity'] as String,
  );
}
