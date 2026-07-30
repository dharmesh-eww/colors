import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../game/paint_background_game.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

// ignore: must_be_immutable
class HomeScreen extends StatekitView<HomeScreenController>
    implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _HomeScreenBody(controller: controller);
  }

  @override
  void doSomething() {}
}

class _HomeScreenBody extends StatefulWidget {
  final HomeScreenController controller;
  const _HomeScreenBody({required this.controller});

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bottleFloatController;
  late AnimationController _shimmerController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;

  late PaintBackgroundGame _bgGame;

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();

    // Play button pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Decorative ink bottle floating
    _bottleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _bottleFloatController, curve: Curves.easeInOut),
    );

    // Glow shimmer on title
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bottleFloatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: Stack(
        children: [
          // ── Layer 1: Warm Wood Background ──────────────────────────────
          Positioned.fill(child: GameWidget(game: _bgGame)),

          // ── Layer 2: Floating decorative ink bottles (CustomPaint) ─────
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Left ink bottle (Cyan)
                  Positioned(
                    top: screenHeight * 0.18 + _floatAnimation.value,
                    left: -10,
                    child: Transform.rotate(
                      angle: 0.18 + sin(_floatAnimation.value * 0.1) * 0.04,
                      child: const _DecorInkBottle(
                        color: Color(0xFF00FFFF),
                        size: 80,
                      ),
                    ),
                  ),
                  // Right ink bottle (Magenta)
                  Positioned(
                    top: screenHeight * 0.14 - _floatAnimation.value,
                    right: -12,
                    child: Transform.rotate(
                      angle: -0.22 + cos(_floatAnimation.value * 0.1) * 0.04,
                      child: const _DecorInkBottle(
                        color: Color(0xFFFF00FF),
                        size: 75,
                      ),
                    ),
                  ),
                  // Bottom-left small bottle (Yellow)
                  Positioned(
                    bottom: screenHeight * 0.28 - _floatAnimation.value * 0.6,
                    left: 5,
                    child: Transform.rotate(
                      angle: 0.12,
                      child: const _DecorInkBottle(
                        color: Color(0xFFFFFF00),
                        size: 60,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Layer 3: Main UI Content ────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 28),

                // ── Logo + Title ──────────────────────────────────────────
                _LogoBadge(shimmerAnimation: _shimmerAnimation),

                const SizedBox(height: 14),

                // ── Title ─────────────────────────────────────────────────
                const Text(
                  'Color Craft',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF5DEB3),
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                          color: Color(0xFF3B1E08),
                          offset: Offset(0, 3),
                          blurRadius: 8),
                      Shadow(
                          color: Color(0xFFFFD700),
                          offset: Offset(0, -1),
                          blurRadius: 6),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Subtitle badge ────────────────────────────────────────
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A055), Color(0xFFB87333)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Mix · Match · Paint Puzzle',
                    style: TextStyle(
                      color: Color(0xFFFFF8E1),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const Spacer(),

                // ── Central Mixing Station Preview ────────────────────────
                _MixingStationPreview(floatAnimation: _floatAnimation),

                const Spacer(),

                // ── PLAY Button ───────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: GestureDetector(
                    onTap: () =>
                        widget.controller.playButtonClicked(context),
                    child: Container(
                      width: 210,
                      height: 66,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFD4A055)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(33),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color:
                                const Color(0xFF3B1E08).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF3B1E08).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 30,
                              color: Color(0xFF3B1E08),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'PLAY',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF3B1E08),
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                    color: Color(0x33FFFFFF),
                                    offset: Offset(0, 1),
                                    blurRadius: 2),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Mode chips ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeChip('Easy', isSelected: true),
                    const SizedBox(width: 8),
                    _buildModeChip('Medium'),
                    const SizedBox(width: 8),
                    _buildModeChip('Hard'),
                    const SizedBox(width: 8),
                    _buildModeChip('2 Min ⏱'),
                  ],
                ),

                const Spacer(),

                // ── Bottom version ────────────────────────────────────────
                Text(
                  'v1.0 · Color Lab Edition',
                  style: TextStyle(
                    color:
                        const Color(0xFFF5DEB3).withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, {bool isSelected = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFFD4A055), Color(0xFF8B5E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected
            ? null
            : const Color(0xFF3B1E08).withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFFD700)
              : const Color(0xFFD4A055).withValues(alpha: 0.4),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? const Color(0xFFFFF8E1)
              : const Color(0xFFF5DEB3).withValues(alpha: 0.75),
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Logo Badge — glowing ink drop icon
// ──────────────────────────────────────────────────────────────────────────────
class _LogoBadge extends StatelessWidget {
  final Animation<double> shimmerAnimation;
  const _LogoBadge({required this.shimmerAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A055), Color(0xFF8B5E3C), Color(0xFF5D3A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700)
                    .withValues(alpha: 0.3 + shimmerAnimation.value * 0.3),
                blurRadius: 20 + shimmerAnimation.value * 14,
                spreadRadius: 2 + shimmerAnimation.value * 4,
              ),
              const BoxShadow(
                color: Color(0xFF3B1E08),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Beaker icon
              const Icon(Icons.science_rounded, size: 46, color: Color(0xFFF5DEB3)),
              // Small color dots around
              Positioned(
                top: 18,
                right: 14,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 14,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF00FF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Central mixing station preview — beaker with CMYK color swatches
// ──────────────────────────────────────────────────────────────────────────────
class _MixingStationPreview extends StatelessWidget {
  final Animation<double> floatAnimation;
  const _MixingStationPreview({required this.floatAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatAnimation.value * 0.4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Glass mixing station ──────────────────────────────────
              Container(
                width: 220,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4A055),
                      Color(0xFF8B5E3C),
                      Color(0xFF5D3A1A),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border:
                      Border.all(color: const Color(0xFFFFD700), width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B1E08).withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glass chamber outline
                    Positioned(
                      top: 16,
                      child: Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Beaker body (simplified preview)
                            Positioned(
                              bottom: 20,
                              child: CustomPaint(
                                size: const Size(70, 100),
                                painter: _HomeBeakerPainter(),
                              ),
                            ),
                            // Glow text
                            Positioned(
                              bottom: 6,
                              child: Text(
                                'MIX IT!',
                                style: TextStyle(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top glow light
                    Positioned(
                      top: 10,
                      child: Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFF8E1).withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CMYK Color swatches ──────────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorDot(const Color(0xFF00FFFF), 'C'),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFFF00FF), 'M'),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFFFFF00), 'Y'),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFF1A1A1A), 'K'),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFF0F0F0), 'W'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorDot(Color color, String label) {
    final bool isDark =
        color.computeLuminance() < 0.12 || color == const Color(0xFF1A1A1A);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.3 : 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF5DEB3),
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Simplified beaker for home screen preview
class _HomeBeakerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final topW = w * 0.90;
    final botW = w * 0.72;
    final topX = (w - topW) / 2;
    final botX = (w - botW) / 2;

    final beakerPath = Path()
      ..moveTo(topX + 10, 0)
      ..lineTo(topX + topW - 10, 0)
      ..quadraticBezierTo(topX + topW, 0, topX + topW, 10)
      ..lineTo(botX + botW, h - 12)
      ..quadraticBezierTo(botX + botW, h, botX + botW - 10, h)
      ..lineTo(botX + 10, h)
      ..quadraticBezierTo(botX, h, botX, h - 12)
      ..lineTo(topX, 10)
      ..quadraticBezierTo(topX, 0, topX + 10, 0)
      ..close();

    canvas.save();
    canvas.clipPath(beakerPath);

    // Glass bg
    canvas.drawPath(
      beakerPath,
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    // Liquid fill (teal demo)
    final liquidPath = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      liquidPath,
      Paint()..color = const Color(0xFF008080).withValues(alpha: 0.85),
    );

    canvas.restore();

    // Beaker border
    canvas.drawPath(
      beakerPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Glass highlight
    canvas.drawLine(
      Offset(topX + 5, 12),
      Offset(botX + 4, h - 16),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeBeakerPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// Decorative floating ink bottle (CustomPaint) — no images used
// ──────────────────────────────────────────────────────────────────────────────
class _DecorInkBottle extends StatelessWidget {
  final Color color;
  final double size;
  const _DecorInkBottle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.65,
      child: SizedBox(
        width: size,
        height: size * 1.4,
        child: CustomPaint(
          painter: _DecorBottlePainter(color: color),
        ),
      ),
    );
  }
}

class _DecorBottlePainter extends CustomPainter {
  final Color color;
  const _DecorBottlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Cork
    final corkW = w * 0.36;
    final corkX = (w - corkW) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(corkX, 0, corkW, h * 0.10),
          const Radius.circular(3)),
      Paint()..color = const Color(0xFFD4A055),
    );

    // Neck
    final neckW = w * 0.38;
    final neckX = (w - neckW) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(neckX, h * 0.10, neckW, h * 0.14),
          const Radius.circular(2)),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );

    // Body
    final bodyY = h * 0.24;
    final bodyH = h - bodyY;
    final bodyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, bodyY, w, bodyH), const Radius.circular(10));

    // Glass body
    canvas.drawRRect(
      bodyRect,
      Paint()..color = Colors.white.withValues(alpha: 0.15),
    );

    // Liquid fill
    canvas.save();
    canvas.clipRRect(bodyRect);
    canvas.drawRect(
      Rect.fromLTWH(0, bodyY + bodyH * 0.15, w, bodyH * 0.85),
      Paint()..color = color.withValues(alpha: 0.75),
    );
    canvas.restore();

    // Border
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Highlight
    canvas.drawLine(
      Offset(w * 0.18, bodyY + 8),
      Offset(w * 0.18, bodyY + bodyH * 0.55),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _DecorBottlePainter oldDelegate) =>
      oldDelegate.color != color;
}