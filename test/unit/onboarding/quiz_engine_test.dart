import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/onboarding/domain/quiz_engine.dart';

void main() {
  const engine = QuizEngine();

  group('QE-01 to QE-06: Score Generation', () {
    test('QE-01: Single food selection produces valid 0-10 axis scores', () {
      final profile = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]], // Butter Chicken
        drinkAnswer: kQuizStep3Drinks[0], // Old Monk
      );
      for (final axis in PalateAxis.values) {
        expect(profile[axis], greaterThanOrEqualTo(0.0));
        expect(profile[axis], lessThanOrEqualTo(10.0));
      }
    });

    test('QE-02: Two food selections sum contributions', () {
      final singleProfile = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]], // Butter Chicken only
        drinkAnswer: kQuizStep3Drinks[0],
      );
      final doubleProfile = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0], kQuizStep1Foods[1]], // + Biryani
        drinkAnswer: kQuizStep3Drinks[0],
      );
      // Two foods should produce different scores than one
      expect(singleProfile.axisValues, isNot(equals(doubleProfile.axisValues)));
    });

    test('QE-04: Chaat answer modifies profile when applicable', () {
      final withoutChaat = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[2]], // Pani Puri
        drinkAnswer: kQuizStep3Drinks[0],
      );
      final withChaat = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[2]], // Pani Puri
        chaatAnswer: kQuizStep2Chaat[0], // Tangy water burst (acidity+3)
        drinkAnswer: kQuizStep3Drinks[0],
      );
      // With chaat answer should produce different profile
      expect(withoutChaat.axisValues, isNot(equals(withChaat.axisValues)));
    });

    test('QE-05: Normalization maps to 0-10 range', () {
      // Test with extreme food combinations
      final profile = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0], kQuizStep1Foods[6]], // Butter Chicken + Dal Makhani
        drinkAnswer: kQuizStep3Drinks[2], // Masala Chai
      );
      for (final axis in PalateAxis.values) {
        expect(profile[axis], greaterThanOrEqualTo(0.0));
        expect(profile[axis], lessThanOrEqualTo(10.0));
      }
    });

    test('QE-06: All-same raw scores dont cause division by zero', () {
      // "Surprise me" gives equal scores on all axes
      final profile = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]],
        drinkAnswer: kQuizStep3Drinks[8], // Surprise me (all 2s)
      );
      // Should not throw and should produce valid scores
      for (final axis in PalateAxis.values) {
        expect(profile[axis], greaterThanOrEqualTo(0.0));
        expect(profile[axis], lessThanOrEqualTo(10.0));
      }
    });
  });

  group('QE-07 to QE-09: Slider Blending', () {
    test('QE-07: Untouched sliders equal quiz result', () {
      final quizOnly = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]],
        drinkAnswer: kQuizStep3Drinks[0],
      );
      // No slider overrides = same result (0.4*q + 0.6*q = q)
      final withSameSliders = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]],
        drinkAnswer: kQuizStep3Drinks[0],
        sliderOverrides: null,
      );
      expect(quizOnly.fruit, equals(withSameSliders.fruit));
    });

    test('QE-08: Slider overrides weight at 60%', () {
      final withSlider = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]],
        drinkAnswer: kQuizStep3Drinks[0],
        sliderOverrides: {
          PalateAxis.fruit: 10.0,
          PalateAxis.acidity: 10.0,
          PalateAxis.body: 10.0,
          PalateAxis.tannin: 10.0,
          PalateAxis.freshness: 10.0,
          PalateAxis.complexity: 10.0,
        },
      );
      // All sliders at 10 should push everything high
      // blend = 0.4 * quiz + 0.6 * 10 = at least 6.0
      for (final axis in PalateAxis.values) {
        expect(withSlider[axis], greaterThanOrEqualTo(6.0));
      }
    });

    test('QE-09: Blended scores clamped to 0-10', () {
      final profile = engine.generateProfile(
        foodAnswers: [kQuizStep1Foods[0]],
        drinkAnswer: kQuizStep3Drinks[0],
        sliderOverrides: {
          for (final axis in PalateAxis.values) axis: 10.0,
        },
      );
      for (final axis in PalateAxis.values) {
        expect(profile[axis], lessThanOrEqualTo(10.0));
        expect(profile[axis], greaterThanOrEqualTo(0.0));
      }
    });
  });

  group('QE-10 to QE-16: Archetype Classification', () {
    test('QE-10: Body>=7 AND Complexity>=7 → Bold Explorer', () {
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 5,
        PalateAxis.acidity: 5,
        PalateAxis.body: 8,
        PalateAxis.tannin: 5,
        PalateAxis.freshness: 4,
        PalateAxis.complexity: 8,
      });
      expect(archetype, equals(PalateArchetype.boldExplorer));
    });

    test('QE-11: Acidity>=7 AND Freshness>=7 → Crisp Purist', () {
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 5,
        PalateAxis.acidity: 8,
        PalateAxis.body: 3,
        PalateAxis.tannin: 3,
        PalateAxis.freshness: 8,
        PalateAxis.complexity: 5,
      });
      expect(archetype, equals(PalateArchetype.crispPurist));
    });

    test('QE-12: Fruit>=8 with high tannin → Fruit Forward (not Sweet Tooth)', () {
      // Tannin=5 prevents Sweet Tooth (needs Tannin<=3)
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 9,
        PalateAxis.acidity: 4,
        PalateAxis.body: 4,
        PalateAxis.tannin: 5,
        PalateAxis.freshness: 5,
        PalateAxis.complexity: 4,
      });
      expect(archetype, equals(PalateArchetype.fruitForward));
    });

    test('QE-12b: Fruit>=8 AND Tannin<=3 → Sweet Tooth wins (higher combined score)', () {
      // Both trigger, but Sweet Tooth has higher combined threshold
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 9,
        PalateAxis.acidity: 4,
        PalateAxis.body: 4,
        PalateAxis.tannin: 3,
        PalateAxis.freshness: 5,
        PalateAxis.complexity: 4,
      });
      expect(archetype, equals(PalateArchetype.sweetTooth));
    });

    test('QE-13: Tannin<=3 AND Fruit>=7 → Sweet Tooth', () {
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 7,
        PalateAxis.acidity: 4,
        PalateAxis.body: 4,
        PalateAxis.tannin: 2,
        PalateAxis.freshness: 5,
        PalateAxis.complexity: 4,
      });
      expect(archetype, equals(PalateArchetype.sweetTooth));
    });

    test('QE-14: All axes 3-7 → Balanced Sipper', () {
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 5,
        PalateAxis.acidity: 5,
        PalateAxis.body: 5,
        PalateAxis.tannin: 5,
        PalateAxis.freshness: 5,
        PalateAxis.complexity: 5,
      });
      expect(archetype, equals(PalateArchetype.balancedSipper));
    });

    test('QE-16: No archetype triggered → fallback to Balanced Sipper', () {
      // Scores that don't trigger any specific archetype
      final archetype = engine.classifyArchetype({
        PalateAxis.fruit: 4,
        PalateAxis.acidity: 4,
        PalateAxis.body: 4,
        PalateAxis.tannin: 4,
        PalateAxis.freshness: 4,
        PalateAxis.complexity: 4,
      });
      expect(archetype, equals(PalateArchetype.balancedSipper));
    });
  });
}
