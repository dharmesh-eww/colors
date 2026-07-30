import 'package:flutter/material.dart';

class ColorMixer {
  /// Calculates the resulting color using a weighted average based on paint amounts in ml.
  /// 
  /// Available paints:
  /// - Red (255, 0, 0)
  /// - Green (0, 255, 0)
  /// - Blue (0, 0, 255)
  /// - White (255, 255, 255)
  /// - Black (0, 0, 0)
  ///
  /// If total amount is 0, defaults to White (255, 255, 255).
  static Color mix({
    required double redMl,
    required double greenMl,
    required double blueMl,
    required double whiteMl,
    required double blackMl,
  }) {
    final double totalMl = redMl + greenMl + blueMl + whiteMl + blackMl;

    if (totalMl <= 0.0) {
      return const Color(0xFFFFFFFF);
    }

    final double r = (redMl * 255.0 + whiteMl * 255.0 + blackMl * 0.0) / totalMl;
    final double g = (greenMl * 255.0 + whiteMl * 255.0 + blackMl * 0.0) / totalMl;
    final double b = (blueMl * 255.0 + whiteMl * 255.0 + blackMl * 0.0) / totalMl;

    final int finalR = r.round().clamp(0, 255);
    final int finalG = g.round().clamp(0, 255);
    final int finalB = b.round().clamp(0, 255);

    return Color.fromARGB(255, finalR, finalG, finalB);
  }
}
