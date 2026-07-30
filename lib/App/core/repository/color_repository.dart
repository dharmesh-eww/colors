import 'package:flutter/material.dart';
import '../game_logic/color_generator.dart';
import '../game_logic/color_mixer.dart';
import '../game_logic/accuracy_calculator.dart';

class ColorRepository {
  Color generateTargetColor({Color? previousColor}) {
    return ColorGenerator.generateTarget(previousColor: previousColor);
  }

  Color mixPaints({
    required double cyan,
    required double magenta,
    required double yellow,
    required double black,
    required double white,
  }) {
    return ColorMixer.mix(
      cyanMl: cyan,
      magentaMl: magenta,
      yellowMl: yellow,
      blackMl: black,
      whiteMl: white,
    );
  }

  double calculateAccuracy(Color target, Color mixed) {
    return AccuracyCalculator.calculate(target, mixed);
  }
}
