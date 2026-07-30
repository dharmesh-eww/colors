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
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Unity 3D Game Score Ribbon Banner (Positioned Standalone Above - NO OVERLAPPING)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.accuracy >= 95.0
                  ? const [Color(0xFF00B894), Color(0xFF00897B)]
                  : (widget.accuracy >= 80.0
                      ? const [Color(0xFFFF9F43), Color(0xFFE67E22)]
                      : const [Color(0xFF6C5CE7), Color(0xFF4834D4)]),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.speed_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Match ${widget.accuracy.toStringAsFixed(widget.accuracy % 1 == 0 ? 0 : 1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.8,
                  shadows: [Shadow(color: Color(0xFF2C3E50), offset: Offset(0, 1), blurRadius: 2)],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Main Restored Unity 3D Golden Cauldron Circle Mixing Vessel
        Container(
          key: widget.tileKey,
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF9F43), Color(0xFFE67E22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isWhiteLiquid
                    ? const Color(0xFFFFD700).withValues(alpha: 0.55)
                    : widget.mixedColor.withValues(alpha: 0.55),
                blurRadius: 22,
                spreadRadius: 3,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 3.5,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                final wavePhase = _waveController.value * 2 * pi;
                return Container(
                  width: 178,
                  height: 178,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEBF3FF),
                    border: Border.all(
                      color: isWhiteLiquid ? const Color(0xFFFFD700) : Colors.white,
                      width: 3.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF74B9FF).withValues(alpha: 0.35),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Stack(
                      children: [
                        // Swirling Liquid Surface inside Circle Cauldron
                        CustomPaint(
                          size: const Size(178, 178),
                          painter: LiquidWavePainter(color: widget.mixedColor, phase: wavePhase),
                        ),

                        // Specular Glass Reflection Overlay
                        Positioned(
                          top: 14,
                          left: 24,
                          child: Container(
                            width: 48,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.65),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LiquidWavePainter extends CustomPainter {
  final Color color;
  final double phase;

  LiquidWavePainter({required this.color, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.3 + sin((x / size.width) * 2 * pi + phase) * 6;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Dynamic wave highlight line
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final highlightPath = Path();
    highlightPath.moveTo(0, size.height * 0.3);
    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.3 + sin((x / size.width) * 2 * pi + phase) * 6;
      highlightPath.lineTo(x, y);
    }
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.color != color;
  }
}
