import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/puzzle/puzzle_model.dart';
import '../../../game/paint_background_game.dart';
import '../../level_selection_screen/view/level_selection_screen.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

class HomeScreen extends StatekitView<HomeScreenController> implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _HomeScreenBody(controller: controller);
  }

  @override
  void playButtonClicked(BuildContext context) => controller.playButtonClicked(context);

  @override
  void settingsButtonClicked(BuildContext context) => controller.settingsButtonClicked(context);

  @override
  void dailyChallengeClicked(BuildContext context) => controller.dailyChallengeClicked(context);
}

class _HomeScreenBody extends StatefulWidget {
  final HomeScreenController controller;
  const _HomeScreenBody({required this.controller});

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> with TickerProviderStateMixin {
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

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Decorative ink bottle floating
    _bottleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _bottleFloatController, curve: Curves.easeInOut));

    // Glow shimmer on title
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));
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
    return StateBuilder<HomeScreenController>(
      controller: widget.controller,
      builder: (context, ctrl, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF8B5E3C),
          body: IndexedStack(
            index: ctrl.currentTabIndex,
            children: [
              _buildHomePlayTabContent(),
              LevelSelectionScreen(),
              const _BlankProfilePage(),
            ],
          ),
          bottomNavigationBar: _WoodenBottomNavigationBar(
            currentIndex: ctrl.currentTabIndex,
            onTap: (index) => ctrl.changeTab(index),
          ),
        );
      },
    );
  }

  Widget _buildHomePlayTabContent() {
    return Stack(
      children: [
        // ── Layer 1: Warm Wood Background ──────────────────────────────
        Positioned.fill(child: GameWidget(game: _bgGame)),
        Positioned.fill(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // ── Logo + Title ──────────────────────────────────────────
                _LogoBadge(shimmerAnimation: _shimmerAnimation),

                const SizedBox(height: 10),

                // ── Title ─────────────────────────────────────────────────
                const Text(
                  'Color Craft',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF5DEB3),
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(color: Color(0xFF3B1E08), offset: Offset(0, 3), blurRadius: 8),
                      Shadow(color: Color(0xFFFFD700), offset: Offset(0, -1), blurRadius: 6),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── Subtitle badge ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4A055), Color(0xFFB87333)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Wooden Difficulty Buttons ─────────────────────────────
                _WoodenDifficultyButtonsBar(
                  onDifficultyTap: (tier) => widget.controller.onDifficultyClicked(context, tier),
                ),

                const Spacer(),

                // ── Central Mixing Station Preview ────────────────────────
                _MixingStationPreview(floatAnimation: _floatAnimation),

                const Spacer(),

                // ── PLAY Button ───────────────────────────────────────────
                _PlayButtonWidget(
                  onTap: () => widget.controller.playButtonClicked(context),
                  pulseAnimation: _scaleAnimation,
                ),

                const Spacer(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: () => widget.controller.settingsButtonClicked(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.settings_rounded, color: Color(0xFF5D4037), size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Theme-Matched 3D Gold & Wood PLAY Button
// ──────────────────────────────────────────────────────────────────────────────
class _PlayButtonWidget extends StatefulWidget {
  final VoidCallback onTap;
  final Animation<double> pulseAnimation;

  const _PlayButtonWidget({required this.onTap, required this.pulseAnimation});

  @override
  State<_PlayButtonWidget> createState() => _PlayButtonWidgetState();
}

class _PlayButtonWidgetState extends State<_PlayButtonWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.pulseAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: 215,
            height: 68,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF5DF), // Champagne top highlight
                  Color(0xFFF5DEB3), // Cream gold
                  Color(0xFFD4A055), // Polished brass
                  Color(0xFFB87333), // Copper edge
                  Color(0xFF6D4C2A), // Warm wood base
                ],
                stops: [0.0, 0.25, 0.55, 0.82, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: const Color(0xFFFFE082).withValues(alpha: 0.9), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF3B1E08).withValues(alpha: 0.55),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5DEB3), Color(0xFFE8C898), Color(0xFFD4A055)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFF8D6228).withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Play Icon Circle Badge
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                        width: 1.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, size: 28, color: Color(0xFFFFD700)),
                  ),
                  const SizedBox(width: 12),
                  // PLAY Text
                  const Text(
                    'PLAY',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3B1E08),
                      letterSpacing: 3.5,
                      shadows: [
                        Shadow(color: Color(0x77FFFFFF), offset: Offset(0, 1), blurRadius: 2),
                        Shadow(color: Color(0x33000000), offset: Offset(0, 2), blurRadius: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                color: const Color(
                  0xFFFFD700,
                ).withValues(alpha: 0.3 + shimmerAnimation.value * 0.3),
                blurRadius: 20 + shimmerAnimation.value * 14,
                spreadRadius: 2 + shimmerAnimation.value * 4,
              ),
              const BoxShadow(color: Color(0xFF3B1E08), blurRadius: 8, offset: Offset(0, 4)),
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
                  decoration: const BoxDecoration(color: Color(0xFF00FFFF), shape: BoxShape.circle),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 14,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(color: Color(0xFFFF00FF), shape: BoxShape.circle),
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
                    colors: [Color(0xFFD4A055), Color(0xFF8B5E3C), Color(0xFF5D3A1A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
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
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.9),
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
                  _colorDot(const Color(0xFF4DD0E1)),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFFF80AB)),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFFFF176)),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFB0BEC5)),
                  const SizedBox(width: 8),
                  _colorDot(const Color(0xFFFFFFFF)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _colorDot(Color color) {
    final bool isDark = color.computeLuminance() < 0.12;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.3 : 0.5),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
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
    canvas.drawPath(beakerPath, Paint()..color = Colors.white.withValues(alpha: 0.12));

    // Liquid fill (teal demo)
    final liquidPath = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(liquidPath, Paint()..color = const Color(0xFF008080).withValues(alpha: 0.85));

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
// Daily Challenge Banner Widget — Matches reference image frame
// ──────────────────────────────────────────────────────────────────────────────
class _DailyChallengeBannerWidget extends StatefulWidget {
  final VoidCallback onTap;
  const _DailyChallengeBannerWidget({required this.onTap});

  @override
  State<_DailyChallengeBannerWidget> createState() => _DailyChallengeBannerWidgetState();
}

class _DailyChallengeBannerWidgetState extends State<_DailyChallengeBannerWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 76,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomPaint(
            painter: _DailyChallengeFramePainter(),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "TODAY'S COLOR",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFF1D6),
                        letterSpacing: 2.2,
                        height: 1.1,
                        shadows: [
                          Shadow(color: Color(0xFF381806), offset: Offset(0, 2.5), blurRadius: 4),
                          Shadow(color: Color(0xFF1E0B02), offset: Offset(0, 4), blurRadius: 6),
                        ],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'CRAFT CHALLENGE',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFF1D6),
                        letterSpacing: 2.5,
                        height: 1.1,
                        shadows: [
                          Shadow(color: Color(0xFF381806), offset: Offset(0, 2.5), blurRadius: 4),
                          Shadow(color: Color(0xFF1E0B02), offset: Offset(0, 4), blurRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Custom Painter for 3D Wood & Gold Frame with Side Wings & Top Flare Glow
// ──────────────────────────────────────────────────────────────────────────────
class _DailyChallengeFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    const double wingSpace = 16.0;
    final double frameX = wingSpace;
    final double frameW = w - (wingSpace * 2);

    // ── 1. Top Rainbow Light Flare Glow ──────────────────────────────────
    final flareRect = Rect.fromLTWH(w * 0.15, -12, w * 0.7, 26);
    final flarePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF3A6).withValues(alpha: 0.6),
          const Color(0xFFFFB04A).withValues(alpha: 0.35),
          const Color(0xFFFF69B4).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(flareRect);
    canvas.drawOval(flareRect, flarePaint);

    // ── 2. Outer Drop Shadow Under Banner ────────────────────────────────
    final pillRect = Rect.fromLTWH(frameX, 0, frameW, h);
    final pillRRect = RRect.fromRectAndRadius(pillRect, Radius.circular(h * 0.44));

    // Outer glow aura
    canvas.drawRRect(
      pillRRect,
      Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Deep wood drop shadow
    canvas.drawRRect(
      pillRRect.shift(const Offset(0, 4)),
      Paint()
        ..color = const Color(0xFF241004).withValues(alpha: 0.65)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // ── 3. Main Pill Body Fill ───────────────────────────────────────────
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF6E3B1C), // Deep chocolate top
          Color(0xFF532911), // Mid warm oak
          Color(0xFF421E0B), // Dark chocolate bottom
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(pillRect);
    canvas.drawRRect(pillRRect, fillPaint);

    // Top Glossy Highlight Rim inside Pill
    final topHighlightRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameX + 3, 2, frameW - 6, h * 0.4),
      Radius.circular(h * 0.35),
    );
    canvas.drawRRect(
      topHighlightRRect,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(topHighlightRRect.outerRect),
    );

    // ── 4. Polished Gold Double Rim ──────────────────────────────────────
    final outerGoldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFDE6A2), // Champagne top highlight
          Color(0xFFD49E53), // Brass middle
          Color(0xFFB87834), // Bronze edge
          Color(0xFF8B5222), // Dark underside
        ],
        stops: [0.0, 0.35, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(pillRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2;
    canvas.drawRRect(pillRRect, outerGoldPaint);

    // Inner bevel stroke
    final innerRimRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameX + 3.5, 3.5, frameW - 7, h - 7),
      Radius.circular((h - 7) * 0.44),
    );
    canvas.drawRRect(
      innerRimRRect,
      Paint()
        ..color = const Color(0xFF8B5222).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── 5. Left & Right Ornamental Wing Brackets ─────────────────────────
    _drawWing(canvas, size, isLeft: true);
    _drawWing(canvas, size, isLeft: false);
  }

  void _drawWing(Canvas canvas, Size size, {required bool isLeft}) {
    final double w = size.width;
    final double h = size.height;

    final double attachX = isLeft ? 16.0 : w - 16.0;
    final double outerX = isLeft ? 1.0 : w - 1.0;
    final double midX = isLeft ? 6.0 : w - 6.0;

    final path = Path();
    if (isLeft) {
      path.moveTo(attachX + 6, h * 0.10);
      path.cubicTo(attachX - 6, h * 0.08, outerX, h * 0.25, outerX, h * 0.5);
      path.cubicTo(outerX, h * 0.75, attachX - 6, h * 0.92, attachX + 6, h * 0.90);
      path.cubicTo(midX, h * 0.72, midX + 1, h * 0.5, attachX + 6, h * 0.10);
    } else {
      path.moveTo(attachX - 6, h * 0.10);
      path.cubicTo(attachX + 6, h * 0.08, outerX, h * 0.25, outerX, h * 0.5);
      path.cubicTo(outerX, h * 0.75, attachX + 6, h * 0.92, attachX - 6, h * 0.90);
      path.cubicTo(midX, h * 0.72, midX - 1, h * 0.5, attachX - 6, h * 0.10);
    }
    path.close();

    final bounds = path.getBounds();

    // Wing 3D Fill
    final wingFill = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFDE6A2), // Champagne top
          Color(0xFFD49E53), // Polished brass
          Color(0xFF9E5F27), // Bronze shadow
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds);

    canvas.drawPath(path, wingFill);

    // Wing Outer Border
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF4A230D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Center Diamond Gemstone
    final double diamondCenterX = isLeft ? 7.5 : w - 7.5;
    final double diamondCenterY = h * 0.5;
    final double dH = 7.5;
    final double dW = 5.5;

    final diamondPath = Path()
      ..moveTo(diamondCenterX, diamondCenterY - dH)
      ..lineTo(diamondCenterX + dW, diamondCenterY)
      ..lineTo(diamondCenterX, diamondCenterY + dH)
      ..lineTo(diamondCenterX - dW, diamondCenterY)
      ..close();

    // Diamond Inner Fill
    canvas.drawPath(diamondPath, Paint()..color = const Color(0xFF5A2C11));

    // Diamond Gold Rim
    canvas.drawPath(
      diamondPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFF2A1), Color(0xFFD49E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(diamondPath.getBounds())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// 3D Wooden Bottom Navigation Bar (PLAY, LEVELS, PROFILE)
// ──────────────────────────────────────────────────────────────────────────────
class _WoodenBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _WoodenBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6E3B1C), // Deep chocolate top
            Color(0xFF532911), // Mid warm oak
            Color(0xFF381806), // Dark wood base
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(top: BorderSide(color: Color(0xFFFFD700), width: 2.0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241004).withValues(alpha: 0.7),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(index: 0, icon: Icons.sports_esports_rounded, label: 'PLAY'),
          _buildNavItem(index: 1, icon: Icons.grid_view_rounded, label: 'LEVELS'),
          _buildNavItem(index: 2, icon: Icons.person_rounded, label: 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFF5DEB3), Color(0xFFD4A055)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: const Color(0xFFFFE082), width: 1.5) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF3B1E08)
                  : const Color(0xFFF5DEB3).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF3B1E08)
                    : const Color(0xFFF5DEB3).withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 3D Wooden Difficulty Buttons Bar for Home Screen
