import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/core/constants/pairing_constants.dart';
import 'package:winebro/features/pairing/domain/palate_profile.dart';
import 'package:winebro/features/pairing/domain/product.dart';

export 'package:winebro/core/config/app_config.dart' show QuizAnswer, QuizStep;

/// Weight of the "bottles I have tried" prior, as a share of one quiz
/// answer. From config.
double get kTriedPriorWeight => AppConfig.current.quiz.triedPriorWeight;

/// Quiz answers per step, from config.
List<QuizAnswer> get kQuizStep1Foods => AppConfig.current.quiz.answers('foods');
List<QuizAnswer> get kQuizStep2Chaat => AppConfig.current.quiz.answers('chaat');
List<QuizAnswer> get kQuizStep3Drinks => AppConfig.current.quiz.answers('drinks');

/// Turns quiz answers into a palate profile and an archetype, using the
/// rules in `config/quiz` and `config/archetypes`.
class QuizEngine {
  const QuizEngine({this.quiz, this.archetypes});

  final QuizConfig? quiz;
  final ArchetypesConfig? archetypes;

  QuizConfig get _quiz => quiz ?? AppConfig.current.quiz;
  ArchetypesConfig get _archetypes => archetypes ?? AppConfig.current.archetypes;

  PalateProfile generateProfile({
    required List<QuizAnswer> foodAnswers,
    QuizAnswer? chaatAnswer,
    required QuizAnswer drinkAnswer,
    Map<PalateAxis, double>? sliderOverrides,
    List<Product> triedProducts = const [],
  }) {
    final q = _quiz;
    final rawScores = <PalateAxis, double>{
      for (final axis in PalateAxis.values) axis: 0.0,
    };

    void add(QuizAnswer answer) {
      for (final entry in answer.axisContributions.entries) {
        rawScores[entry.key] = rawScores[entry.key]! + entry.value;
      }
    }

    foodAnswers.forEach(add);
    if (chaatAnswer != null) add(chaatAnswer);
    add(drinkAnswer);

    if (triedProducts.isNotEmpty) {
      for (final axis in PalateAxis.values) {
        final avg = triedProducts.map((p) => p[axis]).reduce((a, b) => a + b) /
            triedProducts.length;
        rawScores[axis] = rawScores[axis]! + avg * q.triedPriorWeight;
      }
    }

    final normalizedQuiz = _normalize(rawScores, q);

    final blended = <PalateAxis, double>{};
    for (final axis in PalateAxis.values) {
      final quizScore = normalizedQuiz[axis]!;
      final sliderScore = sliderOverrides?[axis] ?? quizScore;
      blended[axis] =
          (q.quizBlendWeight * quizScore + q.sliderBlendWeight * sliderScore)
              .clamp(q.axisMin, q.axisMax);
    }

    final archetype = classifyArchetype(blended);

    return PalateProfile(
      fruit: blended[PalateAxis.fruit]!,
      acidity: blended[PalateAxis.acidity]!,
      body: blended[PalateAxis.body]!,
      tannin: blended[PalateAxis.tannin]!,
      freshness: blended[PalateAxis.freshness]!,
      complexity: blended[PalateAxis.complexity]!,
      archetype: archetype,
    );
  }

  Map<PalateAxis, double> _normalize(
    Map<PalateAxis, double> raw,
    QuizConfig q,
  ) {
    final values = raw.values.toList();
    var minVal = values.reduce((a, b) => a < b ? a : b);
    var maxVal = values.reduce((a, b) => a > b ? a : b);

    if (maxVal == minVal) {
      minVal = 0;
      maxVal = maxVal == 0 ? 1 : maxVal;
    }

    final range = maxVal - minVal;
    return {
      for (final axis in PalateAxis.values)
        axis: ((raw[axis]! - minVal) / range * q.axisMax)
            .clamp(q.axisMin, q.axisMax),
    };
  }

  /// Every archetype whose rule a profile meets, best match first. Used to
  /// tag drinks (a drink can suit several archetypes); [classifyArchetype]
  /// picks the single best one for a person.
  List<PalateArchetype> qualifyingArchetypes(Map<PalateAxis, double> scores) {
    final ranked = _candidates(scores)..sort((a, b) => b.$2.compareTo(a.$2));
    return ranked.map((c) => c.$1).toList();
  }

  PalateArchetype classifyArchetype(Map<PalateAxis, double> scores) {
    final candidates = _candidates(scores);
    if (candidates.isEmpty) return _archetypes.fallback;
    candidates.sort((a, b) => b.$2.compareTo(a.$2));
    return candidates.first.$1;
  }

  List<(PalateArchetype, double)> _candidates(Map<PalateAxis, double> scores) {
    final axisMax = _quiz.axisMax;
    return [
      for (final rule in _archetypes.rules)
        if (rule.rank(scores, axisMax) case final r?) (rule.archetype, r),
    ];
  }
}
