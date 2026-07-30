import 'package:flutter/material.dart';

class ColorCardWidget extends StatelessWidget {
  final String title;
  final Color color;

  const ColorCardWidget({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final int r = (color.r * 255.0).round();
    final int g = (color.g * 255.0).round();
    final int b = (color.b * 255.0).round();

    final String rgbText = 'RGB($r, $g, $b)';
    final bool isTarget = title.toLowerCase().contains('target');
    final bool isWhiteSwatch = (r > 240 && g > 240 && b > 240);

    // Unity Casual Game Theme Gradients
    final List<Color> panelGradient = isTarget
        ? const [Color(0xFF6C5CE7), Color(0xFF4834D4)]
        : const [Color(0xFF00CEC9), Color(0xFF0984E3)];

    final List<Color> ribbonGradient = isTarget
        ? const [Color(0xFFFF7675), Color(0xFFD63031)]
        : const [Color(0xFF00B894), Color(0xFF00897B)];

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: panelGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: panelGradient[0].withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFFD700), // Royal Golden Bevel
            width: 2.8,
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // 1. Unity 3D Game Ribbon Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ribbonGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ribbonGradient[1].withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isTarget ? Icons.extension_rounded : Icons.palette_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: Color(0xFF2C3E50),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. 3D Beveled Paint Swatch Window with Glass Reflection
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isWhiteSwatch
                        ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                        : color.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: isWhiteSwatch
                      ? const Color(0xFFFFD700)
                      : Colors.white,
                  width: isWhiteSwatch ? 3.0 : 2.5,
                ),
              ),
              child: Stack(
                children: [
                  // Glossy Specular Glass Reflection Arc across Top
                  Positioned(
                    top: 4,
                    left: 8,
                    right: 8,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.55),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(14),
                          bottom: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  // Inset Bevel Shadow Rim
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 3. Unity Game Stat Pill (RGB Readout)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Text(
                rgbText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Color(0xFF2C3E50),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
