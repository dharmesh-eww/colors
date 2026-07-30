import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Warm wooden background drawn using Flame's game size
class WoodBackgroundComponent extends Component with HasGameReference<PaintBackgroundGame> {
  @override
  void render(Canvas canvas) {
    final double w = game.size.x;
    final double h = game.size.y;
    if (w <= 0 || h <= 0) return;

    final rect = Rect.fromLTWH(0, 0, w, h);

    // Main warm wood gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8B5E3C), // Deep warm wood top
          Color(0xFFA0652A), // Mid warm oak
          Color(0xFF7A4E2D), // Darker bottom shadow
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Wood grain horizontal lines (subtle lighter streaks)
    final grainPaint = Paint()..style = PaintingStyle.stroke;

    final random = Random(42); // fixed seed for consistent grain
    for (int i = 0; i < 22; i++) {
      final y = h * (i / 22.0) + random.nextDouble() * (h / 22.0);
      final alpha = 0.04 + random.nextDouble() * 0.07;
      final lighter = random.nextBool();
      grainPaint.color = (lighter ? Colors.white : Colors.black).withValues(alpha: alpha);
      grainPaint.strokeWidth = 0.8 + random.nextDouble() * 2.0;

      final path = Path();
      path.moveTo(0, y);
      double x = 0;
      while (x < w) {
        final step = 40.0 + random.nextDouble() * 60;
        final nextY = y + (random.nextDouble() - 0.5) * 4.0;
        path.lineTo(x + step, nextY);
        x += step;
      }
      canvas.drawPath(path, grainPaint);
    }

    // Subtle vignette darkening on edges
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.transparent, const Color(0xFF3B1E08).withValues(alpha: 0.45)],
        stops: const [0.55, 1.0],
        center: Alignment.center,
        radius: 0.85,
      ).createShader(rect);
    canvas.drawRect(rect, vignettePaint);
  }
}

/// Main Flame Background Engine with warm wood aesthetic
class PaintBackgroundGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xFF8B5E3C);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(WoodBackgroundComponent());
  }
}
