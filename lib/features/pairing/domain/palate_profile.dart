import 'package:winebro/core/constants/pairing_constants.dart';

class PalateProfile {
  const PalateProfile({
    required this.fruit,
    required this.acidity,
    required this.body,
    required this.tannin,
    required this.freshness,
    required this.complexity,
    required this.archetype,
  });

  final double fruit;
  final double acidity;
  final double body;
  final double tannin;
  final double freshness;
  final double complexity;
  final PalateArchetype archetype;

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

  PalateProfile withOccasion(Occasion occasion) {
    final mods = occasion.axisModifiers;
    return PalateProfile(
      fruit: (fruit + (mods[PalateAxis.fruit] ?? 0)).clamp(kAxisMin, kAxisMax),
      acidity:
          (acidity + (mods[PalateAxis.acidity] ?? 0)).clamp(kAxisMin, kAxisMax),
      body: (body + (mods[PalateAxis.body] ?? 0)).clamp(kAxisMin, kAxisMax),
      tannin:
          (tannin + (mods[PalateAxis.tannin] ?? 0)).clamp(kAxisMin, kAxisMax),
      freshness: (freshness + (mods[PalateAxis.freshness] ?? 0))
          .clamp(kAxisMin, kAxisMax),
      complexity: (complexity + (mods[PalateAxis.complexity] ?? 0))
          .clamp(kAxisMin, kAxisMax),
      archetype: archetype,
    );
  }

  PalateProfile copyWith({
    double? fruit,
    double? acidity,
    double? body,
    double? tannin,
    double? freshness,
    double? complexity,
    PalateArchetype? archetype,
  }) {
    return PalateProfile(
      fruit: fruit ?? this.fruit,
      acidity: acidity ?? this.acidity,
      body: body ?? this.body,
      tannin: tannin ?? this.tannin,
      freshness: freshness ?? this.freshness,
      complexity: complexity ?? this.complexity,
      archetype: archetype ?? this.archetype,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fruit': fruit,
      'acidity': acidity,
      'body': body,
      'tannin': tannin,
      'freshness': freshness,
      'complexity': complexity,
      'archetype': archetype.name,
    };
  }

  factory PalateProfile.fromMap(Map<String, dynamic> map) {
    return PalateProfile(
      fruit: (map['fruit'] as num).toDouble(),
      acidity: (map['acidity'] as num).toDouble(),
      body: (map['body'] as num).toDouble(),
      tannin: (map['tannin'] as num).toDouble(),
      freshness: (map['freshness'] as num).toDouble(),
      complexity: (map['complexity'] as num).toDouble(),
      archetype: PalateArchetype.values.firstWhere(
        (a) => a.name == map['archetype'],
        orElse: () => PalateArchetype.balancedSipper,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PalateProfile &&
          fruit == other.fruit &&
          acidity == other.acidity &&
          body == other.body &&
          tannin == other.tannin &&
          freshness == other.freshness &&
          complexity == other.complexity &&
          archetype == other.archetype;

  @override
  int get hashCode => Object.hash(
        fruit, acidity, body, tannin, freshness, complexity, archetype,
      );

  @override
  String toString() =>
      'PalateProfile(F:$fruit A:$acidity B:$body T:$tannin Fr:$freshness C:$complexity [$archetype])';
}

