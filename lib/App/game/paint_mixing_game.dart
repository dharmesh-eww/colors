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
  double _dropletTimer = 0.0;

  void start({
    required Vector2 startPos,
    required Vector2 targetPos,
    required Color color,
  }) {
    this.startPos = startPos;
    this.targetPos = targetPos;
    this.color = color;
    active = true;
    animationTime = 0.0;
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

  /// Calculates Cubic Bezier control points for a smooth, natural liquid pouring parabolic arc.
  (Vector2, Vector2) _getControlPoints() {
    final double dx = targetPos.x - startPos.x;
    final double dy = targetPos.y - startPos.y;

    // Control point 1: projects outward/upward from bottle nozzle spout depending on horizontal offset
    final double arcDir = dx < -10 ? -40.0 : (dx > 10 ? 40.0 : -25.0);
    final double cp1x = startPos.x + arcDir;
    final double cp1y = startPos.y - min(45.0, max(20.0, dy.abs() * 0.25));

    // Control point 2: pulls downward into target under gravity acceleration
    final double cp2x = targetPos.x - (dx * 0.10);
    final double cp2y = targetPos.y - max(40.0, dy * 0.40);

    return (Vector2(cp1x, cp1y), Vector2(cp2x, cp2y));
  }

  /// Evaluates a point along the cubic Bezier curve at parameter [t] (0.0 to 1.0).
  Vector2 getPointAt(double t) {
    final (cp1, cp2) = _getControlPoints();
    final double u = 1.0 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;

    final double x = uuu * startPos.x +
        3 * uu * t * cp1.x +
        3 * u * tt * cp2.x +
        ttt * targetPos.x;

    final double y = uuu * startPos.y +
        3 * uu * t * cp1.y +
        3 * u * tt * cp2.y +
        ttt * targetPos.y;

    return Vector2(x, y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!active) return;

    animationTime += dt;
    _rippleTimer += dt;
    _dropletTimer += dt;

    // Spawn splash ripples & splash particles at target position every 0.06s
    if (_rippleTimer >= 0.06) {
      _rippleTimer = 0;
      final random = Random();
      final offsetPos = Vector2(
        targetPos.x + (random.nextDouble() - 0.5) * 22,
        targetPos.y + (random.nextDouble() - 0.5) * 14,
      );
      parent?.add(SplashRippleParticle(
        position: offsetPos,
        color: color,
      ));

      // Upward splash droplet burst at impact point
      for (int i = 0; i < 2; i++) {
        final angle = (random.nextDouble() - 0.5) * pi * 0.85 - pi / 2;
        final speed = 45.0 + random.nextDouble() * 95.0;
        parent?.add(LiquidSplashDroplet(
          position: Vector2(targetPos.x, targetPos.y),
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          color: color,
          radius: 2.0 + random.nextDouble() * 3.2,
        ));
      }
    }

    // Spawn stream flow droplets along the parabolic path
    if (_dropletTimer >= 0.04) {
      _dropletTimer = 0;
      final random = Random();
      final startT = random.nextDouble() * 0.15;
      parent?.add(PathFlowDroplet(
        streamComponent: this,
        color: color,
        startT: startT,
        speed: 2.0 + random.nextDouble() * 0.8,
        radius: 2.2 + random.nextDouble() * 2.8,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!active || (startPos.x == 0 && startPos.y == 0)) return;

    final (cp1, cp2) = _getControlPoints();

    final streamPath = Path()
      ..moveTo(startPos.x, startPos.y)
      ..cubicTo(cp1.x, cp1.y, cp2.x, cp2.y, targetPos.x, targetPos.y);

    final highlightPath = Path()
      ..moveTo(startPos.x - 1.8, startPos.y - 1.2)
      ..cubicTo(cp1.x - 1.8, cp1.y - 1.2, cp2.x - 1.8, cp2.y - 1.2, targetPos.x - 1.8, targetPos.y - 1.2);

    // 1. Soft fluid aura glow layer
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(streamPath, glowPaint);

    // 2. Main fluid body
    final bodyPaint = Paint()
      ..color = color.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(streamPath, bodyPaint);

    // 3. Inner fluid core with extra intensity
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(streamPath, corePaint);

    // 4. Specular liquid shine highlight along curve
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // 5. Animated liquid bulges/pulses sliding continuously down the curve
    final double pulse1T = (animationTime * 2.8) % 1.0;
    final double pulse2T = (animationTime * 2.8 + 0.5) % 1.0;

    final p1 = getPointAt(pulse1T);
    final p2 = getPointAt(pulse2T);

    final pulsePaint = Paint()
      ..color = color.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(p1.x, p1.y), 5.2, pulsePaint);
    canvas.drawCircle(Offset(p2.x, p2.y), 4.5, pulsePaint);

    // White specular sheen on liquid pulse
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(p1.x - 1.2, p1.y - 1.2), 2.2, shinePaint);
    canvas.drawCircle(Offset(p2.x - 1.0, p2.y - 1.0), 1.8, shinePaint);
  }
}

class SplashRippleParticle extends PositionComponent {
  final Color color;
  double radius = 3.0;
  final double maxRadius = 36.0;
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
      ..color = color.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(Offset.zero, radius, paint);
  }
}

class LiquidSplashDroplet extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  final double radius;
  double opacity = 1.0;
  double age = 0;
  final double maxAge = 0.45;

  LiquidSplashDroplet({
    required Vector2 position,
    required this.velocity,
    required this.color,
    required this.radius,
  }) : super(position: position, size: Vector2.all(radius * 2));

  @override
  void update(double dt) {
    super.update(dt);
    age += dt;
    position += velocity * dt;
    velocity.y += 240 * dt; // Gravity effect on splash droplets
    opacity = (1.0 - (age / maxAge)).clamp(0.0, 1.0);
    if (age >= maxAge) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.92)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius, radius), radius, paint);

    final shine = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(radius * 0.6, radius * 0.6), radius * 0.4, shine);
  }
}

class PathFlowDroplet extends Component {
  final LiquidStreamComponent streamComponent;
  final Color color;
  double currentT;
  final double speed;
  final double radius;

  PathFlowDroplet({
    required this.streamComponent,
    required this.color,
    required double startT,
    required this.speed,
    required this.radius,
  }) : currentT = startT;

  @override
  void update(double dt) {
    super.update(dt);
    if (!streamComponent.active) {
      removeFromParent();
      return;
    }
    currentT += speed * dt;
    if (currentT >= 1.0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!streamComponent.active || currentT > 1.0) return;
    final pos = streamComponent.getPointAt(currentT);

    final paint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.x, pos.y), radius, paint);

    final shine = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.x - radius * 0.35, pos.y - radius * 0.35), radius * 0.45, shine);
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


