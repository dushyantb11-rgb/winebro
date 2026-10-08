import 'package:flutter/material.dart';
import 'package:winebro/core/config/app_config.dart';

// Reference values are plain data from Firestore `config/*`. A value is
// identified by its code (`name`); the list of codes, display names,
// icons, weights and modifiers all come from config, so the admin can
// add a category, occasion or archetype without an app release.

/// A coded reference value. Two values are equal when their codes match.
abstract class Coded {
  const Coded(this.name);

  /// Stable code, e.g. `redWine`, `spicyHeat`. Stored as-is in Firestore.
  final String name;

  @override
  bool operator ==(Object other) =>
      other is Coded && other.runtimeType == runtimeType && other.name == name;

  @override
  int get hashCode => Object.hash(runtimeType, name);

  @override
  String toString() => name;
}

/// The six taste axes. These are structural: every drink and every
/// palate profile carries a score per axis, so the set is fixed.
enum PalateAxis {
  fruit,
  acidity,
  body,
  tannin,
  freshness,
  complexity;

  double get defaultWeight =>
      AppConfig.current.pairingRules.axisWeights[this] ?? 1.0;

  String get displayName => AppConfig.current.categories.palateAxes[this] ?? name;
}

class PalateArchetype extends Coded {
  const PalateArchetype(super.name);

  static const boldExplorer = PalateArchetype('boldExplorer');
  static const crispPurist = PalateArchetype('crispPurist');
  static const fruitForward = PalateArchetype('fruitForward');
  static const balancedSipper = PalateArchetype('balancedSipper');
  static const sweetTooth = PalateArchetype('sweetTooth');

  /// All archetypes in config order.
  static List<PalateArchetype> get values => [
        for (final code in AppConfig.current.archetypes.items.keys)
          PalateArchetype(code),
      ];

  ArchetypeInfo? get _info => AppConfig.current.archetypes.items[name];

  String get displayName => _info?.displayName ?? name;
  String get description => _info?.description ?? '';
  IconData get icon => _info?.icon ?? Icons.wine_bar;
  int get bonusPercent => _info?.bonusPercent ?? 0;
}

class DrinkCategory extends Coded {
  const DrinkCategory(super.name);

  static const redWine = DrinkCategory('redWine');
  static const whiteWine = DrinkCategory('whiteWine');
  static const roseWine = DrinkCategory('roseWine');
  static const sparklingWine = DrinkCategory('sparklingWine');
  static const dessertWine = DrinkCategory('dessertWine');
  static const whisky = DrinkCategory('whisky');
  static const brandy = DrinkCategory('brandy');
  static const gin = DrinkCategory('gin');
  static const rum = DrinkCategory('rum');
  static const vodka = DrinkCategory('vodka');
  static const tequila = DrinkCategory('tequila');
  static const beer = DrinkCategory('beer');
  static const craftBeer = DrinkCategory('craftBeer');

  /// All drink categories in config order.
  static List<DrinkCategory> get values => [
        for (final code in AppConfig.current.categories.drinks.keys)
          DrinkCategory(code),
      ];

  DrinkCategoryInfo? get _info => AppConfig.current.categories.drinks[name];

  String get displayName => _info?.displayName ?? name;
  String get group => _info?.group ?? 'Spirits';
}

class FoodCategory extends Coded {
  const FoodCategory(super.name);

  static const northIndianRich = FoodCategory('northIndianRich');
  static const southIndianSpiced = FoodCategory('southIndianSpiced');
  static const coastalSeafood = FoodCategory('coastalSeafood');
  static const streetFood = FoodCategory('streetFood');
  static const tandooriGrilled = FoodCategory('tandooriGrilled');
  static const vegetarianPaneer = FoodCategory('vegetarianPaneer');
  static const riceDishes = FoodCategory('riceDishes');
  static const desserts = FoodCategory('desserts');

  /// All cuisines in config order.
  static List<FoodCategory> get values => [
        for (final code in AppConfig.current.categories.cuisines.keys)
          FoodCategory(code),
      ];

  CuisineInfo? get _info => AppConfig.current.categories.cuisines[name];

  String get displayName => _info?.displayName ?? name;
  IconData get icon => _info?.icon ?? Icons.restaurant;
}

/// A property of a dish that the pairing rules react to.
class FoodProperty extends Coded {
  const FoodProperty(super.name);

  static const highFat = FoodProperty('highFat');
  static const spicyHeat = FoodProperty('spicyHeat');
  static const highProtein = FoodProperty('highProtein');
  static const lightDelicate = FoodProperty('lightDelicate');
  static const sweetDessert = FoodProperty('sweetDessert');
  static const umamiRich = FoodProperty('umamiRich');
  static const acidic = FoodProperty('acidic');
  static const smokyCharred = FoodProperty('smokyCharred');
  static const creamy = FoodProperty('creamy');
  static const tangy = FoodProperty('tangy');
  static const aromatic = FoodProperty('aromatic');

  /// All food properties in config order.
  static List<FoodProperty> get values => [
        for (final code in AppConfig.current.categories.foodProperties.keys)
          FoodProperty(code),
      ];

  String get displayName =>
      AppConfig.current.categories.foodProperties[name] ?? name;
}

enum PairingStrategy {
  complement,
  contrast;

  StrategyInfo? get _info =>
      AppConfig.current.categories.pairingStrategies[this];

  String get displayName => _info?.displayName ?? name;
  String get description => _info?.description ?? '';
}

class Occasion extends Coded {
  const Occasion(super.name);

  static const dateNight = Occasion('dateNight');
  static const bbqCookout = Occasion('bbqCookout');
  static const casualFriday = Occasion('casualFriday');
  static const celebration = Occasion('celebration');
  static const businessDinner = Occasion('businessDinner');
  static const beachPool = Occasion('beachPool');

  /// All occasions in config order.
  static List<Occasion> get values => [
        for (final code in AppConfig.current.occasions.items.keys) Occasion(code),
      ];

  OccasionInfo? get _info => AppConfig.current.occasions.items[name];

  String get displayName => _info?.displayName ?? name;
  IconData get icon => _info?.icon ?? Icons.celebration;
  Map<PalateAxis, double> get axisModifiers => _info?.axisModifiers ?? const {};
  ({DrinkCategory category, double bonusPercent})? get categoryBonus =>
      _info?.categoryBonus;
}

// Scoring bounds and blend weights, from config.
double get kScoreFloor => AppConfig.current.pairingRules.scoreFloor;
double get kScoreCeiling => AppConfig.current.pairingRules.scoreCeiling;
double get kAxisMin => AppConfig.current.quiz.axisMin;
double get kAxisMax => AppConfig.current.quiz.axisMax;
double get kQuizBlendWeight => AppConfig.current.quiz.quizBlendWeight;
double get kSliderBlendWeight => AppConfig.current.quiz.sliderBlendWeight;
double get kFrequencyPenalty2nd =>
    AppConfig.current.pairingRules.frequencyPenaltySecond;
double get kFrequencyPenalty3rd =>
    AppConfig.current.pairingRules.frequencyPenaltyThird;
double get kFrequencyPenaltyCap =>
    AppConfig.current.pairingRules.frequencyPenaltyCap;

/// XP levels keyed by level number, from config.
Map<int, ({String name, int minXp, IconData icon})> get kXpLevels => {
      for (final l in AppConfig.current.gamification.levels)
        l.level: (name: l.name, minXp: l.minXp, icon: l.icon),
    };
