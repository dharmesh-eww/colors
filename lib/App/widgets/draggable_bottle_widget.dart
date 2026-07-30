import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Matrix4;
import '../core/models/paint_model.dart';
import '../game/paint_mixing_game.dart';

class DraggableBottleWidget extends StatefulWidget {
  final PaintBottle bottle;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(PaintType type, double amountMl, Offset nozzlePosition) onPourContinuous;
  final VoidCallback? onPourEnd;
  final PaintMixingGame? flameGame;
  final Rect mixingTileArea;

  const DraggableBottleWidget({
    super.key,
    required this.bottle,
    required this.isSelected,
    required this.onTap,
    required this.onPourContinuous,
    this.onPourEnd,
    this.flameGame,
    required this.mixingTileArea,
  });

  @override
  State<DraggableBottleWidget> createState() => _DraggableBottleWidgetState();
}

class _DraggableBottleWidgetState extends State<DraggableBottleWidget> {
  bool _isOverTile = false;
  Timer? _pourTimer;
  Timer? _rotationDelayTimer;
  Offset _currentDragGlobalPos = Offset.zero;

  void _startPouring() {
    _pourTimer?.cancel();
    _rotationDelayTimer?.cancel();

    _rotationDelayTimer = Timer(const Duration(milliseconds: 150), () {
      _pourTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (widget.bottle.availableMl <= 0) {
          _stopPouring();
          return;
        }

        widget.onPourContinuous(widget.bottle.type, 2.5, _currentDragGlobalPos);

        if (widget.flameGame != null && _currentDragGlobalPos != Offset.zero) {
          widget.flameGame!.spawnDropletStream(
            bottleNozzlePos: Vector2(_currentDragGlobalPos.dx, _currentDragGlobalPos.dy),
            color: widget.bottle.color,
            targetTilePos: Vector2(
              widget.mixingTileArea.center.dx,
              widget.mixingTileArea.center.dy,
            ),
          );
        }
      });
    });
  }

  void _stopPouring() {
    _rotationDelayTimer?.cancel();
    _rotationDelayTimer = null;
    _pourTimer?.cancel();
    _pourTimer = null;
  }

  void _resetDrag() {
    _stopPouring();
    if (_isOverTile) {
      setState(() {
        _isOverTile = false;
        _currentDragGlobalPos = Offset.zero;
      });
    }
    widget.onPourEnd?.call();
  }

  @override
  void dispose() {
    _rotationDelayTimer?.cancel();
    _pourTimer?.cancel();
    super.dispose();
  }

  /// Builds ONLY the Test Tube bottle graphic itself with 90 degree rotation when over tile.
  Widget _buildTestTubeGraphic({required bool isDragging, required bool isTilted}) {
    final bottle = widget.bottle;
    final Color bottleColor = bottle.color;
    final double fillRatio = (bottle.availableMl / 100.0).clamp(0.0, 1.0);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: isTilted
            ? (Matrix4.identity()
              ..rotateZ(-pi / 2)
              ..multiply(Matrix4.diagonal3Values(1.2, 1.2, 1.0)))
            : (isDragging
                ? (Matrix4.identity()..multiply(Matrix4.diagonal3Values(1.15, 1.15, 1.0)))
                : Matrix4.identity()),
        transformAlignment: Alignment.topCenter,
        child: SizedBox(
          height: 62,
          width: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Test Tube Top Rim Lip (Golden Metallic Lip)
              Positioned(
                top: 0,
                child: Container(
                  height: 6,
                  width: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFF2A1), Color(0xFFE67E22)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(color: bottleColor.withValues(alpha: 0.5), blurRadius: 4),
                    ],
                  ),
                ),
              ),

              // Main Test Tube Cylindrical Body
              Positioned(
                top: 4,
                child: Container(
                  height: 55,
                  width: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FF),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                      bottom: Radius.circular(15),
                    ),
                    border: Border.all(color: Colors.white, width: 2.0),
                    boxShadow: [
                      BoxShadow(color: bottleColor.withValues(alpha: 0.4), blurRadius: 8),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Liquid Fill
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 200),
                          widthFactor: 1.0,
                          heightFactor: fillRatio,
                          child: Container(
                            decoration: BoxDecoration(
                              color: bottleColor,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(13),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: bottleColor.withValues(alpha: 0.7),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Graduation Measurement Lines
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            3,
                            (index) => Container(
                              margin: const EdgeInsets.only(left: 2),
                              height: 1.5,
                              width: (index == 1) ? 10 : 6,
                              color: const Color(0xFF4A6572).withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),

                      // Glass Highlight Reflective Line
                      Positioned(
                        top: 4,
                        right: 3,
                        bottom: 6,
                        child: Container(
                          width: 2.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Emoji Cap
              Positioned(top: -2, child: Text(bottle.emoji, style: const TextStyle(fontSize: 12))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottle = widget.bottle;
    final Color bottleColor = bottle.color;

    // Unity Casual Game Pedestal Gradients
    final List<Color> cardGradient = widget.isSelected
        ? const [Color(0xFF6C5CE7), Color(0xFF4834D4)]
        : const [Color(0xFFF0F4FF), Color(0xFFE2ECFF)];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        width: 84,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: widget.isSelected ? const Color(0xFFFFD700) : const Color(0xFFC7DCFF),
            width: widget.isSelected ? 2.8 : 1.5,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF74B9FF).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Draggable Test Tube Bottle Graphic ONLY (Centered)
            Center(
              child: Draggable<PaintType>(
                data: bottle.type,
                feedback: _buildTestTubeGraphic(isDragging: true, isTilted: _isOverTile),
                childWhenDragging: Opacity(
                  opacity: 0.25,
                  child: _buildTestTubeGraphic(isDragging: false, isTilted: false),
                ),
                onDragStarted: () {
                  widget.onTap();
                },
                onDragUpdate: (details) {
                  _currentDragGlobalPos = details.globalPosition;
                  final bool isCurrentlyOverTile = widget.mixingTileArea.contains(
                    _currentDragGlobalPos,
                  );

                  if (isCurrentlyOverTile != _isOverTile) {
                    setState(() {
                      _isOverTile = isCurrentlyOverTile;
                    });
                    if (isCurrentlyOverTile) {
                      _startPouring();
                    } else {
                      _stopPouring();
                    }
                  }
                },
                onDragEnd: (details) => _resetDrag(),
                onDraggableCanceled: (velocity, offset) => _resetDrag(),
                child: _buildTestTubeGraphic(isDragging: false, isTilted: false),
              ),
            ),

            const SizedBox(height: 4),

            // 2. Bottle Name Label (Centered, 3D Game Font Style)
            Text(
              bottle.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isSelected ? Colors.white : const Color(0xFF2C3E50),
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
                shadows: widget.isSelected
                    ? const [
                        Shadow(
                          color: Color(0xFF2C3E50),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),

            const SizedBox(height: 3),

            // 3. Unity Game Stat Volume Badge (Centered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : bottleColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: widget.isSelected ? Colors.white : bottleColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Text(
                '${bottle.availableMl.round()} ml',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.isSelected
                      ? Colors.white
                      : (bottle.type == PaintType.black
                          ? const Color(0xFF2C3E50)
                          : (bottle.type == PaintType.white ? Colors.grey.shade800 : bottleColor)),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
