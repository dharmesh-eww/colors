import 'dart:math';
import 'package:flutter/material.dart';

class AccuracyCalculator {
  static const double _maxRgbDistance = 441.6729559300637; // sqrt(255^2 * 3)

  /// Calculates accuracy percentage (0.0% - 100.0%) between target and generated colors.
  static double calculate(Color target, Color generated) {
    final double tr = target.r * 255.0;
    final double tg = target.g * 255.0;
    final double tb = target.b * 255.0;

    final double gr = generated.r * 255.0;
    final double gg = generated.g * 255.0;
    final double gb = generated.b * 255.0;

    final double dr = tr - gr;
    final double dg = tg - gg;
    final double db = tb - gb;

    final double distance = sqrt(dr * dr + dg * dg + db * db);
    final double accuracy = (1.0 - (distance / _maxRgbDistance)) * 100.0;

    return accuracy.clamp(0.0, 100.0);
  }
}
