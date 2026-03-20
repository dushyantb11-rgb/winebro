import 'package:flutter/material.dart';
import 'package:winebro/core/constants/pairing_constants.dart';

class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.foodProperties,
    required this.pairings,
    this.description,
  });

  final String id;
  final String name;
  final FoodCategory category;
  final List<FoodProperty> foodProperties;
  final List<DishPairing> pairings;
  final String? description;

  IconData get icon => category.icon;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category.name,
    'foodProperties': foodProperties.map((p) => p.name).toList(),
    'pairings': pairings.map((p) => p.toMap()).toList(),
    if (description != null) 'description': description,
  };

  factory Dish.fromMap(Map<String, dynamic> map) => Dish(
    id: map['id'] as String,
    name: map['name'] as String,
    category: FoodCategory.values.firstWhere(
      (c) => c.name == map['category'],
      orElse: () => FoodCategory.northIndianRich,
    ),
    foodProperties: (map['foodProperties'] as List)
        .map((p) => FoodProperty.values.firstWhere(
              (fp) => fp.name == p,
              orElse: () => FoodProperty.aromatic,
            ))
        .toList(),
    pairings: (map['pairings'] as List)
        .map((p) => DishPairing.fromMap(p as Map<String, dynamic>))
        .toList(),
    description: map['description'] as String?,
  );
}

class DishPairing {
  const DishPairing({
    required this.productId,
    required this.strategy,
    required this.broTip,
    required this.score,
  }) : assert(score >= 40 && score <= 99);

  final String productId;
  final PairingStrategy strategy;
  final String broTip;
  final double score;

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'strategy': strategy.name,
    'broTip': broTip,
    'score': score,
  };

  factory DishPairing.fromMap(Map<String, dynamic> map) => DishPairing(
    productId: map['productId'] as String,
    strategy: PairingStrategy.values.firstWhere(
      (s) => s.name == map['strategy'],
      orElse: () => PairingStrategy.complement,
    ),
    broTip: map['broTip'] as String,
    score: (map['score'] as num).toDouble(),
  );
}

enum FoodProperty {
  highFat('High Fat'),
  spicyHeat('Spicy Heat'),
  highProtein('High Protein'),
  lightDelicate('Light & Delicate'),
  sweetDessert('Sweet Dessert'),
  umamiRich('Umami-Rich'),
  acidic('Acidic'),
  smokyCharred('Smoky / Charred'),
  creamy('Creamy'),
  tangy('Tangy'),
  aromatic('Aromatic');

  const FoodProperty(this.displayName);
  final String displayName;
}

