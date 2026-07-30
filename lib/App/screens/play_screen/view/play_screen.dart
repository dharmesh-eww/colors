import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/paint_model.dart';
import '../../../game/paint_background_game.dart';
import '../../../game/paint_mixing_game.dart';
import '../../../widgets/color_card_widget.dart';
import '../../../widgets/draggable_bottle_widget.dart';
import '../../../widgets/mixing_tile_widget.dart';
import '../binding/play_screen_binding.dart';
import '../controller/play_screen_controller.dart';

// ignore: must_be_immutable
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTileArea());
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
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Color Craft',
          style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0984E3)),
            tooltip: 'New Target',
            onPressed: () => widget.controller.initNewTarget(),
          ),
        ],
      ),
      body: StateBuilder<PlayScreenController>(
        controller: widget.controller,
        builder: (context, ctrl, child) {
          return Stack(
            children: [
              // White Studio Wall Background Canvas
              Positioned.fill(child: GameWidget(game: _bgGame)),

              // Flame Droplets Overlay
              Positioned.fill(child: GameWidget(game: _flameGame)),

              // Game Play Canvas Layout
              Column(
                children: [
                  const SizedBox(height: 10),

                  // 1. Target vs Mixed Color Comparison Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        ColorCardWidget(title: 'Target Colour', color: ctrl.targetColor),
                        const SizedBox(width: 12),
                        ColorCardWidget(title: 'Your Colour', color: ctrl.mixedColor),
                      ],
                    ),
                  ),

                  // 2. Central Animated Liquid Mixing Tile (Drag Target)
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

                  const SizedBox(height: 10),

                  // 3. Horizontal Bottle Shelf (Interactive Centered 3D Draggable Test Tubes)
                  SizedBox(
                    height: 135,
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: ctrl.bottles.length,
                        itemBuilder: (context, index) {
                          final bottle = ctrl.bottles[index];
                          return DraggableBottleWidget(
                            bottle: bottle,
                            isSelected: ctrl.selectedType == bottle.type,
                            mixingTileArea: _mixingTileArea,
                            flameGame: _flameGame,
                            onTap: () {
                              ctrl.selectColorType(bottle.type);
                            },
                            onPourContinuous: (type, amountMl, nozzlePos) {
                              ctrl.pourPaintType(type, amountMl);
                            },
                            onPourEnd: () {
                              ctrl.checkCompletionOnPourEnd();
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),

              // Victory Celebration Overlay on Accuracy >= 95%
              if (ctrl.isCompleted)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF2C3E50).withValues(alpha: 0.45),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF00B894), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B894).withValues(alpha: 0.35),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, size: 72, color: Color(0xFFFFD700)),
                            const SizedBox(height: 16),
                            const Text(
                              'Perfect!',
                              style: TextStyle(
                                color: Color(0xFF00B894),
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Puzzle Complete!',
                              style: TextStyle(
                                color: Color(0xFF2C3E50),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Accuracy: ${ctrl.accuracy.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Color(0xFF0984E3),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: Color(0xFF00B894),
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Generating Next Target...',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
