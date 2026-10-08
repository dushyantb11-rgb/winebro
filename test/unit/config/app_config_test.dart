import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/config/default_config.g.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/data/seed_dishes.dart';
import 'package:winebro/features/pairing/domain/dish.dart';
import 'package:winebro/features/pairing/domain/pairing_engine.dart';
import 'package:winebro/features/pairing/domain/product.dart';

Product drink({
  double fruit = 5,
  double acidity = 5,
  double body = 5,
  double tannin = 5,
}) =>
    Product(
      id: 'test-drink',
      name: 'Test Drink',
      category: DrinkCategory.redWine,
      subcategory: 'Test',
      region: 'Test',
      price: 0,
      fruit: fruit,
      acidity: acidity,
      body: body,
      tannin: tannin,
      freshness: 5,
      complexity: 5,
      archetypeTags: const [],
      tastingNotes: '',
      aromas: const [],
    );

void main() {
  group('AppConfig', () {
    test('CF-01 bundled defaults match tool/config/config.json', () {
      final file = File('tool/config/config.json').readAsStringSync();
      expect(jsonDecode(kDefaultConfigJson), equals(jsonDecode(file)),
          reason: 'run: python tool/config/gen_defaults.py');
    });

    test('CF-02 defaults parse every document', () {
      final c = AppConfig.defaults;
      expect(c.pairingRules.foodFitRules.length, FoodProperty.values.length);
      expect(c.archetypes.items.length, PalateArchetype.values.length);
      expect(c.quiz.answers('foods'), isNotEmpty);
      expect(c.badges.items.length, 20);
      expect(c.categories.drinks.length, DrinkCategory.values.length);
      expect(c.occasions.items.length, Occasion.values.length);
      expect(c.aromaWheel.categories.length, 6);
      expect(c.gamification.levels.map((l) => l.minXp), [0, 500, 1500, 5000]);
    });

    test('CF-03 a broken remote document falls back to the bundled one', () {
      final errors = <String>[];
      final c = AppConfig.fromJson(
        {
          'scanner': {'minScore': 'oops'},
          'quiz': {'axisMin': 0, 'axisMax': 10, 'quizBlendWeight': 0.5, 'sliderBlendWeight': 0.5, 'triedPriorWeight': 0.5, 'steps': <Object>[], 'version': 7},
        },
        fallback: AppConfig.defaults,
        onError: (doc, e, s) => errors.add(doc),
      );
      expect(errors, ['scanner']);
      expect(c.scanner.minScore, AppConfig.defaults.scanner.minScore);
      expect(c.quiz.quizBlendWeight, 0.5);
      expect(c.versions, {'quiz': 7});
      expect(c.badges.items, AppConfig.defaults.badges.items);
    });

    test('CF-04 engine scores follow the rules it is given', () {
      final spicy = kSeedDishes.firstWhere(
        (d) => d.foodProperties.contains(FoodProperty.spicyHeat),
      );
      final fruity = drink(fruit: 8, tannin: 2);
      final base = const PairingEngine().explainFoodFit(spicy, fruity);
      final spicyPoints = base.rulePoints
          .firstWhere((r) => r.property == FoodProperty.spicyHeat)
          .points;
      expect(spicyPoints, 20);

      final raw = jsonDecode(kDefaultConfigJson) as Map<String, dynamic>;
      final rules = Map<String, dynamic>.from(raw['pairingRules'] as Map);
      final fit = Map<String, dynamic>.from(rules['foodFitRules'] as Map);
      fit['spicyHeat'] = [
        {
          'when': [
            {'axis': 'fruit', 'op': '>=', 'value': 6},
          ],
          'points': 33,
        },
      ];
      rules['foodFitRules'] = fit;
      final tuned = PairingEngine(rules: PairingRulesConfig.fromMap(rules));
      final after = tuned.explainFoodFit(spicy, fruity);
      expect(
        after.rulePoints
            .firstWhere((r) => r.property == FoodProperty.spicyHeat)
            .points,
        33,
      );
      expect(after.total, isNot(base.total));
    });

    test('CF-06 a category added in config appears in the app', () {
      final raw = jsonDecode(kDefaultConfigJson) as Map<String, dynamic>;
      final cats = Map<String, dynamic>.from(raw['categories'] as Map);
      cats['drinks'] = [
        ...(cats['drinks'] as List),
        {'code': 'mead', 'displayName': 'Mead', 'group': 'Wine'},
      ];
      raw['categories'] = cats;
      final previous = AppConfig.current;
      AppConfig.current = AppConfig.fromJson(raw);
      try {
        expect(DrinkCategory.values.map((c) => c.name), contains('mead'));
        const mead = DrinkCategory('mead');
        expect(mead.displayName, 'Mead');
        expect(mead.group, 'Wine');
        final p = drink().copyWith(category: mead);
        expect(Product.fromMap(p.toMap()).category, mead);
      } finally {
        AppConfig.current = previous;
      }
      expect(DrinkCategory.values.map((c) => c.name), isNot(contains('mead')));
    });

    test('CF-05 explanation templates fill placeholders', () {
      final spicy = kSeedDishes.firstWhere(
        (d) => d.foodProperties.contains(FoodProperty.spicyHeat),
      );
      final results = const PairingEngine().suggestFoodForDrink(
        product: drink(fruit: 8, acidity: 7, tannin: 2),
        dishes: [spicy],
      );
      final text = results.single.explanation;
      expect(text, isNot(contains('{')));
      expect(text, contains(spicy.name));
    });
  });
}
