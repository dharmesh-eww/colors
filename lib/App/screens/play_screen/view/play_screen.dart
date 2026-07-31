import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/paint_model.dart';
import '../../../game/paint_background_game.dart';
import '../../../game/paint_mixing_game.dart';
import '../../../widgets/draggable_bottle_widget.dart';
import '../../../widgets/mixing_tile_widget.dart';
import '../binding/play_screen_binding.dart';
import '../controller/play_screen_controller.dart';

// ignore: must_be_immutable
class PlayScreen extends StatekitView<PlayScreenController>
    implements PlayScreenBinding {
  PlayScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _PlayScreenBody(controller: controller);
  }

  @override
  void onPaintAmountChanged(PaintType type, double value) {}

  @override
  void onMixPressed() {}

  @override
  void onResetPressed() {}
}

class _PlayScreenBody extends StatefulWidget {
  final PlayScreenController controller;
  const _PlayScreenBody({required this.controller});

  @override
  State<_PlayScreenBody> createState() => _PlayScreenBodyState();
}

class _PlayScreenBodyState extends State<_PlayScreenBody> {
  late PaintMixingGame _flameGame;
  late PaintBackgroundGame _bgGame;
  final GlobalKey _mixingTileKey = GlobalKey();
  Rect _mixingTileArea = Rect.zero;

