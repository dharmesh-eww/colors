import 'package:flutter/material.dart';
import '../game_logic/color_generator.dart';
import '../game_logic/color_mixer.dart';
import '../game_logic/accuracy_calculator.dart';

class ColorRepository {
  Color generateTargetColor({Color? previousColor}) {
    return ColorGenerator.generateTarget(previousColor: previousColor);
  }

  Color mixPaints({
    required double red,
    required double green,
    required double blue,
    required double white,
    required double black,
  }) {
    return ColorMixer.mix(
      redMl: red,
      greenMl: green,
      blueMl: blue,
      whiteMl: white,
      blackMl: black,
    );
  }

  double calculateAccuracy(Color target, Color mixed) {
    return AccuracyCalculator.calculate(target, mixed);
  }
}
