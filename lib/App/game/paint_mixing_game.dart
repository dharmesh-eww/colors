import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DropletParticle extends PositionComponent {
  final Vector2 targetPosition;
  final Color color;
  final double radius;
  final VoidCallback onImpact;

  double age = 0;
  final double duration = 0.35;
  final Vector2 startPosition;

  DropletParticle({
    required Vector2 position,
    required this.targetPosition,
    required this.color,
    this.radius = 6.0,
    required this.onImpact,
  })  : startPosition = position.clone(),
        super(position: position, size: Vector2.all(radius * 2));

  @override
  void update(double dt) {
    super.update(dt);
    age += dt;
    final progress = (age / duration).clamp(0.0, 1.0);

    // Quadratic bezier path for arc drop
    final currentX = startPosition.x + (targetPosition.x - startPosition.x) * progress;
    final currentY = startPosition.y + (targetPosition.y - startPosition.y) * progress + sin(progress * pi) * -20;

    position = Vector2(currentX, currentY);

    if (progress >= 1.0) {
      onImpact();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Teardrop shape
    final path = Path()
      ..moveTo(radius, 0)
      ..cubicTo(radius * 2, radius * 1.5, radius * 1.8, radius * 2, radius, radius * 2)
      ..cubicTo(0.2 * radius, radius * 2, 0, radius * 1.5, radius, 0);

    canvas.drawPath(path, paint);
  }
}

class SplashRippleParticle extends PositionComponent {
  final Color color;
  double radius = 4.0;
  final double maxRadius = 35.0;
  double opacity = 1.0;

  SplashRippleParticle({
    required Vector2 position,
    required this.color,
  }) : super(position: position, size: Vector2.all(10));

  @override
  void update(double dt) {
    super.update(dt);
    radius += 60 * dt;
    opacity = (1.0 - (radius / maxRadius)).clamp(0.0, 1.0);
    if (radius >= maxRadius) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset.zero, radius, paint);
  }
}

class VictoryStarParticle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double sizeValue;
  double opacity = 1.0;
  double lifespan = 1.5;
  double age = 0;

  VictoryStarParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.sizeValue,
  }) : super(position: position, size: Vector2.all(sizeValue));

  @override
  void update(double dt) {
    super.update(dt);
    age += dt;
    position += velocity * dt;
    velocity.y += 180 * dt; // Gravity
    opacity = (1.0 - (age / lifespan)).clamp(0.0, 1.0);
    if (age >= lifespan) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sizeValue / 2, sizeValue / 2), sizeValue / 2, paint);
  }
}

class PaintMixingGame extends FlameGame {
  Color currentColor = Colors.white;
  Vector2 tileCenter = Vector2(200, 300);

  @override
  Color backgroundColor() => Colors.transparent;

  void triggerMixAnimation(Color resultColor) {
    currentColor = resultColor;
  }

  void spawnDropletStream({
    required Vector2 bottleNozzlePos,
    required Color color,
    required Vector2 targetTilePos,
  }) {
    tileCenter = targetTilePos;
    final random = Random();

    for (int i = 0; i < 3; i++) {
      final offsetTarget = Vector2(
        targetTilePos.x + (random.nextDouble() - 0.5) * 30,
        targetTilePos.y + (random.nextDouble() - 0.5) * 30,
      );

      add(
        DropletParticle(
          position: bottleNozzlePos,
          targetPosition: offsetTarget,
          color: color,
          onImpact: () {
            add(SplashRippleParticle(
              position: offsetTarget,
              color: color,
            ));
          },
        ),
      );
    }
  }

  void triggerVictoryCelebration(Color winColor) {
    final random = Random();
    final spawnX = size.x > 0 ? size.x / 2 : 200.0;
    final spawnY = size.y > 0 ? size.y / 2 : 300.0;

    final colors = [
      winColor,
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF7675),
      const Color(0xFF74B9FF),
      const Color(0xFF55E6C1),
      Colors.white,
    ];

    for (int i = 0; i < 50; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 180.0 + random.nextDouble() * 320.0;
      final vel = Vector2(cos(angle) * speed, sin(angle) * speed - 120);

      add(
        VictoryStarParticle(
          position: Vector2(spawnX, spawnY),
          velocity: vel,
          color: colors[i % colors.length],
          sizeValue: 5.0 + random.nextDouble() * 8.0,
        ),
      );
    }
  }
}
