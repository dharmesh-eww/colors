import 'package:flutter/material.dart';

/// 100% Transparent Vector CustomPainter for 3D Paint Palette Decor
class PaintPaletteWidget extends StatelessWidget {
  final double size;
  const PaintPaletteWidget({super.key, this.size = 85.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PaintPalettePainter(),
      ),
    );
  }
}

class _PaintPalettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Outer Wooden Palette Body Path
    final path = Path()
      ..moveTo(w * 0.2, h * 0.1)
      ..cubicTo(w * 0.7, h * 0.05, w * 0.95, h * 0.3, w * 0.9, h * 0.6)
      ..cubicTo(w * 0.85, h * 0.9, w * 0.4, h * 0.95, w * 0.15, h * 0.75)
      ..cubicTo(w * 0.0, h * 0.55, w * 0.05, h * 0.2, w * 0.2, h * 0.1)
      ..close();

    // Thumb Hole Path
    final thumbHole = Path()
      ..addOval(Rect.fromLTWH(w * 0.15, h * 0.45, w * 0.18, h * 0.22));

    final paletteShape = Path.combine(
      PathOperation.difference,
      path,
      thumbHole,
    );

    // Soft Shadow (No Black)
    canvas.drawPath(
      paletteShape,
      Paint()
        ..color = const Color(0xFF74B9FF).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main Wooden Texture Gradient Fill
    final woodPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE5AA70), Color(0xFFC68B59), Color(0xFF9E6536)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(paletteShape, woodPaint);

    // Wooden Rim Highlight Border
    canvas.drawPath(
      paletteShape,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 6 Glossy Paint Spots (Red, Yellow, Blue, Green, Purple, Orange)
    final paintSpots = [
      Offset(w * 0.42, h * 0.22),
      Offset(w * 0.68, h * 0.24),
      Offset(w * 0.78, h * 0.46),
      Offset(w * 0.68, h * 0.70),
      Offset(w * 0.44, h * 0.72),
      Offset(w * 0.25, h * 0.25),
    ];

    final spotColors = [
      const Color(0xFFFF7675), // Red
      const Color(0xFFFFEAA7), // Yellow
      const Color(0xFF74B9FF), // Blue
      const Color(0xFF55E6C1), // Green
      const Color(0xFFA29BFE), // Purple
      const Color(0xFFFFBE76), // Orange
    ];

    for (int i = 0; i < paintSpots.length; i++) {
      final pos = paintSpots[i];
      final color = spotColors[i];
      final double r = w * 0.09;

      // Base Paint Spot
      canvas.drawCircle(
        pos,
        r,
        Paint()..color = color,
      );

      // Specular 3D Highlight
      canvas.drawCircle(
        pos + Offset(-r * 0.3, -r * 0.3),
        r * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.65),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 100% Transparent Vector CustomPainter for 3D Paint Brush Decor
class PaintBrushWidget extends StatelessWidget {
  final double size;
  const PaintBrushWidget({super.key, this.size = 90.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PaintBrushPainter(),
      ),
    );
  }
}

class _PaintBrushPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    canvas.save();
    // Rotate slightly for playful brush angle
    canvas.translate(w / 2, h / 2);
    canvas.rotate(0.35);
    canvas.translate(-w / 2, -h / 2);

    // 1. Brush Handle (Cyan to Blue 3D gradient)
    final handlePath = Path()
      ..moveTo(w * 0.42, h * 0.5)
      ..lineTo(w * 0.58, h * 0.5)
      ..lineTo(w * 0.54, h * 0.92)
      ..cubicTo(w * 0.52, h * 0.98, w * 0.48, h * 0.98, w * 0.46, h * 0.92)
      ..close();

    canvas.drawPath(
      handlePath,
      Paint()
        ..color = const Color(0xFF74B9FF).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final handlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(handlePath, handlePaint);

    // 2. Ferrule Metallic Ring
    final ferruleRect = RRect.fromLTRBR(
      w * 0.38,
      h * 0.40,
      w * 0.62,
      h * 0.52,
      const Radius.circular(4),
    );

    final ferrulePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFF2A1), Color(0xFFD4AF37)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(ferruleRect.outerRect);

    canvas.drawRRect(ferruleRect, ferrulePaint);

    // 3. Bristles & Wet Rainbow Paint Tip
    final bristlePath = Path()
      ..moveTo(w * 0.40, h * 0.40)
      ..cubicTo(w * 0.32, h * 0.20, w * 0.36, h * 0.05, w * 0.50, h * 0.02)
      ..cubicTo(w * 0.64, h * 0.05, w * 0.68, h * 0.20, w * 0.60, h * 0.40)
      ..close();

    final paintTip = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7675), Color(0xFFFDCB6E), Color(0xFF55E6C1), Color(0xFF74B9FF)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(bristlePath, paintTip);

    // Glossy Specular Highlight on Paint Tip
    final specPath = Path()
      ..moveTo(w * 0.46, h * 0.28)
      ..cubicTo(w * 0.42, h * 0.16, w * 0.45, h * 0.08, w * 0.50, h * 0.05)
      ..cubicTo(w * 0.48, h * 0.12, w * 0.47, h * 0.20, w * 0.46, h * 0.28)
      ..close();

    canvas.drawPath(
      specPath,
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
