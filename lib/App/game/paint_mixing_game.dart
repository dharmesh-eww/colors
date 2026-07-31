import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class LiquidStreamComponent extends Component {
  Vector2 startPos = Vector2.zero();
  Vector2 targetPos = Vector2.zero();
  Color color = Colors.transparent;
  bool active = false;
  double animationTime = 0.0;
  double _rippleTimer = 0.0;

  void start({
    required Vector2 startPos,
    required Vector2 targetPos,
    required Color color,
  }) {
    this.startPos = startPos;
    this.targetPos = targetPos;
    this.color = color;
    active = true;
  }

  void updatePosition({
    required Vector2 startPos,
    required Vector2 targetPos,
  }) {
    this.startPos = startPos;
    this.targetPos = targetPos;
  }

  void stop() {
    active = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!active) return;

    animationTime += dt;
    _rippleTimer += dt;

    // Spawn splash ripples at target position every 0.08s
    if (_rippleTimer >= 0.08) {
      _rippleTimer = 0;
      final random = Random();
      final offsetPos = Vector2(
        targetPos.x + (random.nextDouble() - 0.5) * 16,
        targetPos.y + (random.nextDouble() - 0.5) * 10,
      );
      parent?.add(SplashRippleParticle(
        position: offsetPos,
        color: color,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!active || (startPos.x == 0 && startPos.y == 0)) return;

    final double startX = startPos.x;
    final double startY = startPos.y;
    final double endX = targetPos.x;
    final double endY = targetPos.y;

    // Control point for a natural liquid curve downward
    final double midX = (startX + endX) / 2;
    final double midY = max(startX, startY) < endY
        ? (startY + endY) / 2 + 15
        : (startY + endY) / 2;

    final streamPath = Path()
      ..moveTo(startX, startY)
      ..quadraticBezierTo(midX, midY, endX, endY);

    final highlightPath = Path()
      ..moveTo(startX - 1.5, startY)
      ..quadraticBezierTo(midX - 1.5, midY, endX - 1.5, endY);

    // 1. Outer liquid glow aura
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(streamPath, glowPaint);

    // 2. Main fluid body
    final bodyPaint = Paint()
      ..color = color.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(streamPath, bodyPaint);

    // 3. Inner liquid specular highlight core
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // 4. Animated liquid pulse effect along stream
    final double distance = startPos.distanceTo(targetPos);
    if (distance > 20) {
      final pulsePhase = (animationTime * 4.0) % 1.0;
      final pulseX = startX + (endX - startX) * pulsePhase;
      final pulseY = startY + (endY - startY) * pulsePhase;
      canvas.drawCircle(
        Offset(pulseX, pulseY),
        3.5,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill,
      );
    }
  }
}

class SplashRippleParticle extends PositionComponent {
  final Color color;
  double radius = 3.0;
  final double maxRadius = 32.0;
  double opacity = 1.0;

  SplashRippleParticle({
    required Vector2 position,
    required this.color,
  }) : super(position: position, size: Vector2.all(10));

  @override
  void update(double dt) {
    super.update(dt);
    radius += 55 * dt;
    opacity = (1.0 - (radius / maxRadius)).clamp(0.0, 1.0);
    if (radius >= maxRadius) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

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
  LiquidStreamComponent? _activeStream;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _activeStream = LiquidStreamComponent();
    add(_activeStream!);
  }

  void triggerMixAnimation(Color resultColor) {
    currentColor = resultColor;
  }

  void startLiquidPour({
    required Vector2 bottleNozzlePos,
    required Color color,
    required Vector2 targetTilePos,
  }) {
    tileCenter = targetTilePos;
    _activeStream?.start(
      startPos: bottleNozzlePos,
      targetPos: targetTilePos,
      color: color,
    );
  }

  void updateLiquidPour({
    required Vector2 bottleNozzlePos,
    required Vector2 targetTilePos,
  }) {
    tileCenter = targetTilePos;
    _activeStream?.updatePosition(
      startPos: bottleNozzlePos,
      targetPos: targetTilePos,
    );
  }

  void stopLiquidPour() {
    _activeStream?.stop();
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

