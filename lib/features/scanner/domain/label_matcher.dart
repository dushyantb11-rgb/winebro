import 'package:string_similarity/string_similarity.dart';
import 'package:winebro/core/config/app_config.dart';
import 'package:winebro/features/pairing/domain/product.dart';

/// Result of matching label text to the catalogue.
class LabelMatch {
  const LabelMatch({required this.product, required this.score});
  final Product product;

  /// Share of the product's name words found on the label, 0..1.
  final double score;

  int get percent => (score * 100).round();
}

/// Matches OCR text from a bottle label to a catalogue product, word by
/// word. A label rarely prints the full catalogue name in one line
/// ("SULA" and "SAUVIGNON BLANC" on separate lines, no "Vineyards"), so
/// comparing the whole name to the whole label text misses real bottles.
///
/// Rules (thresholds and the generic-word list come from `config/scanner`):
///   - generic words (vineyards, winery, the, …) are ignored;
///   - a name word counts as found if a label word equals it, or is at
///     least `fuzzyThreshold` similar (OCR slips such as "SAUV1GNON");
///   - numbers must match exactly, so "12" never matches "16";
///   - the brand (first name word) must be found;
///   - score = found words / name words; at least `minScore` to match;
///   - ties go to the name with more found words (the more specific one).
class LabelMatcher {
  const LabelMatcher({this.config});

  final ScannerConfig? config;

  ScannerConfig get _c => config ?? AppConfig.current.scanner;

  double get minScore => _c.minScore;
  double get fuzzyThreshold => _c.fuzzyThreshold;

  /// Words ignored when comparing names, from config.
  static Set<String> get genericWords => AppConfig.current.scanner.genericWords;

  static List<String> words(String text) {
    const accents = {
      'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e', 'ê': 'e',
      'ë': 'e', 'í': 'i', 'ï': 'i', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'ú': 'u',
      'ü': 'u', 'ñ': 'n', 'ç': 'c',
    };
    final lower =
        text.toLowerCase().split('').map((c) => accents[c] ?? c).join();
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
  }

  LabelMatch? match(String ocrText, List<Product> catalog) {
    final c = _c;
    final labelWords = words(ocrText).toSet();
    if (labelWords.isEmpty) return null;

    LabelMatch? best;
    var bestFound = 0;
    for (final product in catalog) {
      final nameWords = words(product.name)
          .where((w) => !c.genericWords.contains(w))
          .toList();
      if (nameWords.isEmpty) continue;

      var found = 0;
      var brandFound = false;
      for (var i = 0; i < nameWords.length; i++) {
        if (_isOnLabel(nameWords[i], labelWords, c)) {
          found++;
          if (i == 0) brandFound = true;
        }
      }
      if (!brandFound) continue;

      final score = found / nameWords.length;
      if (score < c.minScore) continue;
      final better = best == null ||
          score > best.score ||
          (score == best.score && found > bestFound);
      if (better) {
        best = LabelMatch(product: product, score: score);
        bestFound = found;
      }
    }
    return best;
  }

  bool _isOnLabel(String word, Set<String> labelWords, ScannerConfig c) {
    if (labelWords.contains(word)) return true;
    final isNumber = RegExp(r'^\d+$').hasMatch(word);
    if (isNumber || word.length < c.minFuzzyWordLength) return false;
    return labelWords.any((w) =>
        w.length >= c.minFuzzyWordLength &&
        StringSimilarity.compareTwoStrings(word, w) >= c.fuzzyThreshold);
  }
}
