import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/enums/bottle_interaction_mode.dart';
import '../../../core/models/paint_model.dart';
import '../../../game/paint_background_game.dart';
import '../../../game/paint_mixing_game.dart';
import '../../../widgets/draggable_bottle_widget.dart';
import '../../../widgets/mixing_tile_widget.dart';
import '../binding/tutorial_screen_binding.dart';
import '../controller/tutorial_screen_controller.dart';

class TutorialScreen extends StatekitView<TutorialScreenController>
    implements TutorialScreenBinding {
  TutorialScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _TutorialScreenBody(controller: controller);
  }

  @override
  void doSomething() {}
}

class _TutorialScreenBody extends StatefulWidget {
  final TutorialScreenController controller;
  const _TutorialScreenBody({required this.controller});

  @override
  State<_TutorialScreenBody> createState() => _TutorialScreenBodyState();
}

class _TutorialScreenBodyState extends State<_TutorialScreenBody> with TickerProviderStateMixin {
  late PaintMixingGame _flameGame;
  late PaintBackgroundGame _bgGame;
  final GlobalKey _mixingTileKey = GlobalKey();
  Rect _mixingTileArea = Rect.zero;

  late AnimationController _handDragController;
  late Animation<double> _dragProgressAnimation;

  @override
  void initState() {
    super.initState();
    _flameGame = PaintMixingGame();
    _bgGame = PaintBackgroundGame();

    _handDragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _dragProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _handDragController, curve: Curves.easeInOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTileArea();
    });
  }

  @override
  void dispose() {
    _handDragController.dispose();
    super.dispose();
  }

  void _calculateTileArea() {
    if (!mounted) return;
    final RenderBox? renderBox = _mixingTileKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.attached) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final newArea = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      if (_mixingTileArea != newArea) {
        setState(() {
          _mixingTileArea = newArea;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.controller.attachFlameGame(_flameGame);

    // Re-calculate tile global bounds on frame render
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTileArea());

    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: StateBuilder<TutorialScreenController>(
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
                    // ── PlayScreen-Style Target Header ───────────────────────
                    _TutorialHeader(
                      targetColor: ctrl.targetColor,
                      targetHex: ctrl.targetHex,
                      onSkip: () => ctrl.skipTutorial(context),
                    ),

                    // ── Step Guidance Banner ─────────────────────────────────
                    _buildGuidanceBanner(ctrl),

                    // ── Central Mixing Station (MixingTileWidget) ────────────
                    Expanded(
                      child: Center(
                        child: DragTarget<PaintType>(
                          onWillAcceptWithDetails: (_) => true,
                          onAcceptWithDetails: (details) {
                            ctrl.pourPaintType(details.data, 25.0, context);
                          },
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

                    // ── PlayScreen-Style Wooden Shelf + Ink Bottles ─────────
                    _TutorialWoodenShelf(
                      bottles: ctrl.bottles,
                      mixingTileArea: _mixingTileArea,
                      flameGame: _flameGame,
                      currentStep: ctrl.currentStep,
                      onPourContinuous: (type, ml, pos) {
                        ctrl.pourPaintType(type, ml, context);
                      },
                    ),
                  ],
                ),
              ),

              // ── Layer 4: Animated Hand Pointer Suggestion ─────────────────
              if (ctrl.currentStep != TutorialStep.completed) _buildAnimatedHandPointer(ctrl),
            ],
          );
        },
      ),
    );
  }

  // ── Step Guidance Banner ───────────────────────────────────────────────────
  Widget _buildGuidanceBanner(TutorialScreenController ctrl) {
    String stepText;
    Color stepHighlightColor;

    switch (ctrl.currentStep) {
      case TutorialStep.pourRed:
        stepText = "STEP 1: Drag RED bottle to mixing beaker!";
        stepHighlightColor = const Color(0xFFFF3333);
        break;
      case TutorialStep.pourGreen:
        stepText = "STEP 2: Drag GREEN bottle to mix Red + Green!";
        stepHighlightColor = const Color(0xFF33FF33);
        break;
      case TutorialStep.completed:
        stepText = "EXCELLENT! Target Yellow Color Matched!";
        stepHighlightColor = const Color(0xFFFFD700);
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF532911), Color(0xFF381806)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stepHighlightColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: stepHighlightColor.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, color: stepHighlightColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stepText,
              style: const TextStyle(
                color: Color(0xFFFFF1D6),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Animated Drag Hand Pointer ────────────────────────────────────────────
  Widget _buildAnimatedHandPointer(TutorialScreenController ctrl) {
    return AnimatedBuilder(
      animation: _dragProgressAnimation,
      builder: (context, child) {
        final double progress = _dragProgressAnimation.value;
        final double screenWidth = MediaQuery.of(context).size.width;
        final double screenHeight = MediaQuery.of(context).size.height;

        // Position over Red (left) vs Green (center) bottle
        final double startX = ctrl.currentStep == TutorialStep.pourRed
            ? screenWidth * 0.28
            : screenWidth * 0.50;
        final double startY = screenHeight - 110.0;

        final double endX = _mixingTileArea != Rect.zero
            ? _mixingTileArea.center.dx
            : screenWidth * 0.50;
        final double endY = _mixingTileArea != Rect.zero
            ? _mixingTileArea.center.dy
            : screenHeight * 0.45;

        final double currentX = startX + (endX - startX) * progress;
        final double currentY = startY + (endY - startY) * progress;

        return Positioned(
          left: currentX - 24,
          top: currentY - 24,
          child: IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3B1E08), width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.touch_app_rounded, size: 28, color: Color(0xFF3B1E08)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1E08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                  ),
                  child: const Text(
                    'DRAG TO MIX',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// PlayScreen-Style Target Header
// ──────────────────────────────────────────────────────────────────────────────
class _TutorialHeader extends StatelessWidget {
  final Color targetColor;
  final String targetHex;
  final VoidCallback onSkip;

  const _TutorialHeader({required this.targetColor, required this.targetHex, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          // Left Info (Title & Target Hex Badge)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TUTORIAL LEVEL',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: targetColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.0),
                  ),
                  child: Text(
                    targetHex,
                    style: const TextStyle(
                      color: Color(0xFF3B1E08),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skip Button (Right Side)
          GestureDetector(
            onTap: onSkip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SKIP',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.fast_forward_rounded, color: Color(0xFFFFD700), size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onTap;

  const _AnimatedIconButton({required this.icon, required this.iconSize, required this.onTap});

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
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
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 38,
          height: 38,
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
          child: Icon(widget.icon, color: const Color(0xFF5D4037), size: widget.iconSize),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// PlayScreen-Style Wooden Shelf + Ink Bottles
// ──────────────────────────────────────────────────────────────────────────────
class _TutorialWoodenShelf extends StatelessWidget {
  final List<PaintBottle> bottles;
  final Rect mixingTileArea;
  final PaintMixingGame flameGame;
  final TutorialStep currentStep;
  final Function(PaintType, double, Offset) onPourContinuous;

  const _TutorialWoodenShelf({
    required this.bottles,
    required this.mixingTileArea,
    required this.flameGame,
    required this.currentStep,
    required this.onPourContinuous,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Bottle Row ──────────────────────────────────────────────────────
        SizedBox(
          height: 162,
          width: double.maxFinite,
          child: Center(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: bottles.length,
              itemBuilder: (context, index) {
                final bottle = bottles[index];
                final bool isSuggested =
                    (currentStep == TutorialStep.pourRed && bottle.type == PaintType.magenta) ||
                    (currentStep == TutorialStep.pourGreen && bottle.type == PaintType.cyan);

                return DraggableBottleWidget(
                  bottle: bottle,
                  isSelected: isSuggested,
                  mixingTileArea: mixingTileArea,
                  flameGame: flameGame,
                  bottleInteractionMode: BottleInteractionMode.drag,
                  isHintActive: isSuggested,
                  targetAmountMl: isSuggested ? 50.0 : 0.0,
                  onTap: () {
                    if (isSuggested) {
                      onPourContinuous(bottle.type, 25.0, Offset.zero);
                    }
                  },
                  onPourContinuous: onPourContinuous,
                  onPourEnd: () {},
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
              colors: [Color(0xFFB87333), Color(0xFF8B5E3C), Color(0xFF6D4C2A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: CustomPaint(painter: _ShelfGrainPainter()),
        ),
      ],
    );
  }
}

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