  @override
  void initState() {
    super.initState();
    _flameGame = PaintMixingGame();
    _bgGame = PaintBackgroundGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTileArea();
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int) {
        widget.controller.loadLevel(args);
      }
    });
  }

  @override
  void dispose() {
    widget.controller.stopTimer();
    super.dispose();
  }

  void _calculateTileArea() {
    final RenderBox? renderBox =
        _mixingTileKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      setState(() {
        _mixingTileArea =
            Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.attachFlameGame(_flameGame);

    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: StateBuilder<PlayScreenController>(
        controller: widget.controller,
        builder: (context, ctrl, child) {
          return Stack(
            children: [
              // ── Layer 1: Wood Background ─────────────────────────────────
              Positioned.fill(child: GameWidget(game: _bgGame)),

              // ── Layer 2: Droplet Particle Overlay ────────────────────────
              Positioned.fill(child: GameWidget(game: _flameGame)),

              // ── Layer 3: UI Layout ───────────────────────────────────────
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ───────────────────────────────────────────────
                    _TargetColorHeader(
                      targetColor: ctrl.targetColor,
                      targetHex: ctrl.targetHex,
                      levelNumber: ctrl.currentLevelNumber,
                      formattedTime: ctrl.formattedTime,
                      onBack: () => Navigator.pop(context),
                      onReset: () => ctrl.resetMix(),
                    ),

                    // ── Central Mixing Station ────────────────────────────────
                    Expanded(
                      child: Center(
                        child: DragTarget<PaintType>(
                          onWillAcceptWithDetails: (_) => true,
                          builder: (context, candidateData, rejectedData) {
                            return MixingTileWidget(
                              tileKey: _mixingTileKey,
                              mixedColor: ctrl.mixedColor,
                              accuracy: ctrl.accuracy,
                            );
                          },
                        ),
                      ),
                    ),

                    // ── Wooden Shelf + Bottles ────────────────────────────────
                    _WoodenShelf(
                      bottles: ctrl.bottles,
                      selectedType: ctrl.selectedType,
                      mixingTileArea: _mixingTileArea,
                      flameGame: _flameGame,
                      onTap: (type) => ctrl.selectColorType(type),
                      onPourContinuous: (type, ml, pos) =>
                          ctrl.pourPaintType(type, ml),
                      onPourEnd: () => ctrl.checkCompletionOnPourEnd(),
                    ),
                  ],
                ),
              ),

              // ── Victory Overlay ──────────────────────────────────────────
              if (ctrl.isCompleted)
                _VictoryOverlay(
                  accuracy: ctrl.accuracy,
                  mixedColor: ctrl.mixedColor,
                  formattedTime: ctrl.formattedTime,
                ),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Target Color Header — matches reference: cream/tan panel with hex badge
// ──────────────────────────────────────────────────────────────────────────────
class _TargetColorHeader extends StatelessWidget {
  final Color targetColor;
  final String targetHex;
  final int levelNumber;
  final String formattedTime;
  final VoidCallback onBack;
  final VoidCallback onReset;

  const _TargetColorHeader({
    required this.targetColor,
    required this.targetHex,
    required this.levelNumber,
    required this.formattedTime,
    required this.onBack,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4A055), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B1E08).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8C898),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF5D4037),
                size: 24,
              ),
            ),
          ),

          // Target Color label + timer + hex badge (centered)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL $levelNumber',
                      style: const TextStyle(
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.4,
                        shadows: [
                          Shadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8D6228),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Color(0xFF5D4037),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Teal rounded pill with hex code
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                  decoration: BoxDecoration(
                    color: targetColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: targetColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    targetHex,
                    style: TextStyle(
                      color: _contrastColor(targetColor),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                      shadows: const [
                        Shadow(
                            color: Color(0x55000000),
                            offset: Offset(0, 1),
                            blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reset button
          GestureDetector(
            onTap: onReset,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8C898),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF5D4037),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _contrastColor(Color bg) {
    final double luminance = bg.computeLuminance();
    return luminance > 0.4 ? const Color(0xFF3B1E08) : Colors.white;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Wooden Shelf + Ink Bottles
// ──────────────────────────────────────────────────────────────────────────────
class _WoodenShelf extends StatelessWidget {
  final List<PaintBottle> bottles;
  final PaintType selectedType;
  final Rect mixingTileArea;
  final PaintMixingGame flameGame;
  final Function(PaintType) onTap;
  final Function(PaintType, double, Offset) onPourContinuous;
  final VoidCallback onPourEnd;

  const _WoodenShelf({
    required this.bottles,
    required this.selectedType,
    required this.mixingTileArea,
    required this.flameGame,
    required this.onTap,
    required this.onPourContinuous,
    required this.onPourEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bottle Row ──────────────────────────────────────────────────────
        SizedBox(
          height: 130,
          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: bottles.length,
              itemBuilder: (context, index) {
                final bottle = bottles[index];
                return DraggableBottleWidget(
                  bottle: bottle,
                  isSelected: selectedType == bottle.type,
                  mixingTileArea: mixingTileArea,
                  flameGame: flameGame,
                  onTap: () => onTap(bottle.type),
                  onPourContinuous: onPourContinuous,
                  onPourEnd: onPourEnd,
                );
              },
            ),
          ),
        ),

        // ── Wooden Shelf Plank ──────────────────────────────────────────────
        Container(
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB87333), // Copper wood edge highlight
                Color(0xFF8B5E3C), // Main plank
                Color(0xFF6D4C2A), // Bottom shadow
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CustomPaint(painter: _ShelfGrainPainter()),
        ),
      ],
    );
  }
}

// Subtle wood grain on the shelf plank
class _ShelfGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1.0;
    final random = Random(7);
    for (int i = 0; i < 8; i++) {
      final y = random.nextDouble() * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + (random.nextDouble() - 0.5) * 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShelfGrainPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────────────────────────────────────
// Victory Overlay — styled to match warm wood theme
// ──────────────────────────────────────────────────────────────────────────────
class _VictoryOverlay extends StatelessWidget {
  final double accuracy;
  final Color mixedColor;
  final String formattedTime;

  const _VictoryOverlay({
    required this.accuracy,
    required this.mixedColor,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF3B1E08).withValues(alpha: 0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFD4A055), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color swatch of matched color
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: mixedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A055), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: mixedColor.withValues(alpha: 0.6),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'PERFECT MATCH!',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    shadows: [
                      Shadow(
                          color: Color(0x44000000),
                          offset: Offset(0, 2),
                          blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C853).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFF00C853), width: 1.5),
                      ),
                      child: Text(
                        'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5D4037).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFF5D4037), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Color(0xFF5D4037),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              color: Color(0xFF5D4037),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4A055),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generating Next Target...',
                  style: TextStyle(color: Color(0xFF8D6228), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
