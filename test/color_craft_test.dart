import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colors/App/core/game_logic/color_mixer.dart';
import 'package:colors/App/core/game_logic/accuracy_calculator.dart';
import 'package:colors/App/core/models/paint_model.dart';

void main() {
  group('Color Mixer & Depletion Tests', () {
    test('Paint bottle starts with 100ml available and 0ml poured', () {
      final bottle = PaintBottle(
        type: PaintType.red,
        name: 'Red',
        color: const Color(0xFFFF7675),
        emoji: '🔴',
      );
      expect(bottle.availableMl, equals(100.0));
      expect(bottle.pouredMl, equals(0.0));
    });

    test('Pouring paint reduces availableMl and increases pouredMl', () {
      final bottle = PaintBottle(
        type: PaintType.red,
        name: 'Red',
        color: const Color(0xFFFF7675),
        emoji: '🔴',
      );

      // Pour 20ml
      const pourAmount = 20.0;
      bottle.pouredMl += pourAmount;
      bottle.availableMl = (100.0 - bottle.pouredMl).clamp(0.0, 100.0);

      expect(bottle.pouredMl, equals(20.0));
      expect(bottle.availableMl, equals(80.0));
    });

    test('Mixed color recalculates correctly after multiple pours', () {
      final redPoured = 40.0;
      final greenPoured = 60.0;

      final mixed = ColorMixer.mix(
        redMl: redPoured,
        greenMl: greenPoured,
        blueMl: 0,
        whiteMl: 0,
        blackMl: 0,
      );

      final r = (mixed.r * 255).round();
      final g = (mixed.g * 255).round();
      final b = (mixed.b * 255).round();

      expect(r, equals(102)); // (40 * 255) / 100
      expect(g, equals(153)); // (60 * 255) / 100
      expect(b, equals(0));
    });
  });

  group('Accuracy Calculator Tests', () {
    test('Identical colors yield 100% accuracy', () {
      const c = Color(0xFFE6BE28);
      final accuracy = AccuracyCalculator.calculate(c, c);
      expect(accuracy, closeTo(100.0, 0.01));
    });
  });
}
