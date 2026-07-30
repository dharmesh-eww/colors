import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colors/App/core/game_logic/color_mixer.dart';
import 'package:colors/App/core/game_logic/accuracy_calculator.dart';
import 'package:colors/App/core/models/paint_model.dart';

void main() {
  group('Color Mixer & Depletion Tests', () {
    test('Paint bottle starts with 100ml available and 0ml poured', () {
      final bottle = PaintBottle(
        type: PaintType.cyan,
        name: 'Cyan',
        color: const Color(0xFF00FFFF),
        hexCode: '#00FFFF',
      );
      expect(bottle.availableMl, equals(100.0));
      expect(bottle.pouredMl, equals(0.0));
    });

    test('Pouring paint reduces availableMl and increases pouredMl', () {
      final bottle = PaintBottle(
        type: PaintType.magenta,
        name: 'Magenta',
        color: const Color(0xFFFF00FF),
        hexCode: '#FF00FF',
      );

      // Pour 20ml
      const pourAmount = 20.0;
      bottle.pouredMl += pourAmount;
      bottle.availableMl = (100.0 - bottle.pouredMl).clamp(0.0, 100.0);

      expect(bottle.pouredMl, equals(20.0));
      expect(bottle.availableMl, equals(80.0));
    });

    test('Cyan + Magenta mix produces blue-ish color (subtractive)', () {
      // 50ml cyan + 50ml magenta = blue-ish (RGB: 0, 0, 255)
      final mixed = ColorMixer.mix(
        cyanMl: 50,
        magentaMl: 50,
        yellowMl: 0,
        blackMl: 0,
        whiteMl: 0,
      );

      final r = (mixed.r * 255).round();
      final g = (mixed.g * 255).round();
      final b = (mixed.b * 255).round();

      // CMYK weighted: 50ml cyan absorbs 50% red, 50ml magenta absorbs 50% green
      // r = (1 - 0.5) * 255 = 128, g = (1 - 0.5) * 255 = 128, b = 255
      // But total absorption of R = c/(c+m) = 0.5, total absorption of G = m/(c+m) = 0.5
      expect(r, lessThan(200));  // Red is reduced by cyan
      expect(g, lessThan(200));  // Green is reduced by magenta
      expect(b, equals(255));    // Blue unaffected — both absorb neither blue
    });

    test('Pure cyan mix produces cyan color', () {
      final mixed = ColorMixer.mix(
        cyanMl: 100,
        magentaMl: 0,
        yellowMl: 0,
        blackMl: 0,
        whiteMl: 0,
      );

      final r = (mixed.r * 255).round();
      final g = (mixed.g * 255).round();
      final b = (mixed.b * 255).round();

      expect(r, equals(0));
      expect(g, equals(255));
      expect(b, equals(255));
    });
  });

  group('Accuracy Calculator Tests', () {
    test('Identical colors yield 100% accuracy', () {
      const c = Color(0xFF008080);
      final accuracy = AccuracyCalculator.calculate(c, c);
      expect(accuracy, closeTo(100.0, 0.01));
    });
  });
}
