import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../game/paint_background_game.dart';
import '../../../widgets/decor_painters.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

// ignore: must_be_immutable
class HomeScreen extends StatekitView<HomeScreenController> implements HomeScreenBinding {
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

class _HomeScreenBodyState extends State<_HomeScreenBody> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _decorFloatController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;

  late PaintBackgroundGame _bgGame;

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();

    // Primary Play button pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Decorative objects floating bobbing animation
    _decorFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _decorFloatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _decorFloatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: Stack(
        children: [
          // 1. Flame White Wall Background Canvas with Color Blobs & Hanging Drops
          Positioned.fill(
            child: GameWidget(game: _bgGame),
          ),

          // 2. Floating Edge 100% Transparent Vector Decorative Objects (Palette & Paint Brush)
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Top-Left Floating 100% Transparent Paint Palette
                  Positioned(
                    top: 60 + _floatAnimation.value,
                    left: 15,
                    child: Transform.rotate(
                      angle: -0.15 + (sin(_floatAnimation.value * 0.1) * 0.05),
                      child: const PaintPaletteWidget(size: 90),
                    ),
                  ),

                  // Top-Right Floating 100% Transparent Paint Brush
                  Positioned(
                    top: 70 - _floatAnimation.value,
                    right: 15,
                    child: Transform.rotate(
                      angle: 0.2 + (cos(_floatAnimation.value * 0.1) * 0.05),
                      child: const PaintBrushWidget(size: 95),
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Foreground Content & Clean Center Reserved Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Game Logo Header
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7675), Color(0xFF6C5CE7), Color(0xFF74B9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Color Craft',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFFD63031), Color(0xFF6C5CE7), Color(0xFF0984E3)],
                        ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                      shadows: [
                        Shadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.25),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      '🎨 Mix & Match Paint Puzzle',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Center Reserved Space: Primary PLAY Button
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: () => widget.controller.playButtonClicked(context),
                      child: Container(
                        width: 220,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00CEC9), Color(0xFF0984E3)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00CEC9).withValues(alpha: 0.55),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 44,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PLAY',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF0984E3).withValues(alpha: 0.4),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mode Selector Row (Easy, Medium, Hard, Challenge 2 Min)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeChip('Easy', isSelected: true),
                      const SizedBox(width: 8),
                      _buildModeChip('Medium'),
                      const SizedBox(width: 8),
                      _buildModeChip('Hard'),
                      const SizedBox(width: 8),
                      _buildModeChip('2 Min ⏱️'),
                    ],
                  ),

                  const Spacer(),

                  // Version Text
                  Text(
                    'Version 1.0 Demo',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF74B9FF).withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}