// ──────────────────────────────────────────────────────────────────────────────
class _WoodenDifficultyButtonsBar extends StatelessWidget {
  final Function(DifficultyTier) onDifficultyTap;

  const _WoodenDifficultyButtonsBar({required this.onDifficultyTap});

  @override
  Widget build(BuildContext context) {
    final List<DifficultyTier> tiers = DifficultyTier.values;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFFFFD700)),
              const SizedBox(width: 6),
              const Text(
                'DIFFICULTY MODES',
                style: TextStyle(
                  color: Color(0xFFF5DEB3),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Color(0xFF3B1E08), offset: Offset(0, 1), blurRadius: 2)],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tiers.length,
            itemBuilder: (context, index) {
              final tier = tiers[index];
              return _WoodenDifficultyButtonPill(tier: tier, onTap: () => onDifficultyTap(tier));
            },
          ),
        ),
      ],
    );
  }
}

class _WoodenDifficultyButtonPill extends StatefulWidget {
  final DifficultyTier tier;
  final VoidCallback onTap;

  const _WoodenDifficultyButtonPill({required this.tier, required this.onTap});

  @override
  State<_WoodenDifficultyButtonPill> createState() => _WoodenDifficultyButtonPillState();
}

class _WoodenDifficultyButtonPillState extends State<_WoodenDifficultyButtonPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF421E0B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: tier.primaryColor.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: tier.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.0),
                ),
                child: Center(child: Icon(_getIconForTier(tier), size: 13, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Text(
                tier.displayName.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFFFF1D6),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTier(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.easy:
        return Icons.auto_awesome_rounded;
      case DifficultyTier.medium:
        return Icons.science_rounded;
      case DifficultyTier.hard:
        return Icons.whatshot_rounded;
      case DifficultyTier.expert:
        return Icons.military_tech_rounded;
      case DifficultyTier.challenge:
        return Icons.timer_rounded;
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Blank Profile Page Placeholder
// ──────────────────────────────────────────────────────────────────────────────
class _BlankProfilePage extends StatelessWidget {
  const _BlankProfilePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF8B5E3C),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF421E0B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B1E08).withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF5DEB3), Color(0xFFD4A055)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                ),
                child: const Icon(Icons.person_rounded, size: 36, color: Color(0xFF5D4037)),
              ),
              const SizedBox(height: 16),
              const Text(
                'PROFILE',
                style: TextStyle(
                  color: Color(0xFFFFF1D6),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Player stats & achievements coming soon!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF5DEB3),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
