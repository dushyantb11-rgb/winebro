import 'package:flutter_test/flutter_test.dart';
import 'package:winebro/features/aroma_wheel/domain/aroma_calibration.dart';

void main() {
  group('AromaCalibrationBuilder', () {
    test('returns the requested number of items', () {
      final session = AromaCalibrationBuilder.buildSession(seed: 42);
      expect(session.length, 3);
    });

    test('returns the requested count when count parameter is set', () {
      final session = AromaCalibrationBuilder.buildSession(seed: 42, count: 5);
      expect(session.length, 5);
    });

    test('biases toward Indian-context terms (>=2 of 3 over 100 sessions)', () {
      var indianMajoritySessions = 0;
      for (var seed = 0; seed < 100; seed++) {
        final session =
            AromaCalibrationBuilder.buildSession(seed: seed, count: 3);
        final indianCount = session.where((e) => _looksDesi(e.aroma)).length;
        if (indianCount >= 2) indianMajoritySessions++;
      }
      // Should be the strong majority — sampling logic bias plus the
      // 30+ desi terms in the wheel vs ~50 western means most sessions
      // hit the 2/3 floor.
      expect(indianMajoritySessions, greaterThanOrEqualTo(70));
    });

    test('same seed produces the same session (deterministic for QA)', () {
      final a = AromaCalibrationBuilder.buildSession(seed: 1234);
      final b = AromaCalibrationBuilder.buildSession(seed: 1234);
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].aroma, b[i].aroma);
        expect(a[i].category, b[i].category);
      }
    });

    test('different seeds produce different sessions (variance check)', () {
      final a = AromaCalibrationBuilder.buildSession(seed: 1);
      final b = AromaCalibrationBuilder.buildSession(seed: 999);
      // Not asserting they're TOTALLY different — just at least one
      // slot diverges, which is what we need for daily rotation.
      var divergent = false;
      for (var i = 0; i < a.length; i++) {
        if (a[i].aroma != b[i].aroma) {
          divergent = true;
          break;
        }
      }
      expect(divergent, isTrue);
    });
  });

  group('AromaCalibrationResponse', () {
    test('toMap omits empty userAssociation', () {
      const r = AromaCalibrationResponse(
        aroma: 'Aam (Mango)',
        category: 'Fruity',
        familiarity: AromaFamiliarity.familiar,
        userAssociation: '   ',
      );
      expect(r.toMap().containsKey('userAssociation'), isFalse);
    });

    test('toMap includes trimmed userAssociation when present', () {
      const r = AromaCalibrationResponse(
        aroma: 'Imli',
        category: 'Earthy',
        familiarity: AromaFamiliarity.familiar,
        userAssociation: '  panipuri water  ',
      );
      expect(r.toMap()['userAssociation'], 'panipuri water');
    });
  });
}

bool _looksDesi(String aroma) {
  return aroma.contains('(') ||
      const {
        'Champa', 'Mogra', 'Mahua', 'Jaggery', 'Ajwain', 'Kokum',
        'Munakka', 'Pudina', 'Curry Leaf', 'Ghee', 'Jackfruit',
      }.contains(aroma);
}
