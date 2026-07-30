import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Layer 1: Top-to-Bottom 3-Color Gradient Background Component
class TopToBottomGradientBackgroundComponent extends Component {
  @override
  void render(Canvas canvas) {
    final double w = canvas.getLocalClipBounds().width;
    final double h = canvas.getLocalClipBounds().height;
    if (w <= 0 || h <= 0) return;

    final rect = Rect.fromLTWH(0, 0, w, h);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFEBF3FF), // Top: Soft Sky Blue
          Color(0xFFF6E8FF), // Middle: Pastel Lavender Pink
          Color(0xFFFAFAFC), // Bottom: Off-White Studio
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }
}

/// Layer 2: Wall Paint Splash & Blob Component (Artistic Splatters on Wall)
class WallPaintBlobComponent extends PositionComponent {
  final Color color;
  final double radius;

  WallPaintBlobComponent({
    required Vector2 position,
    required this.radius,
    required this.color,
  }) : super(position: position, size: Vector2.all(radius * 2));

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.save();
    canvas.translate(radius, radius);

    // Main Organic Paint Blob Body
    final mainPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, -radius)
      ..cubicTo(radius * 0.9, -radius * 0.8, radius * 1.1, radius * 0.4, radius * 0.6, radius * 0.9)
      ..cubicTo(
        radius * 0.2,
        radius * 1.1,
        -radius * 0.7,
        radius * 0.8,
        -radius * 0.9,
        radius * 0.3,
      )
      ..cubicTo(-radius * 1.1, -radius * 0.3, -radius * 0.6, -radius * 0.9, 0, -radius)
      ..close();

    // Soft Shadow on Wall
    canvas.drawPath(
      path.shift(const Offset(3, 4)),
      Paint()
        ..color = const Color(0xFF74B9FF).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawPath(path, mainPaint);

    // Mini Splash Droplets around Blob
    final dropletPaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius * 1.2, -radius * 0.4), radius * 0.18, dropletPaint);
    canvas.drawCircle(Offset(-radius * 1.1, radius * 0.6), radius * 0.14, dropletPaint);
    canvas.drawCircle(Offset(radius * 0.3, radius * 1.25), radius * 0.16, dropletPaint);

    // Glossy Specular Highlight on Paint Blob
    canvas.drawCircle(
      Offset(-radius * 0.35, -radius * 0.35),
      radius * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.6),
    );

    canvas.restore();
  }
}

/// Layer 5: Compact Glossy Hanging Paint Drops with Fall & Bounce Physics
class HangingPaintDropComponent extends PositionComponent {
  final Color color;
  final double dropXFraction;
  double maxScreenHeight;
  double maxScreenWidth;
  final double delaySeconds;

  double _time = 0;
  double _dropY = 0;
  double _stretch = 1.0;
  bool _isFalling = false;

  HangingPaintDropComponent({
    required this.dropXFraction,
    required this.color,
    required this.maxScreenHeight,
    required this.maxScreenWidth,
    this.delaySeconds = 0.0,
  }) : super(position: Vector2(dropXFraction * maxScreenWidth, 0), size: Vector2(20, 26));

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    if (_time < delaySeconds) return;

    final cycleTime = (_time - delaySeconds) % 4.0;

    position.x = dropXFraction * (maxScreenWidth > 0 ? maxScreenWidth : 400.0);

    if (cycleTime < 2.3) {
      _isFalling = false;
      _dropY = 0;
      _stretch = 1.0 + (cycleTime / 2.3) * 0.45;
    } else {
      _isFalling = true;
      final fallProgress = (cycleTime - 2.3) / 1.7;
      _dropY = fallProgress * fallProgress * (maxScreenHeight > 0 ? maxScreenHeight : 800.0);
      _stretch = 1.25;
    }

    position.y = _dropY;
  }

  @override
  void render(Canvas canvas) {
    if (_time < delaySeconds) return;
    super.render(canvas);

    canvas.save();
    canvas.scale(1.0 / _stretch, _stretch);

    // Compact 3D Glossy Tear-drop Path
    final path = Path()
      ..moveTo(10, 0)
      ..cubicTo(20, 13, 20, 21, 10, 26)
      ..cubicTo(0, 21, 0, 13, 10, 0)
      ..close();

    // Soft Shadow on Wall
    canvas.drawPath(
      path.shift(const Offset(2, 3)),
      Paint()
        ..color = const Color(0xFF74B9FF).withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    final dropPaint = Paint()
      ..color = color.withValues(alpha: _isFalling ? 0.85 : 0.98)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, dropPaint);

    // Specular Highlight Arc
    final specPath = Path()
      ..moveTo(11, 4)
      ..cubicTo(16, 12, 16, 18, 11, 21)
      ..cubicTo(8, 18, 8, 12, 11, 4)
      ..close();

    final specPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    canvas.drawPath(specPath, specPaint);

    canvas.restore();
  }
}

/// Main Flame Background Engine on 3-Color Top-to-Bottom Gradient Canvas
class PaintBackgroundGame extends FlameGame {
  final List<HangingPaintDropComponent> _drops = [];

  @override
  Color backgroundColor() => const Color(0xFFEBF3FF);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    for (var d in _drops) {
      d.maxScreenWidth = size.x;
      d.maxScreenHeight = size.y;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sizeX = size.x > 0 ? size.x : 400.0;
    final sizeY = size.y > 0 ? size.y : 800.0;

    // Layer 1: Top-to-Bottom 3-Color Gradient Background
    add(TopToBottomGradientBackgroundComponent());

    // Layer 2: Color Paint Splashes & Blobs on Wall
    add(
      WallPaintBlobComponent(
        position: Vector2(sizeX * 0.05, sizeY * 0.1),
        radius: 45,
        color: const Color(0xFFFF7675), // Red
      ),
    );

    add(
      WallPaintBlobComponent(
        position: Vector2(sizeX * 0.78, sizeY * 0.18),
        radius: 52,
        color: const Color(0xFF74B9FF), // Blue
      ),
    );

    add(
      WallPaintBlobComponent(
        position: Vector2(sizeX * 0.08, sizeY * 0.72),
        radius: 48,
        color: const Color(0xFF55E6C1), // Mint Green
      ),
    );

    add(
      WallPaintBlobComponent(
        position: Vector2(sizeX * 0.75, sizeY * 0.76),
        radius: 42,
        color: const Color(0xFFFDCB6E), // Yellow
      ),
    );

    add(
      WallPaintBlobComponent(
        position: Vector2(sizeX * 0.4, sizeY * 0.45),
        radius: 38,
        color: const Color(0xFFA29BFE), // Purple
      ),
    );
  }
}
