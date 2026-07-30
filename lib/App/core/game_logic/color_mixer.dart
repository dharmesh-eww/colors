import 'package:flutter/material.dart';

class ColorMixer {
  /// Calculates the resulting color using CMYK subtractive color mixing.
  ///
  /// CMYK Primaries:
  /// - Cyan    (0, 255, 255)  → absorbs Red
  /// - Magenta (255, 0, 255)  → absorbs Green
  /// - Yellow  (255, 255, 0)  → absorbs Blue
  /// - Black   (0, 0, 0)      → absorbs all
  /// - White   (255, 255, 255)→ reflects all (lightens)
  ///
  /// If total amount is 0, defaults to White (255, 255, 255).
  static Color mix({
    required double cyanMl,
    required double magentaMl,
    required double yellowMl,
    required double blackMl,
    required double whiteMl,
  }) {
    final double totalMl = cyanMl + magentaMl + yellowMl + blackMl + whiteMl;

    if (totalMl <= 0.0) {
      return const Color(0xFFFFFFFF);
    }

    // Normalize amounts to fractions of total
    final double c = cyanMl / totalMl;
    final double m = magentaMl / totalMl;
    final double y = yellowMl / totalMl;
    final double k = blackMl / totalMl;
    final double w = whiteMl / totalMl;

    // CMYK subtractive: start from white (255,255,255), subtract absorbed channels
    // Cyan absorbs red, Magenta absorbs green, Yellow absorbs blue
    // Black absorbs all. White adds back luminance.
    final double absorptionR = c + k;
    final double absorptionG = m + k;
    final double absorptionB = y + k;

    // Base RGB from subtractive model, clamped
    double r = (1.0 - absorptionR.clamp(0.0, 1.0)) * 255.0;
    double g = (1.0 - absorptionG.clamp(0.0, 1.0)) * 255.0;
    double b = (1.0 - absorptionB.clamp(0.0, 1.0)) * 255.0;

    // White tints the result upward
    r = (r + w * (255.0 - r)).clamp(0.0, 255.0);
    g = (g + w * (255.0 - g)).clamp(0.0, 255.0);
    b = (b + w * (255.0 - b)).clamp(0.0, 255.0);

    return Color.fromARGB(255, r.round(), g.round(), b.round());
  }
}
