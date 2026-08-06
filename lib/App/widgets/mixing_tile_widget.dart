import 'dart:math';
import 'package:flutter/material.dart';

class MixingTileWidget extends StatefulWidget {
  final Color mixedColor;
  final double accuracy;
  final GlobalKey tileKey;

  const MixingTileWidget({
    super.key,
    required this.mixedColor,
    required this.accuracy,
    required this.tileKey,
  });

  @override
  State<MixingTileWidget> createState() => _MixingTileWidgetState();
}

class _MixingTileWidgetState extends State<MixingTileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int r = (widget.mixedColor.r * 255.0).round();
    final int g = (widget.mixedColor.g * 255.0).round();
    final int b = (widget.mixedColor.b * 255.0).round();
    final bool isWhiteLiquid = (r > 240 && g > 240 && b > 240);

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final wavePhase = _waveController.value * 2 * pi;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Accuracy text ───────────────────────────────────────────────
            Text(
              'Match ${widget.accuracy.toStringAsFixed(widget.accuracy % 1 == 0 ? 0 : 1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.8,
                shadows: [Shadow(color: Color(0xFF000000), offset: Offset(0, 1), blurRadius: 4)],
              ),
            ),

            const SizedBox(height: 14),

            // ── Lab Mixing Station ──────────────────────────────────────────
            SizedBox(
              width: 230,
              height: 270,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing platform at bottom
                  Positioned(
                    bottom: 0,
                    child: _GlowingPlatform(
                      color: isWhiteLiquid ? const Color(0xFFFFD700) : widget.mixedColor,
                    ),
                  ),

                  // Cylindrical glass chamber behind beaker
                  Positioned(top: 0, left: 20, right: 20, bottom: 22, child: _GlassChamber()),

                  // Beaker with liquid (DragTarget key area)
                  Positioned(
                    bottom: 28,
                    child: SizedBox(
                      key: widget.tileKey,
                      width: 160,
                      height: 190,
                      child: CustomPaint(
                        painter: BeakerPainter(
                          liquidColor: widget.mixedColor,
                          wavePhase: wavePhase,
                          isWhite: isWhiteLiquid,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Glowing circular platform below beaker
// ──────────────────────────────────────────────────────────────────────────────
class _GlowingPlatform extends StatelessWidget {
  final Color color;
  const _GlowingPlatform({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.5), color.withValues(alpha: 0.15), Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Center(
        child: Container(
          height: 10,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: color.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Glass Cylindrical Chamber (tower around beaker)
// ──────────────────────────────────────────────────────────────────────────────
class _GlassChamber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GlassChamberPainter());
  }
}

class _GlassChamberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── 1. Glass Chamber Body (rounded rect glass tube) ──────────────────────
    final chamberRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 4, w, h - 4),
      const Radius.circular(22),
    );

    // Glass body fill (very translucent crystal glass)
    canvas.drawRRect(
      chamberRect,
      Paint()
        ..color = const Color(0xFFD6EAF8).withValues(alpha: 0.16)
        ..style = PaintingStyle.fill,
    );

    // Glass border outline
    canvas.drawRRect(
      chamberRect,
      Paint()
        ..color = const Color(0xFFE3F2FD).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Inner rim highlights (left and right glass sheen)
    final leftHighlight = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 14, 6, h - 35),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      leftHighlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.fill,
    );

    final rightHighlight = RRect.fromRectAndRadius(
      Rect.fromLTWH(w - 9, 14, 6, h - 35),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      rightHighlight,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill,
    );

    // ── 2. Light Cone Projection from Top Cap ────────────────────────────────
    const glowColor = Color(0xFFFFECB3); // Warm golden-amber light
    final lightRect = Rect.fromLTWH(w * 0.10, 20, w * 0.80, h * 0.50);
    canvas.drawOval(
      lightRect,
      Paint()
        ..shader = RadialGradient(
          colors: [glowColor.withValues(alpha: 0.30), glowColor.withValues(alpha: 0.0)],
          center: const Alignment(0, -0.7),
        ).createShader(lightRect),
    );

    // ── 3. Sleek Streamlined Gold/Brass Top Cap Assembly ─────────────────────

    // A. Soft Drop Shadow under top cap onto glass
    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-2, 12, w + 4, 6),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      shadowRect,
      Paint()
        ..color = const Color(0xFF3B1E08).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // B. Slim Base Flange (Lower rim of cap)
    final baseFlangeRect = Rect.fromLTWH(-3, 6, w + 6, 8);
    final baseFlangeRRect = RRect.fromRectAndRadius(baseFlangeRect, const Radius.circular(6));
    canvas.drawRRect(
      baseFlangeRRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE8C898), Color(0xFFD4A055), Color(0xFF8D6228), Color(0xFF5D4037)],
          stops: [0.0, 0.35, 0.75, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(baseFlangeRect)
        ..style = PaintingStyle.fill,
    );

    // C. Main Upper Crown Cap (Sleek low-profile top rim)
    final mainCapRect = Rect.fromLTWH(-6, -4, w + 12, 13);
    final mainCapRRect = RRect.fromRectAndRadius(mainCapRect, const Radius.circular(8));

    canvas.drawRRect(
      mainCapRRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFFFF5DF), // Top champagne sheen
            Color(0xFFF5DEB3), // Cream gold
            Color(0xFFD4A055), // Warm polished brass
            Color(0xFFB87333), // Metallic copper transition
            Color(0xFF6D4C2A), // Dark wood/brass shadow
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(mainCapRect)
        ..style = PaintingStyle.fill,
    );

    // D. Outer Gold Border for Main Cap
    canvas.drawRRect(
      mainCapRRect,
      Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // E. Inner Specular Highlight Line (Glossy reflection on main cap)
    final highlightPath = Path()
      ..moveTo(-2, -2)
      ..quadraticBezierTo(w / 2, -4, w + 2, -2);
    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // F. Inset Metallic Groove Line (Decorative band across cap)
    canvas.drawLine(
      Offset(-3, 3),
      Offset(w + 3, 3),
      Paint()
        ..color = const Color(0xFF5D4037).withValues(alpha: 0.45)
        ..strokeWidth = 0.9,
    );
    canvas.drawLine(
      Offset(-3, 4),
      Offset(w + 3, 4),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 0.7,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassChamberPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// Glass Laboratory Beaker with animated liquid
// ──────────────────────────────────────────────────────────────────────────────
class BeakerPainter extends CustomPainter {
  final Color liquidColor;
  final double wavePhase;
  final bool isWhite;

  BeakerPainter({required this.liquidColor, required this.wavePhase, required this.isWhite});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Beaker shape ──────────────────────────────────────────────────────────
    // A lab beaker: slightly wider at top, straight sides, rounded bottom
    final double topWidth = w * 0.88;
    final double bottomWidth = w * 0.72;
    final double topX = (w - topWidth) / 2;
    final double bottomX = (w - bottomWidth) / 2;
    final double beakerTop = h * 0.04;
    final double beakerBottom = h * 0.96;
    final double cornerR = 14.0;

    final beakerPath = Path()
      ..moveTo(topX + 12, beakerTop)
      ..lineTo(topX + topWidth - 12, beakerTop)
      // Top right corner
      ..quadraticBezierTo(topX + topWidth, beakerTop, topX + topWidth, beakerTop + 10)
      // Right side slanting inward
      ..lineTo(bottomX + bottomWidth, beakerBottom - cornerR)
      ..quadraticBezierTo(
        bottomX + bottomWidth,
        beakerBottom,
        bottomX + bottomWidth - cornerR,
        beakerBottom,
      )
      // Bottom
      ..lineTo(bottomX + cornerR, beakerBottom)
      ..quadraticBezierTo(bottomX, beakerBottom, bottomX, beakerBottom - cornerR)
      // Left side slanting inward
      ..lineTo(topX, beakerTop + 10)
      ..quadraticBezierTo(topX, beakerTop, topX + 12, beakerTop)
      ..close();

    // Clip all drawing to beaker shape
    canvas.save();
    canvas.clipPath(beakerPath);

    // Glass background fill
    canvas.drawPath(beakerPath, Paint()..color = const Color(0xFFE8F4F8).withValues(alpha: 0.55));

    // ── Liquid fill with wave ─────────────────────────────────────────────────
    final double liquidLevel = 0.42; // liquid fills ~42% from bottom
    final double liquidTopY = h * (1.0 - liquidLevel);

    final liquidPath = Path();
    liquidPath.moveTo(0, liquidTopY);

    // Wave on liquid surface
    for (double x = 0; x <= w; x += 3) {
      final y =
          liquidTopY +
          sin((x / w) * 2.5 * pi + wavePhase) * 5 +
          cos((x / w) * 1.8 * pi + wavePhase * 0.7) * 3;
      liquidPath.lineTo(x, y);
    }

    liquidPath.lineTo(w, h);
    liquidPath.lineTo(0, h);
    liquidPath.close();

    canvas.drawPath(
      liquidPath,
      Paint()
        ..color = isWhite
            ? const Color(0xFFF0F0F0).withValues(alpha: 0.9)
            : liquidColor.withValues(alpha: 0.88)
        ..style = PaintingStyle.fill,
    );

    // Wave surface highlight
    final waveSurfacePath = Path();
    waveSurfacePath.moveTo(0, liquidTopY);
    for (double x = 0; x <= w; x += 3) {
      final y =
          liquidTopY +
          sin((x / w) * 2.5 * pi + wavePhase) * 5 +
          cos((x / w) * 1.8 * pi + wavePhase * 0.7) * 3;
      waveSurfacePath.lineTo(x, y);
    }

    canvas.drawPath(
      waveSurfacePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    canvas.restore();

    // ── Draw beaker border (glass outline) ────────────────────────────────────
    canvas.drawPath(
      beakerPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // ── Glass highlight strips on left side ───────────────────────────────────
    final highlightPath = Path()
      ..moveTo(topX + 8, beakerTop + 14)
      ..lineTo(bottomX + 6, beakerBottom - 20);

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    // ── Spout / lip at top of beaker ──────────────────────────────────────────
    final spoutPath = Path()
      ..moveTo(topX - 4, beakerTop)
      ..lineTo(topX - 4, beakerTop - 8)
      ..quadraticBezierTo(topX + topWidth / 2, beakerTop - 14, topX + topWidth + 4, beakerTop - 8)
      ..lineTo(topX + topWidth + 4, beakerTop);

    canvas.drawPath(
      spoutPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    // ── Graduation marks on beaker ────────────────────────────────────────────
    final markPaint = Paint()
      ..color = const Color(0xFF90A4AE).withValues(alpha: 0.6)
      ..strokeWidth = 1.2;

    for (int i = 1; i <= 4; i++) {
      final markY = beakerTop + (beakerBottom - beakerTop) * i / 5;
      final markLeft = bottomX + (i % 2 == 0 ? 6 : 4);
      final markLen = i % 2 == 0 ? 16.0 : 10.0;
      canvas.drawLine(Offset(markLeft, markY), Offset(markLeft + markLen, markY), markPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BeakerPainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.liquidColor != liquidColor ||
        oldDelegate.isWhite != isWhite;
  }
}
