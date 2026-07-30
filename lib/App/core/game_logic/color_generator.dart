import 'dart:math';
import 'package:flutter/material.dart';

class ColorGenerator {
  static final Random _random = Random();

  /// Generates a vibrant, fair random target color.
  /// Avoids pure black, pure white, and colors too close to [previousColor].
  static Color generateTarget({Color? previousColor}) {
    Color candidate;
    int attempts = 0;

    do {
      final int r = _random.nextInt(256);
      final int g = _random.nextInt(256);
      final int b = _random.nextInt(256);

      candidate = Color.fromARGB(255, r, g, b);
      attempts++;

      // Check constraints
      final bool isTooDark = (r < 25 && g < 25 && b < 25);
      final bool isTooLight = (r > 240 && g > 240 && b > 240);
      bool isTooClose = false;

      if (previousColor != null) {
        final double dist = _rgbDistance(candidate, previousColor);
        if (dist < 40.0) {
          isTooClose = true;
        }
      }

      if (!isTooDark && !isTooLight && !isTooClose) {
        return candidate;
      }
    } while (attempts < 100);

    return candidate;
  }

  static double _rgbDistance(Color c1, Color c2) {
    final double dr = (c1.r * 255 - c2.r * 255);
    final double dg = (c1.g * 255 - c2.g * 255);
    final double db = (c1.b * 255 - c2.b * 255);
    return sqrt(dr * dr + dg * dg + db * db);
  }
}
