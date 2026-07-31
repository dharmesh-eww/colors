import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../../game/paint_background_game.dart';
import '../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late PaintBackgroundGame _bgGame;

  late AnimationController _bottleFloatController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();

    // Floating animation for decorative ink bottles
    _bottleFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    // Glow shimmer animation for logo badge
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    // Smooth progress loader animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic));

    // Navigation timer
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.homeScreen);
      }
    });
  }

  @override
  void dispose() {
    _bottleFloatController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: Stack(
        children: [
          // ── Layer 1: Warm Wood Flame Background ───────────────────────
          Positioned.fill(child: GameWidget(game: _bgGame)),

          // ── Layer 3: Main Splash Content ────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // ── Glowing Craft Logo Badge ─────────────────────────────
                _SplashLogoBadge(shimmerAnimation: _shimmerAnimation),

                const SizedBox(height: 28),

                // ── Title 'Color Craft' ──────────────────────────────────
                const Text(
                  'Color Craft',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFF5DEB3),
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(color: Color(0xFF3B1E08), offset: Offset(0, 3), blurRadius: 8),
                      Shadow(color: Color(0xFFFFD700), offset: Offset(0, -1), blurRadius: 6),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Spacer(flex: 3),

                // ── Warm Progress Loading Bar ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B1E08).withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFD4A055).withValues(alpha: 0.5),
                                width: 1.0,
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFD4A055)],
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Initializing Color Studio...',
                        style: TextStyle(
                          color: const Color(0xFFF5DEB3).withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Splash Logo Badge — glowing warm wood & gold emblem with science palette icon
// ──────────────────────────────────────────────────────────────────────────────
class _SplashLogoBadge extends StatelessWidget {
  final Animation<double> shimmerAnimation;
  const _SplashLogoBadge({required this.shimmerAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A055), Color(0xFF8B5E3C), Color(0xFF5D3A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFFFD700), width: 3.0),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFFFD700,
                ).withValues(alpha: 0.35 + shimmerAnimation.value * 0.35),
                blurRadius: 24 + shimmerAnimation.value * 16,
                spreadRadius: 3 + shimmerAnimation.value * 4,
              ),
              const BoxShadow(color: Color(0xFF3B1E08), blurRadius: 10, offset: Offset(0, 5)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.palette_rounded, size: 56, color: Color(0xFFF5DEB3)),
              // Floating color droplets around badge rim
              Positioned(
                top: 18,
                right: 16,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(color: Color(0xFF00FFFF), shape: BoxShape.circle),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 16,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(color: Color(0xFFFF00FF), shape: BoxShape.circle),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 18,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFFFFF00), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
