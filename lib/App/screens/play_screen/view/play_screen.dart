import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/enums/bottle_interaction_mode.dart';
import '../../../core/models/paint_model.dart';
import '../../../core/puzzle/puzzle_model.dart';
import '../../../game/paint_background_game.dart';
import '../../../game/paint_mixing_game.dart';
import '../../../widgets/draggable_bottle_widget.dart';
import '../../../widgets/mixing_tile_widget.dart';
import '../binding/play_screen_binding.dart';
import '../controller/play_screen_controller.dart';

class PlayScreen extends StatekitView<PlayScreenController> implements PlayScreenBinding {
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
      if (args is DifficultyTier) {
        widget.controller.loadDifficulty(args);
      } else if (args is int) {
        widget.controller.loadLevel(args);
      } else {
        widget.controller.loadLevel(1);
      }
    });
  }

  @override
  void dispose() {
    widget.controller.stopTimer();
    super.dispose();
  }

  void _calculateTileArea() {
    final RenderBox? renderBox = _mixingTileKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      setState(() {
        _mixingTileArea = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
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
                      difficultyTier: ctrl.currentDifficultyTier,
                      puzzleStreakCount: ctrl.puzzleStreakCount,
                      formattedTime: ctrl.formattedTime,
                      availableCoins: ctrl.availableCoins,
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
                      bottleInteractionMode: ctrl.bottleInteractionMode,
                      isHintActive: ctrl.isHintActive,
                      targetRecipe: ctrl.targetRecipe,
                      onTap: (type) => ctrl.selectColorType(type),
                      onPourContinuous: (type, ml, pos) => ctrl.pourPaintType(type, ml),
                      onPourEnd: () => ctrl.checkCompletionOnPourEnd(),
                      onUseHint: () async {
                        final bool success = await ctrl.useHint();
                        if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Need 5 coins for a hint! You have ${ctrl.availableCoins} coins.',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: const Color(0xFF5D4037),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // ── Game Puzzle Complete Dialog ──────────────────────────────
              if (ctrl.isCompleted)
                _GamePuzzleCompleteDialog(
                  accuracy: ctrl.accuracy,
                  mixedColor: ctrl.mixedColor,
                  formattedTime: ctrl.formattedTime,
                  difficultyTier: ctrl.currentDifficultyTier,
                  streakCount: ctrl.puzzleStreakCount,
                  levelNumber: ctrl.currentLevelNumber,
                  earnedStars: ctrl.earnedStars,
                  earnedCoins: ctrl.earnedCoins,
                  availableCoins: ctrl.availableCoins,
                  restartCount: ctrl.restartCount,
                  onNext: () => ctrl.initNewTarget(),
                  onRetry: () => ctrl.retryChallenge(),
                  onHome: () => Navigator.pop(context),
                ),

              // ── Time Up Overlay ──────────────────────────────────────────
              if (ctrl.isTimeUp)
                _TimeUpOverlay(
                  onRetry: () => ctrl.retryChallenge(),
                  onExit: () => Navigator.pop(context),
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
  final DifficultyTier? difficultyTier;
  final int puzzleStreakCount;
  final String formattedTime;
  final int availableCoins;
  final VoidCallback onBack;
  final VoidCallback onReset;

  const _TargetColorHeader({
    required this.targetColor,
    required this.targetHex,
    required this.levelNumber,
    this.difficultyTier,
    required this.puzzleStreakCount,
    required this.formattedTime,
    required this.availableCoins,
    required this.onBack,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDifficultyMode = difficultyTier != null;

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
          // Back button with press animation
          _AnimatedIconButton(icon: Icons.chevron_left_rounded, iconSize: 24, onTap: onBack),

          // Target Color label + timer + hex badge (centered)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isDifficultyMode) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: difficultyTier!.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            difficultyTier!.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PUZZLE #$puzzleStreakCount',
                          style: const TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          'LEVEL $levelNumber',
                          style: const TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w900,
                            fontSize: 11.5,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8D6228),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.timer_outlined, size: 13, color: Color(0xFF5D4037)),
                      const SizedBox(width: 2),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Target hex code badge
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: targetColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: targetColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    targetHex,
                    style: TextStyle(
                      color: _contrastColor(targetColor),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1.4,
                      fontFamily: 'monospace',
                      shadows: const [
                        Shadow(color: Color(0x55000000), offset: Offset(0, 1), blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Available Coins Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B1E08).withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 14),
                const SizedBox(width: 3),
                Text(
                  '$availableCoins',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Reset button with press animation
          _AnimatedIconButton(icon: Icons.refresh_rounded, iconSize: 20, onTap: onReset),
        ],
      ),
    );
  }

  Color _contrastColor(Color bg) {
    final double luminance = bg.computeLuminance();
    return luminance > 0.4 ? const Color(0xFF3B1E08) : Colors.white;
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
// Wooden Shelf + Ink Bottles
// ──────────────────────────────────────────────────────────────────────────────
class _WoodenShelf extends StatelessWidget {
  final List<PaintBottle> bottles;
  final PaintType selectedType;
  final Rect mixingTileArea;
  final PaintMixingGame flameGame;
  final BottleInteractionMode bottleInteractionMode;
  final bool isHintActive;
  final Map<PaintType, double> targetRecipe;
  final Function(PaintType) onTap;
  final Function(PaintType, double, Offset) onPourContinuous;
  final VoidCallback onPourEnd;
  final VoidCallback onUseHint;

  const _WoodenShelf({
    required this.bottles,
    required this.selectedType,
    required this.mixingTileArea,
    required this.flameGame,
    this.bottleInteractionMode = BottleInteractionMode.drag,
    this.isHintActive = false,
    this.targetRecipe = const {},
    required this.onTap,
    required this.onPourContinuous,
    required this.onPourEnd,
    required this.onUseHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Shelf Header Bar (Hint Button) ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onUseHint,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isHintActive
                        ? const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isHintActive ? const Color(0xFFFFD700) : const Color(0xFFFFD700),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isHintActive ? const Color(0xFF2E7D32) : const Color(0xFF3B1E08))
                            .withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: isHintActive ? Colors.white : const Color(0xFFFFD700),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHintActive ? 'HINT ACTIVE' : 'HINT',
                        style: TextStyle(
                          color: isHintActive ? Colors.white : const Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!isHintActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 11),
                              SizedBox(width: 2),
                              Text(
                                '5',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Bottle Row ──────────────────────────────────────────────────────
        SizedBox(
          height: isHintActive ? 162 : 138,
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
                return DraggableBottleWidget(
                  bottle: bottle,
                  isSelected: selectedType == bottle.type,
                  mixingTileArea: mixingTileArea,
                  flameGame: flameGame,
                  bottleInteractionMode: bottleInteractionMode,
                  isHintActive: isHintActive,
                  targetAmountMl: targetRecipe[bottle.type] ?? 0.0,
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
            boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 4))],
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
// Game Puzzle Complete Dialog — Warm Wood & Gold Game-Themed Dialog
// ──────────────────────────────────────────────────────────────────────────────
class _GamePuzzleCompleteDialog extends StatefulWidget {
  final double accuracy;
  final Color mixedColor;
  final String formattedTime;
  final DifficultyTier? difficultyTier;
  final int streakCount;
  final int levelNumber;
  final int earnedStars;
  final int earnedCoins;
  final int availableCoins;
  final int restartCount;
  final VoidCallback onNext;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const _GamePuzzleCompleteDialog({
    required this.accuracy,
    required this.mixedColor,
    required this.formattedTime,
    this.difficultyTier,
    required this.streakCount,
    required this.levelNumber,
    required this.earnedStars,
    required this.earnedCoins,
    required this.availableCoins,
    required this.restartCount,
    required this.onNext,
    required this.onRetry,
    required this.onHome,
  });

  @override
  State<_GamePuzzleCompleteDialog> createState() => _GamePuzzleCompleteDialogState();
}

class _GamePuzzleCompleteDialogState extends State<_GamePuzzleCompleteDialog>
    with SingleTickerProviderStateMixin {
  int _visibleStars = 0;
  bool _isAnimationComplete = false;

  @override
  void initState() {
    super.initState();
    _startStarAnimation();
  }

  void _startStarAnimation() async {
    final int targetStars = widget.earnedStars.clamp(0, 3);
    if (targetStars == 0) {
      if (mounted) {
        setState(() {
          _isAnimationComplete = true;
        });
      }
      return;
    }

    // Wait 1 second (1000ms) after dialog appears before starting star bounce sequence
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 1; i <= targetStars; i++) {
      if (!mounted) return;
      setState(() {
        _visibleStars = i;
      });
      await Future.delayed(const Duration(milliseconds: 450));
    }

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _isAnimationComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDifficulty = widget.difficultyTier != null;
    const double starRowHalfHeight = 24.0;

    return Positioned.fill(
      child: Container(
        color: const Color(0xFF2C1405).withValues(alpha: 0.78),
        child: Center(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  // ── Layer 1: Main Dialog Box Container ─────────────────────
                  Container(
                    margin: EdgeInsets.only(top: isDifficulty ? 0 : starRowHalfHeight),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      isDifficulty ? 18 : (starRowHalfHeight + 12),
                      16,
                      16,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFD4A055), width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                        // BoxShadow(
                        //   color: const Color(0xFF3B1E08).withValues(alpha: 0.6),
                        //   blurRadius: 12,
                        //   offset: const Offset(0, 6),
                        // ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Header Title Banner ──────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            isDifficulty
                                ? '${widget.difficultyTier!.displayName.toUpperCase()} SOLVED!'
                                : 'LEVEL ${widget.levelNumber} COMPLETED!',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Color Swatch & Accuracy Card ──────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B1E08).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFD4A055).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Color Swatch with Theme-Matched High-Contrast Check Icon
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: widget.mixedColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFD4A055), width: 2.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.mixedColor.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF3B1E08).withValues(alpha: 0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: widget.mixedColor.computeLuminance() > 0.5
                                        ? const Color(0xFF3B1E08)
                                        : Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),
                              // Accuracy & Time stats
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.accuracy.toStringAsFixed(1)}% ACCURACY',
                                      style: const TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_outlined,
                                          size: 13,
                                          color: Color(0xFF8D6228),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Time: ${widget.formattedTime}',
                                          style: const TextStyle(
                                            color: Color(0xFF8D6228),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Earned Coins Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.monetization_on_rounded,
                                      color: Color(0xFFFFD700),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${widget.earnedCoins}',
                                      style: const TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Main Action: NEXT PUZZLE / NEXT LEVEL Button ──────────
                        GestureDetector(
                          onTap: _isAnimationComplete ? widget.onNext : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: double.maxFinite,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              gradient: _isAnimationComplete
                                  ? const LinearGradient(
                                      colors: [Color(0xFF8B5E3C), Color(0xFF5D4037)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        const Color(0xFF5D4037).withValues(alpha: 0.3),
                                        const Color(0xFF3B1E08).withValues(alpha: 0.3),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isAnimationComplete
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFF8D6228).withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                              // boxShadow: _isAnimationComplete
                              //     ? [
                              //         BoxShadow(
                              //           color: const Color(0xFF3B1E08).withValues(alpha: 0.45),
                              //           blurRadius: 8,
                              //           offset: const Offset(0, 3),
                              //         ),
                              //       ]
                              //     : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!_isAnimationComplete) ...[
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF5D4037),
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ] else ...[
                                  const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Color(0xFFFFD700),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  isDifficulty ? 'NEXT PUZZLE' : 'NEXT LEVEL',
                                  style: TextStyle(
                                    color: _isAnimationComplete
                                        ? const Color(0xFFFFD700)
                                        : const Color(0xFF5D4037).withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ── Secondary Actions: RETRY & HOME Buttons ────────────────
                        Row(
                          children: [
                            // HOME button
                            Expanded(
                              child: GestureDetector(
                                onTap: widget.onHome,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5D4037).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF5D4037), width: 1.2),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.home_rounded, color: Color(0xFF5D4037), size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'HOME',
                                        style: TextStyle(
                                          color: Color(0xFF5D4037),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // RETRY button
                            Expanded(
                              child: GestureDetector(
                                onTap: widget.onRetry,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5D4037).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF5D4037), width: 1.2),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.replay_rounded,
                                        color: Color(0xFF5D4037),
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'REPLAY',
                                        style: TextStyle(
                                          color: Color(0xFF5D4037),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Layer 2: Star View Parent Container (Overlapping Top Border) ──
                  if (!isDifficulty)
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B1E08), Color(0xFF2C1405)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF8D6228), width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E0D03).withValues(alpha: 0.7),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            final int starNumber = index + 1;
                            final bool isFilled = starNumber <= _visibleStars;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Base: White Outer Border & Unfilled Dark Grey Star
                                  const Icon(Icons.star_rounded, size: 40, color: Colors.white),
                                  Icon(
                                    Icons.star_rounded,
                                    size: 32,
                                    color: const Color(0xFF8D6228).withValues(alpha: 0.4),
                                  ),

                                  // Foreground: Highlighted Golden Star (Animates 0 -> 1 Bounce)
                                  AnimatedScale(
                                    scale: isFilled ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 450),
                                    curve: Curves.bounceOut,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                          ),
                                          // BoxShadow(
                                          //   color: const Color(0xFFFF8F00).withValues(alpha: 0.5),
                                          //   blurRadius: 20,
                                          //   spreadRadius: 1,
                                          // ),
                                        ],
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: const [
                                          Icon(Icons.star_rounded, size: 40, color: Colors.white),
                                          Icon(
                                            Icons.star_rounded,
                                            size: 32,
                                            color: Color(0xFFFFD700),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
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
// Time Up Overlay — displayed when 2-minute countdown expires
// ──────────────────────────────────────────────────────────────────────────────
class _TimeUpOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const _TimeUpOverlay({required this.onRetry, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF3B1E08).withValues(alpha: 0.75),
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
              border: Border.all(color: const Color(0xFFFF5722), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Flame timer icon badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF5722), Color(0xFFD84315)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFCC80), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5722).withValues(alpha: 0.6),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.timer_off_rounded, color: Colors.white, size: 34),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TIME EXPIRED!',
                  style: TextStyle(
                    color: Color(0xFFD84315),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    shadows: [
                      Shadow(color: Color(0x44000000), offset: Offset(0, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The 2-minute timer ran out before you matched the color!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Exit button
                    GestureDetector(
                      onTap: onExit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D4037).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF5D4037), width: 1.5),
                        ),
                        child: const Text(
                          'EXIT',
                          style: TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Retry button
                    GestureDetector(
                      onTap: onRetry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7043), Color(0xFFD84315)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5722).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'TRY AGAIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
