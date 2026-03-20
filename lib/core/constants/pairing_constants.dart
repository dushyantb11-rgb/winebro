import 'package:flutter/material.dart';

enum PalateAxis {
  fruit,
  acidity,
  body,
  tannin,
  freshness,
  complexity;

  double get defaultWeight => switch (this) {
    PalateAxis.fruit => 1.0,
    PalateAxis.acidity => 1.2,
    PalateAxis.body => 1.1,
    PalateAxis.tannin => 0.9,
    PalateAxis.freshness => 0.8,
    PalateAxis.complexity => 1.0,
  };

  String get displayName => switch (this) {
    PalateAxis.fruit => 'Fruit',
    PalateAxis.acidity => 'Acidity',
    PalateAxis.body => 'Body',
    PalateAxis.tannin => 'Tannin',
    PalateAxis.freshness => 'Freshness',
    PalateAxis.complexity => 'Complexity',
  };
}

enum PalateArchetype {
  boldExplorer(
    displayName: 'Bold Explorer',
    description: 'You crave intensity. Full-bodied reds, aged whisky, '
        'barrel-aged stouts — the bolder, the better.',
    icon: Icons.explore,
    bonusPercent: 15,
  ),
  crispPurist(
    displayName: 'Crisp Purist',
    description: 'Clean lines and sharp edges. Sauvignon Blanc, dry Riesling, '
        'pilsner, gin & tonic — you love precision.',
    icon: Icons.diamond,
    bonusPercent: 12,
  ),
  fruitForward(
    displayName: 'Fruit Forward',
    description: 'Ripe, juicy, and expressive. New World reds, fruit beers, '
        'rum cocktails — if it bursts with fruit, you\'re in.',
    icon: Icons.park,
    bonusPercent: 10,
  ),
  balancedSipper(
    displayName: 'Balanced Sipper',
    description: 'Harmony in every sip. Medium-bodied wines, wheat beers, '
        'blended whiskies — you appreciate equilibrium.',
    icon: Icons.balance,
    bonusPercent: 5,
  ),
  sweetTooth(
    displayName: 'Sweet Tooth',
    description: 'Life\'s too short for bitter. Moscato, dessert wines, '
        'sweet cocktails, ciders — you know what you love.',
    icon: Icons.cake,
    bonusPercent: 12,
  );

  const PalateArchetype({
    required this.displayName,
    required this.description,
    required this.icon,
    required this.bonusPercent,
  });

  final String displayName;
  final String description;
  final IconData icon;
  final int bonusPercent;
}

enum DrinkCategory {
  redWine('Red Wine'),
  whiteWine('White Wine'),
  roseWine('Rosé Wine'),
  sparklingWine('Sparkling Wine'),
  dessertWine('Dessert Wine'),
  whisky('Whisky'),
  gin('Gin'),
  rum('Rum'),
  vodka('Vodka'),
  tequila('Tequila'),
  beer('Beer'),
  craftBeer('Craft Beer');

  const DrinkCategory(this.displayName);
  final String displayName;

  String get group => switch (this) {
    DrinkCategory.redWine ||
    DrinkCategory.whiteWine ||
    DrinkCategory.roseWine ||
    DrinkCategory.sparklingWine ||
    DrinkCategory.dessertWine => 'Wine',
    DrinkCategory.whisky => 'Whisky',
    DrinkCategory.gin ||
    DrinkCategory.rum ||
    DrinkCategory.vodka ||
    DrinkCategory.tequila => 'Spirits',
    DrinkCategory.beer ||
    DrinkCategory.craftBeer => 'Beer',
  };
}

enum FoodCategory {
  northIndianRich('North Indian Rich'),
  southIndianSpiced('South Indian Spiced'),
  coastalSeafood('Coastal Seafood'),
  streetFood('Street Food'),
  tandooriGrilled('Tandoori / Grilled'),
  vegetarianPaneer('Vegetarian / Paneer'),
  riceDishes('Rice Dishes'),
  desserts('Desserts');

  const FoodCategory(this.displayName);
  final String displayName;

  IconData get icon => switch (this) {
    FoodCategory.northIndianRich => Icons.restaurant,
    FoodCategory.southIndianSpiced => Icons.breakfast_dining,
    FoodCategory.coastalSeafood => Icons.set_meal,
    FoodCategory.streetFood => Icons.fastfood,
    FoodCategory.tandooriGrilled => Icons.kebab_dining,
    FoodCategory.vegetarianPaneer => Icons.eco,
    FoodCategory.riceDishes => Icons.rice_bowl,
    FoodCategory.desserts => Icons.cake,
  };
}

enum PairingStrategy {
  complement('Complement', 'Like reinforces like — similar profiles enhance each other'),
  contrast('Contrast', 'Opposites balance — opposing elements counteract each other');

  const PairingStrategy(this.displayName, this.description);
  final String displayName;
  final String description;
}

enum Occasion {
  dateNight('Date Night', Icons.nightlife),
  bbqCookout('BBQ / Cookout', Icons.outdoor_grill),
  casualFriday('Casual Friday', Icons.weekend),
  celebration('Celebration', Icons.celebration),
  businessDinner('Business Dinner', Icons.business_center),
  beachPool('Beach / Pool', Icons.beach_access);

  const Occasion(this.displayName, this.icon);
  final String displayName;
  final IconData icon;

  Map<PalateAxis, double> get axisModifiers => switch (this) {
    Occasion.dateNight => {
      PalateAxis.complexity: 1.5,
      PalateAxis.body: 1.0,
      PalateAxis.freshness: -0.5,
    },
    Occasion.bbqCookout => {
      PalateAxis.body: 1.5,
      PalateAxis.tannin: 1.0,
      PalateAxis.complexity: -0.5,
    },
    Occasion.casualFriday => {
      PalateAxis.freshness: 1.0,
      PalateAxis.fruit: 0.5,
      PalateAxis.body: -0.5,
    },
    Occasion.celebration => {
      PalateAxis.complexity: 1.5,
      PalateAxis.acidity: 1.0,
    },
    Occasion.businessDinner => {
      PalateAxis.complexity: 1.0,
    },
    Occasion.beachPool => {
      PalateAxis.freshness: 1.5,
      PalateAxis.acidity: 1.0,
      PalateAxis.body: -1.0,
    },
  };

  ({DrinkCategory category, double bonusPercent})? get categoryBonus =>
      switch (this) {
        Occasion.celebration => (
          category: DrinkCategory.sparklingWine,
          bonusPercent: 10,
        ),
        _ => null,
      };
}

const double kScoreFloor = 40.0;
const double kScoreCeiling = 99.0;
const double kAxisMin = 0.0;
const double kAxisMax = 10.0;

const double kQuizBlendWeight = 0.4;
const double kSliderBlendWeight = 0.6;

const double kFrequencyPenalty2nd = -3.0;
const double kFrequencyPenalty3rd = -8.0;
const double kFrequencyPenaltyCap = -15.0;

const Map<int, ({String name, int minXp, IconData icon})> kXpLevels = {
  0: (name: 'Curious Sibling', minXp: 0, icon: Icons.eco),
  1: (name: 'Aspiring Taster', minXp: 500, icon: Icons.spa),
  2: (name: 'Confident Pairer', minXp: 1500, icon: Icons.local_florist),
  3: (name: 'Wise Elder', minXp: 5000, icon: Icons.diamond),
};

