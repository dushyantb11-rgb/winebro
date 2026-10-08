import 'package:flutter/material.dart';
import 'package:winebro/core/config/app_config.dart';

// Codes below are stable identifiers. Everything about them — names,
// descriptions, icons, weights, bonuses, modifiers — comes from
// Firestore `config/*` (see AppConfig) and is edited in the admin app.

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

enum PalateArchetype {
  boldExplorer,
  crispPurist,
  fruitForward,
  balancedSipper,
  sweetTooth;

  ArchetypeInfo? get _info => AppConfig.current.archetypes.items[this];

  String get displayName => _info?.displayName ?? name;
  String get description => _info?.description ?? '';
  IconData get icon => _info?.icon ?? Icons.wine_bar;
  int get bonusPercent => _info?.bonusPercent ?? 0;
}

enum DrinkCategory {
  redWine,
  whiteWine,
  roseWine,
  sparklingWine,
  dessertWine,
  whisky,
  brandy,
  gin,
  rum,
  vodka,
  tequila,
  beer,
  craftBeer;

  DrinkCategoryInfo? get _info => AppConfig.current.categories.drinks[this];

  String get displayName => _info?.displayName ?? name;
  String get group => _info?.group ?? 'Spirits';
}

enum FoodCategory {
  northIndianRich,
  southIndianSpiced,
  coastalSeafood,
  streetFood,
  tandooriGrilled,
  vegetarianPaneer,
  riceDishes,
  desserts;

  CuisineInfo? get _info => AppConfig.current.categories.cuisines[this];

  String get displayName => _info?.displayName ?? name;
  IconData get icon => _info?.icon ?? Icons.restaurant;
}

enum PairingStrategy {
  complement,
  contrast;

  StrategyInfo? get _info =>
      AppConfig.current.categories.pairingStrategies[this];

  String get displayName => _info?.displayName ?? name;
  String get description => _info?.description ?? '';
}

enum Occasion {
  dateNight,
  bbqCookout,
  casualFriday,
  celebration,
  businessDinner,
  beachPool;

  OccasionInfo? get _info => AppConfig.current.occasions.items[this];

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
