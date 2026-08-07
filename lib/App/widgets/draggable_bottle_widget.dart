import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Matrix4;
import '../core/enums/bottle_interaction_mode.dart';
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
  final BottleInteractionMode bottleInteractionMode;
  final bool isHintActive;
  final double targetAmountMl;

  const DraggableBottleWidget({
    super.key,
    required this.bottle,
    required this.isSelected,
    required this.onTap,
    required this.onPourContinuous,
    this.onPourEnd,
    this.flameGame,
    required this.mixingTileArea,
    this.bottleInteractionMode = BottleInteractionMode.drag,
    this.isHintActive = false,
    this.targetAmountMl = 0.0,
  });

  @override
  State<DraggableBottleWidget> createState() => _DraggableBottleWidgetState();
}

class _DraggableBottleWidgetState extends State<DraggableBottleWidget> {
  bool _isOverTile = false;
  Timer? _pourTimer;
  Timer? _rotationDelayTimer;
  Offset _currentDragGlobalPos = Offset.zero;
  late final ValueNotifier<double> _availableMlNotifier;

  @override
  void initState() {
    super.initState();
    _availableMlNotifier = ValueNotifier<double>(widget.bottle.availableMl);
  }

  @override
  void didUpdateWidget(covariant DraggableBottleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_availableMlNotifier.value != widget.bottle.availableMl) {
      _availableMlNotifier.value = widget.bottle.availableMl;
    }
  }

  final GlobalKey _bottleKey = GlobalKey();

  Offset _getNozzleGlobalPosition(Offset dragGlobalPos, bool isTilted) {
    if (!isTilted) {
      return Offset(dragGlobalPos.dx, dragGlobalPos.dy);
    }
    // When bottle feedback is rotated by -pi * 0.52 (~-93.6 deg):
    // Bottle dimensions: 52 x 75. Center: (26, 37.5).
    // Spout nozzle top: (26, 4) -> relative to center: (0, -33.5).
    const double angle = -pi * 0.52;
    const double relX = 0.0;
    const double relY = -33.5;

    final double rotX = relX * cos(angle) - relY * sin(angle);
    final double rotY = relX * sin(angle) + relY * cos(angle);

    return Offset(dragGlobalPos.dx + rotX, dragGlobalPos.dy + rotY);
  }

  void _startPouring() {
    _pourTimer?.cancel();
    _rotationDelayTimer?.cancel();

    _rotationDelayTimer = Timer(const Duration(milliseconds: 80), () {
      if (widget.flameGame != null && _currentDragGlobalPos != Offset.zero) {
        final nozzlePos = _getNozzleGlobalPosition(_currentDragGlobalPos, true);
        widget.flameGame!.startLiquidPour(
          bottleNozzlePos: Vector2(nozzlePos.dx, nozzlePos.dy),
          color: widget.bottle.color,
          targetTilePos: Vector2(widget.mixingTileArea.center.dx, widget.mixingTileArea.center.dy),
        );
      }

      _pourTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (widget.bottle.availableMl <= 0) {
          _stopPouring();
          return;
        }

        widget.onPourContinuous(widget.bottle.type, 2.5, _currentDragGlobalPos);
        _availableMlNotifier.value = widget.bottle.availableMl;

        if (widget.flameGame != null && _currentDragGlobalPos != Offset.zero) {
          final nozzlePos = _getNozzleGlobalPosition(_currentDragGlobalPos, true);
          widget.flameGame!.updateLiquidPour(
            bottleNozzlePos: Vector2(nozzlePos.dx, nozzlePos.dy),
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
    widget.flameGame?.stopLiquidPour();
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

  Offset _getBottleGlobalPosition() {
    final RenderBox? renderBox = _bottleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.attached) {
      final pos = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      // Top center of the upright bottle neck / spout
      return Offset(pos.dx + size.width / 2, pos.dy + 4.0);
    }
    final RenderBox? fallbackBox = context.findRenderObject() as RenderBox?;
    if (fallbackBox != null && fallbackBox.hasSize && fallbackBox.attached) {
      final pos = fallbackBox.localToGlobal(Offset.zero);
      final size = fallbackBox.size;
      return Offset(pos.dx + size.width / 2, pos.dy + 15.0);
    }
    return widget.mixingTileArea.center;
  }

  void _handleTapPour() {
    if (widget.bottle.availableMl <= 0) return;
    final bottlePos = _getBottleGlobalPosition();

    widget.onPourContinuous(widget.bottle.type, 5.0, bottlePos);
    _availableMlNotifier.value = widget.bottle.availableMl;

    if (widget.flameGame != null) {
      widget.flameGame!.startLiquidPour(
        bottleNozzlePos: Vector2(bottlePos.dx, bottlePos.dy),
        color: widget.bottle.color,
        targetTilePos: Vector2(widget.mixingTileArea.center.dx, widget.mixingTileArea.center.dy),
      );
      Timer(const Duration(milliseconds: 300), () {
        widget.flameGame?.stopLiquidPour();
        widget.onPourEnd?.call();
      });
    } else {
      widget.onPourEnd?.call();
    }
  }

  void _startTapPouring() {
    _pourTimer?.cancel();
    _rotationDelayTimer?.cancel();

    final bottlePos = _getBottleGlobalPosition();
    setState(() {
      _isOverTile = true;
    });

    if (widget.flameGame != null) {
      widget.flameGame!.startLiquidPour(
        bottleNozzlePos: Vector2(bottlePos.dx, bottlePos.dy),
        color: widget.bottle.color,
        targetTilePos: Vector2(widget.mixingTileArea.center.dx, widget.mixingTileArea.center.dy),
      );
    }

    _pourTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.bottle.availableMl <= 0) {
        _stopTapPouring();
        return;
      }

      final currentPos = _getBottleGlobalPosition();
      widget.onPourContinuous(widget.bottle.type, 2.5, currentPos);
      _availableMlNotifier.value = widget.bottle.availableMl;

      if (widget.flameGame != null) {
        widget.flameGame!.updateLiquidPour(
          bottleNozzlePos: Vector2(currentPos.dx, currentPos.dy),
          targetTilePos: Vector2(widget.mixingTileArea.center.dx, widget.mixingTileArea.center.dy),
        );
      }
    });
  }

  void _stopTapPouring() {
    _pourTimer?.cancel();
    _pourTimer = null;
    _rotationDelayTimer?.cancel();
    _rotationDelayTimer = null;
    widget.flameGame?.stopLiquidPour();
    if (_isOverTile) {
      setState(() {
        _isOverTile = false;
      });
    }
    widget.onPourEnd?.call();
  }

  @override
  void dispose() {
    _rotationDelayTimer?.cancel();
    _pourTimer?.cancel();
    widget.flameGame?.stopLiquidPour();
    _availableMlNotifier.dispose();
    super.dispose();
  }

  /// Build the corked ink bottle graphic using CustomPaint
  Widget _buildInkBottle({
    required bool isDragging,
    required bool isTilted,
    bool isUncorked = false,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: _availableMlNotifier,
      builder: (context, availableMl, child) {
        final bottle = widget.bottle;
        final double fillRatio = (availableMl / 100.0).clamp(0.0, 1.0);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          transform: isTilted
              ? (Matrix4.identity()
                  ..rotateZ(-pi * 0.52)
                  ..multiply(Matrix4.diagonal3Values(1.18, 1.18, 1.0)))
              : (isDragging
                    ? (Matrix4.identity()..multiply(Matrix4.diagonal3Values(1.12, 1.12, 1.0)))
                    : Matrix4.identity()),
          transformAlignment: Alignment.topCenter,
          child: Container(
            decoration: isDragging
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: bottle.color.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: 3,
                      ),
                    ],
                  )
                : null,
            child: SizedBox(
              key: isDragging ? null : _bottleKey,
              width: 52,
              height: 75,
              child: CustomPaint(
                painter: _InkBottlePainter(
                  color: bottle.color,
                  fillRatio: fillRatio,
                  isWhite: bottle.type == PaintType.white,
                  isBlack: bottle.type == PaintType.black,
                  isUncorked: isTilted || isUncorked,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottle = widget.bottle;
    final Color bottleColor = bottle.color;
    final bool isBlack = bottle.type == PaintType.black;
    final bool isWhite = bottle.type == PaintType.white;

    // Label text color
    final Color labelColor = (isBlack || isWhite) ? const Color(0xFF5D4037) : bottleColor;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (widget.bottleInteractionMode == BottleInteractionMode.tap) {
          _handleTapPour();
        }
      },
      onLongPressStart: (_) {
        widget.onTap();
        if (widget.bottleInteractionMode == BottleInteractionMode.tap) {
          _startTapPouring();
        }
      },
      onLongPressEnd: (_) {
        if (widget.bottleInteractionMode == BottleInteractionMode.tap) {
          _stopTapPouring();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: widget.isSelected ? 1.1 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Draggable Ink Bottle ──────────────────────────────────────
              Draggable<PaintType>(
                data: bottle.type,
                maxSimultaneousDrags: widget.bottleInteractionMode == BottleInteractionMode.drag
                    ? 1
                    : 0,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildInkBottle(isDragging: true, isTilted: _isOverTile),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.20,
                  child: _buildInkBottle(isDragging: false, isTilted: false),
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
                  } else if (isCurrentlyOverTile && widget.flameGame != null) {
                    final nozzlePos = _getNozzleGlobalPosition(_currentDragGlobalPos, true);
                    widget.flameGame!.updateLiquidPour(
                      bottleNozzlePos: Vector2(nozzlePos.dx, nozzlePos.dy),
                      targetTilePos: Vector2(
                        widget.mixingTileArea.center.dx,
                        widget.mixingTileArea.center.dy,
                      ),
                    );
                  }
                },
                onDragEnd: (details) => _resetDrag(),
                onDraggableCanceled: (velocity, offset) => _resetDrag(),
                child: _buildInkBottle(isDragging: false, isTilted: false, isUncorked: _isOverTile),
              ),

              // ── Hint Target Amount Badge (Shown when hint system is activated) ──
              if (widget.isHintActive) ...[
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: widget.targetAmountMl > 0
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFD4A055)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    color: widget.targetAmountMl <= 0
                        ? const Color(0xFF3B1E08).withValues(alpha: 0.35)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.targetAmountMl > 0
                          ? Colors.white
                          : const Color(0xFF8D6228).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: widget.targetAmountMl > 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: widget.targetAmountMl > 0
                            ? const Color(0xFF3B1E08)
                            : const Color(0xFFBCAAA4),
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.targetAmountMl.toStringAsFixed(0)} ml',
                        style: TextStyle(
                          color: widget.targetAmountMl > 0
                              ? const Color(0xFF3B1E08)
                              : const Color(0xFFBCAAA4),
                          fontWeight: FontWeight.w900,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 5),

              // ── Color Name Label ──────────────────────────────────────────
              Text(
                bottle.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isBlack
                      ? const Color(0xFF4E342E)
                      : (isWhite ? const Color(0xFF6D4C41) : labelColor),
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.3,
                  shadows: const [
                    Shadow(color: Color(0x44000000), offset: Offset(0, 1), blurRadius: 2),
                  ],
                ),
              ),

              const SizedBox(height: 2),

              // ── Hex Code Badge ────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                      : const Color(0xFF3B1E08).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.isSelected
                        ? const Color(0xFFFFD700)
                        : const Color(0xFFBCAAA4).withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  bottle.hexCode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isBlack
                        ? const Color(0xFF5D4037)
                        : (isWhite ? const Color(0xFF795548) : labelColor.withValues(alpha: 0.9)),
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    fontFamily: 'monospace',
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // ── Selection indicator dot ───────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: widget.isSelected ? 22 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Corked Ink Bottle CustomPainter
// ──────────────────────────────────────────────────────────────────────────────
class _InkBottlePainter extends CustomPainter {
  final Color color;
  final double fillRatio;
  final bool isWhite;
  final bool isBlack;
  final bool isUncorked;

  _InkBottlePainter({
    required this.color,
    required this.fillRatio,
    required this.isWhite,
    required this.isBlack,
    this.isUncorked = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Cork stopper / Open spout ───────────────────────────────────────────
    final double corkH = h * 0.12;
    final double corkW = w * 0.36;
    final double corkX = (w - corkW) / 2;
    final double corkY = 0;

    if (!isUncorked) {
      final corkRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(corkX, corkY, corkW, corkH),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        corkRect,
        Paint()
          ..color = const Color(0xFFD4A055)
          ..style = PaintingStyle.fill,
      );
      canvas.drawRRect(
        corkRect,
        Paint()
          ..color = const Color(0xFF8D6228).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Cork grain lines
      final grainPaint = Paint()
        ..color = const Color(0xFF8D6228).withValues(alpha: 0.35)
        ..strokeWidth = 0.8;
      canvas.drawLine(
        Offset(corkX + corkW * 0.3, corkY + 2),
        Offset(corkX + corkW * 0.3, corkY + corkH - 2),
        grainPaint,
      );
      canvas.drawLine(
        Offset(corkX + corkW * 0.65, corkY + 2),
        Offset(corkX + corkW * 0.65, corkY + corkH - 2),
        grainPaint,
      );
    } else {
      // Draw liquid glow at open spout nozzle
      canvas.drawCircle(
        Offset(w / 2, corkY + corkH / 2),
        4.5,
        Paint()
          ..color = color.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill,
      );
    }

    // ── Bottle neck ──────────────────────────────────────────────────────────
    final double neckH = h * 0.16;
    final double neckW = w * 0.38;
    final double neckX = (w - neckW) / 2;
    final double neckY = corkY + corkH;

    final neckRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(neckX, neckY, neckW, neckH),
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
    );

    canvas.drawRRect(
      neckRect,
      Paint()
        ..color = const Color(0xFFD6EAF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      neckRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // ── Bottle body ──────────────────────────────────────────────────────────
    final double bodyY = neckY + neckH;
    final double bodyH = h - bodyY;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, bodyY, w, bodyH),
      const Radius.circular(10),
    );

    // Glass body background
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = const Color(0xFFD6EAF8).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    // ── Liquid fill (clipped to body) ────────────────────────────────────────
    canvas.save();
    canvas.clipRRect(bodyRect);

    final double liquidTopY = bodyY + bodyH * (1.0 - fillRatio);

    final liquidPath = Path();
    liquidPath.moveTo(0, liquidTopY + 3);
    for (double x = 0; x <= w; x += 2) {
      final y = liquidTopY + sin(x / w * 2 * pi) * 2.5;
      liquidPath.lineTo(x, y);
    }
    liquidPath.lineTo(w, liquidTopY + bodyH);
    liquidPath.lineTo(0, liquidTopY + bodyH);
    liquidPath.close();

    canvas.drawPath(
      liquidPath,
      Paint()
        ..color = isWhite
            ? const Color(0xFFEEEEEE).withValues(alpha: 0.9)
            : (isBlack
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : color.withValues(alpha: 0.85))
        ..style = PaintingStyle.fill,
    );

    // Liquid surface shimmer
    canvas.drawLine(
      Offset(4, liquidTopY + 2),
      Offset(w - 4, liquidTopY + 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.5,
    );

    canvas.restore();

    // ── Body border ──────────────────────────────────────────────────────────
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // ── Glass highlight (left edge strip) ────────────────────────────────────
    final double hlX = w * 0.12;
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(hlX, bodyY + 8, 4, bodyH * 0.55),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      highlightRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    // Small secondary highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(hlX + 6, bodyY + 10, 2, bodyH * 0.25),
        const Radius.circular(2),
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    // ── Drop shadow under bottle ──────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromLTWH(w * 0.1, h - 4, w * 0.8, 6),
      Paint()
        ..color = const Color(0xFF3B1E08).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // ── Label area on bottle body ─────────────────────────────────────────────
    final double labelY = bodyY + bodyH * 0.30;
    final double labelH = bodyH * 0.32;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, labelY, w * 0.76, labelH),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      labelRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      labelRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _InkBottlePainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio ||
        oldDelegate.color != color ||
        oldDelegate.isUncorked != isUncorked;
  }
}
