import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/puzzle/puzzle_model.dart';
import '../../../game/paint_background_game.dart';
import '../binding/home_page_binding.dart';
import '../controller/home_page_controller.dart';

class HomePage extends StatekitView<HomePageController> implements HomePageBinding {
  HomePage({super.key, super.tag});

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
  final HomePageController controller;
  const _HomeScreenBody({required this.controller});

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF8B5E3C), body: _buildHomePlayTabContent());
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
                const SizedBox(height: 14),

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

                const SizedBox(height: 4),

                // ── Subtitle badge ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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

                // ── Unity-Style Wooden Slice Difficulty Menu ─────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _UnityWoodenDifficultyMenu(
                      onDifficultyTap: (tier) =>
                          widget.controller.onDifficultyClicked(context, tier),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── PLAY Button ───────────────────────────────────────────
                _PlayButtonWidget(
                  onTap: () => widget.controller.playButtonClicked(context),
                  pulseAnimation: _scaleAnimation,
                ),

                const SizedBox(height: 12),
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
// Unity-Style 3D Wooden Slice Difficulty Menu
// ──────────────────────────────────────────────────────────────────────────────
class _UnityWoodenDifficultyMenu extends StatelessWidget {
  final Function(DifficultyTier) onDifficultyTap;

  const _UnityWoodenDifficultyMenu({required this.onDifficultyTap});

  @override
  Widget build(BuildContext context) {
    final List<DifficultyTier> tiers = DifficultyTier.values;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A250F), Color(0xFF381806), Color(0xFF281003)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.85), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E0B02).withValues(alpha: 0.7),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech_rounded, size: 18, color: Color(0xFFFFD700)),
              const SizedBox(width: 6),
              const Text(
                'SELECT PUZZLE DIFFICULTY',
                style: TextStyle(
                  color: Color(0xFFFFF1D6),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  shadows: [
                    Shadow(color: Color(0xFF1E0B02), offset: Offset(0, 1.5), blurRadius: 3),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.military_tech_rounded, size: 18, color: Color(0xFFFFD700)),
            ],
          ),
          const SizedBox(height: 10),
          // Vertical Unity Wooden Slice Buttons Stack
          ...tiers.map(
            (tier) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _UnityWoodenSliceButton(tier: tier, onTap: () => onDifficultyTap(tier)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnityWoodenSliceButton extends StatefulWidget {
  final DifficultyTier tier;
  final VoidCallback onTap;

  const _UnityWoodenSliceButton({required this.tier, required this.onTap});

  @override
  State<_UnityWoodenSliceButton> createState() => _UnityWoodenSliceButtonState();
}

class _UnityWoodenSliceButtonState extends State<_UnityWoodenSliceButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final tier = widget.tier;
    final primaryColor = tier.primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7A4522), // Carved wood top highlight
                Color(0xFF582D13), // Mid oak plank
                Color(0xFF3C1B08), // Dark bottom bevel
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: const Color(0xFF1E0B02).withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Stud Rivet
              _buildRivet(),
              const SizedBox(width: 8),

              // Tier Icon Emblem Badge
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, tier.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
                  boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.5), blurRadius: 6)],
                ),
                child: Center(child: Icon(_getTierIcon(tier), size: 18, color: Colors.white)),
              ),
              const SizedBox(width: 12),

              // Display Name & Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tier.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFF1D6),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Color(0xFF1E0B02),
                                offset: Offset(0, 1.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _getTierSubtitle(tier),
                      style: TextStyle(
                        color: const Color(0xFFF5DEB3).withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Play Arrow Badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF5DF), Color(0xFFF5DEB3), Color(0xFFD4A055)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF3B1E08), size: 18),
              ),

              const SizedBox(width: 8),
              // Right Stud Rivet
              _buildRivet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRivet() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB87333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF381806), width: 0.8),
      ),
    );
  }

  IconData _getTierIcon(DifficultyTier tier) {
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

  String _getTierSubtitle(DifficultyTier tier) {
    switch (tier) {
      case DifficultyTier.easy:
        return '2 Paints · Gentle Mix';
      case DifficultyTier.medium:
        return '3 Paints · Moderate Complexity';
      case DifficultyTier.hard:
        return '4 Paints · Advanced Crafting';
      case DifficultyTier.expert:
        return '5 Paints · Master Alchemist';
      case DifficultyTier.challenge:
        return '3 Paints · 2-Min Countdown!';
    }
  }
}
