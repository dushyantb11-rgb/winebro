import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_taxonomy.dart';

/// One user's response to an aroma calibration prompt.
///
/// D3 "Indian-context aroma vocabulary" — the goal is to surface
/// non-Western terms that Indian users actually associate with a
/// given scent. The free-text `userAssociation` is where the gold
/// lives (e.g., showing "Vanilla" to an Indian user might surface
/// "Mishti doi", "Phirni", "Kheer").
enum AromaFamiliarity {
  familiar(code: 'familiar'),
  sometimes(code: 'sometimes'),
  never(code: 'never');

  const AromaFamiliarity({required this.code});
  final String code;
}

class AromaCalibrationResponse {
  const AromaCalibrationResponse({
    required this.aroma,
    required this.category,
    required this.familiarity,
    this.userAssociation,
  });

  final String aroma;
  final String category;
  final AromaFamiliarity familiarity;
  final String? userAssociation;

  Map<String, dynamic> toMap() => {
        'aroma': aroma,
        'category': category,
        'familiarity': familiarity.code,
        if (userAssociation != null && userAssociation!.trim().isNotEmpty)
          'userAssociation': userAssociation!.trim(),
      };
}

/// Builds a 3-aroma calibration session, biased toward Indian-context
/// terms (those parenthesized with a Hindi/Marathi name in the
/// taxonomy) since they're the gap we're trying to close.
class AromaCalibrationBuilder {
  static List<({String aroma, String category})> buildSession({
    required int seed,
    int? count,
  }) {
    final cfg = AppConfig.current.aromaWheel;
    count ??= cfg.calibrationCount;
    final indianTerms = <({String aroma, String category})>[];
    final western = <({String aroma, String category})>[];

    for (final cat in kAromaWheel) {
      for (final sub in cat.subcategories) {
        for (final aroma in sub.aromas) {
          // Heuristic: a parenthesized non-Western label, or a known
          // South-Asian-only term.
          final isIndianContext =
              aroma.contains('(') ||
                  kKnownDesiTerms.contains(aroma);
          (isIndianContext ? indianTerms : western)
              .add((aroma: aroma, category: cat.name));
        }
      }
    }

    // Shuffle deterministically by seed so a calibration session
    // is reproducible (helps with QA + analytics).
    _seededShuffle(indianTerms, _LCG(seed));
    _seededShuffle(western, _LCG(seed + 1));

    // 2 Indian-context + 1 western, capped at `count`.
    final result = <({String aroma, String category})>[];
    while (result.length < count) {
      if (indianTerms.length > result.length * cfg.indianShare) {
        result.add(indianTerms.removeLast());
      } else if (western.isNotEmpty) {
        result.add(western.removeLast());
      } else if (indianTerms.isNotEmpty) {
        result.add(indianTerms.removeLast());
      } else {
        break;
      }
    }
    return result;
  }
}

/// Indian-context aroma terms, from `config/aromaWheel`.
Set<String> get kKnownDesiTerms => AppConfig.current.aromaWheel.desiTerms;

/// Tiny LCG so we don't need dart:math import at builder layer
/// just for shuffling 30 terms.
class _LCG {
  _LCG(int seed) : _state = seed;
  int _state;

  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7FFFFFFF;
    return _state % max;
  }
}

void _seededShuffle<T>(List<T> list, _LCG rng) {
  for (var i = list.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = list[i];
    list[i] = list[j];
    list[j] = tmp;
  }
}
