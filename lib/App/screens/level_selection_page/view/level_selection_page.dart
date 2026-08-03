import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/puzzle/puzzle_generator.dart';
import '../../../core/services/level_storage_service.dart';
import '../../../game/paint_background_game.dart';
import '../binding/level_selection_page.dart';
import '../controller/level_selection_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Level Data Model
// ─────────────────────────────────────────────────────────────────────────────
enum _LevelState { completed, playing, locked }

class _LevelData {
  final int number;
  final _LevelState state;
  final int stars; // 1 to 3 for completed, 0 for playing/locked
  final Color targetColor;

  const _LevelData({
    required this.number,
    required this.state,
    this.stars = 0,
    required this.targetColor,
  });
}

// Grid configuration
const int _totalLevelsCount = 1000;
const int _columns = 4;
const int _rows = 5;
const int _itemsPerPage = _columns * _rows; // 20 items per page

// ─────────────────────────────────────────────────────────────────────────────
// Screen Root Widget
// ─────────────────────────────────────────────────────────────────────────────

class LevelSelectionPage extends StatekitView<LevelSelectionController>
    implements LevelSelectionBinding {
  LevelSelectionPage({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _LevelSelectionBody(controller: controller);
  }

  @override
  void onLevelTapped(int levelIndex) {}
}

class _LevelSelectionBody extends StatefulWidget {
  final LevelSelectionController controller;
  const _LevelSelectionBody({required this.controller});

  @override
  State<_LevelSelectionBody> createState() => _LevelSelectionBodyState();
}

class _LevelSelectionBodyState extends State<_LevelSelectionBody>
    with SingleTickerProviderStateMixin {
  final LevelStorageService _levelStorageService = LevelStorageService();
  late PaintBackgroundGame _bgGame;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late PageController _pageController;

  int _currentPage = 0;
  int _unlockedLevel = 1;
  Map<int, int> _levelStarsMap = {};
  final int _totalPages = (_totalLevelsCount / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();

    // Pulse animation for current playing level highlight & floating hero bottle
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _pageController = PageController(initialPage: 0);
    _loadUnlockedLevel();
  }

  void _loadUnlockedLevel() async {
    final unlocked = await _levelStorageService.getUnlockedLevel();
    final Map<int, int> starsMap = {};
    for (int i = 1; i < unlocked; i++) {
      starsMap[i] = await _levelStorageService.getLevelStars(i);
    }
    if (mounted) {
      setState(() {
        _unlockedLevel = unlocked;
        _levelStarsMap = starsMap;
        final targetPage = ((_unlockedLevel - 1) / _itemsPerPage).floor().clamp(0, _totalPages - 1);
        _currentPage = targetPage;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentPage);
        }
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  int get _completedCount => (_unlockedLevel - 1).clamp(0, _totalLevelsCount);

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  _LevelData _getLevelData(int itemIndex) {
    final levelNum = itemIndex + 1;
    final puzzle = PuzzleGenerator.generateLevel(levelNum);

    if (levelNum < _unlockedLevel) {
      // Completed level
      final storedStars = _levelStarsMap[levelNum];
      final stars = (storedStars != null && storedStars > 0) ? storedStars : ((levelNum % 3 == 0) ? 2 : 3);
      return _LevelData(
        number: levelNum,
        state: _LevelState.completed,
        stars: stars,
        targetColor: puzzle.targetColor,
      );
    } else if (levelNum == _unlockedLevel) {
      // Current active playing level
      return _LevelData(
        number: levelNum,
        state: _LevelState.playing,
        stars: 0,
        targetColor: puzzle.targetColor,
      );
    } else {
      // Locked level
      return _LevelData(
        number: levelNum,
        state: _LevelState.locked,
        stars: 0,
        targetColor: const Color(0xFF4A4A4A),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: Stack(
        children: [
          // ── Layer 1: Warm Wood Background ──────────────────────────────
          Positioned.fill(child: GameWidget(game: _bgGame)),

          // ── Layer 2: Content Layout ────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header Panel ──────────────────────────────────────────
                _Header(completedCount: _completedCount, totalCount: _totalLevelsCount),

                const SizedBox(height: 16),

                // ── 1000 Level Matrix Grid PageView ───────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemCount: _totalPages,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, pageIndex) {
                        return AnimatedBuilder(
                          animation: Listenable.merge([_pageController, _glowAnimation]),
                          builder: (context, child) {
                            double pageOffset = 0.0;
                            if (_pageController.position.haveDimensions) {
                              pageOffset =
                                  (_pageController.page ?? _currentPage.toDouble()) - pageIndex;
                            } else {
                              pageOffset = (_currentPage - pageIndex).toDouble();
                            }

                            final double scale = (1.0 - (pageOffset.abs() * 0.12)).clamp(0.88, 1.0);
                            final double opacity = (1.0 - (pageOffset.abs() * 0.45)).clamp(
                              0.35,
                              1.0,
                            );

                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: opacity,
                                child: _buildCustomGridPage(pageIndex),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // ── Page Navigation Controls ──────────────────────────────
                _PageNavigationControls(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPrevPage: () => _goToPage(_currentPage - 1),
                  onNextPage: () => _goToPage(_currentPage + 1),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Custom 4x5 Grid implementation built using Column + Row + Expanded (No GridView)
  Widget _buildCustomGridPage(int pageIndex) {
    return Column(
      children: List.generate(_rows, (rowIndex) {
        return Expanded(
          child: Row(
            children: List.generate(_columns, (colIndex) {
              final itemIndex = pageIndex * _itemsPerPage + rowIndex * _columns + colIndex;

              if (itemIndex >= _totalLevelsCount) {
                return const Expanded(child: SizedBox());
              }

              final level = _getLevelData(itemIndex);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: _LevelCard(
                    level: level,
                    glowValue: _glowAnimation.value,
                    onTap: level.state != _LevelState.locked
                        ? () async {
                            await widget.controller.onLevelTapped(context, itemIndex);
                            _loadUnlockedLevel();
                          }
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — Warm Cream Panel
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  const _Header({required this.completedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
            // onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8C898),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF5D4037), size: 26),
            ),
          ),

          // Title
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEVEL SELECT',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Color Lab · 1000 Levels',
                  style: TextStyle(
                    color: Color(0xFF8D6228),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Completion badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$completedCount/$totalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'DONE',
                  style: TextStyle(
                    color: Color(0xFFB9F6CA),
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page Navigation Controls (< Page X / Y >)
// ─────────────────────────────────────────────────────────────────────────────
class _PageNavigationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;

  const _PageNavigationControls({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevPage,
    required this.onNextPage,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoPrev = currentPage > 0;
    final bool canGoNext = currentPage < totalPages - 1;

    final startLevel = currentPage * _itemsPerPage + 1;
    final endLevel = (startLevel + _itemsPerPage - 1).clamp(1, 1000);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Page Button
          GestureDetector(
            onTap: canGoPrev ? onPrevPage : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: canGoPrev
                    ? const Color(0xFFD4A055)
                    : const Color(0xFF5D3A1A).withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: canGoPrev
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF8D6228).withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: canGoPrev ? const Color(0xFF3B1E08) : Colors.white24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Page Indicator Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1E08).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4A055), width: 1.2),
            ),
            child: Text(
              'Page ${currentPage + 1} / $totalPages  ·  Levels $startLevel - $endLevel',
              style: const TextStyle(
                color: Color(0xFFF5DEB3),
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Next Page Button
          GestureDetector(
            onTap: canGoNext ? onNextPage : null,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: canGoNext
                    ? const Color(0xFFD4A055)
                    : const Color(0xFF5D3A1A).withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: canGoNext
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF8D6228).withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: canGoNext ? const Color(0xFF3B1E08) : Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final _LevelData level;
  final double glowValue;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, required this.glowValue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = level.state == _LevelState.completed;
    final bool isPlaying = level.state == _LevelState.playing;
    final bool isLocked = level.state == _LevelState.locked;

    // Scale pulse for active playing level
    final double cardScale = isPlaying ? 0.97 + (glowValue - 0.6) * 0.08 : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double fontSize = level.number > 999 ? 11.0 : 14.0;
        final double textSize = fontSize + 6.0;
        final double totalHeight = constraints.hasBoundedHeight ? constraints.maxHeight : 78.0;
        final double remainingHeight = (totalHeight - textSize).clamp(0.0, totalHeight);
        final double bottleWidth = remainingHeight * (64.0 / 72.0);

        return GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: cardScale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: bottleWidth,
                  height: remainingHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _HeroPotionBottlePainter(
                          targetColor: level.targetColor,
                          isCompleted: isCompleted,
                          isPlaying: isPlaying,
                          isLocked: isLocked,
                          glowValue: glowValue,
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0.0, 0.8),
                        child: _buildStatusFooter(isCompleted, isPlaying, isLocked),
                      ),
                    ],
                  ),
                ),

                // ── Level Number (White Text) ──────────────────────────
                Text(
                  '${level.number}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: fontSize,
                    height: 1.1,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(color: Color(0xAA000000), offset: Offset(0, 1.5), blurRadius: 2),
                    ],
                  ),
                ),

                // ── Status Footer (Stars for Completed, Lock Icon for Locked, None for Current) ──
              ],
            ),
          ),
        );
      },
    );
  }

  /// Status footer: 1 to 3 stars for completed, Lock Icon for locked, empty for current level
  Widget _buildStatusFooter(bool isCompleted, bool isPlaying, bool isLocked) {
    if (isCompleted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (starIndex) {
          final bool active = starIndex < level.stars;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: Icon(
              Icons.star_rounded,
              size: 15,
              color: active ? const Color(0xFFFFD700) : const Color(0x44FFFFFF),
            ),
          );
        }),
      );
    }
    return SizedBox();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter: Rectangular Ink Bottle + Sliced Wooden Log Pedestal Stand
// ─────────────────────────────────────────────────────────────────────────────
class _HeroPotionBottlePainter extends CustomPainter {
  final Color targetColor;
  final bool isCompleted;
  final bool isPlaying;
  final bool isLocked;
  final double glowValue;

  _HeroPotionBottlePainter({
    required this.targetColor,
    required this.isCompleted,
    required this.isPlaying,
    required this.isLocked,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── 1. Bottle Geometry & Coordinates ───────────────────────────────
    final double bottleH = h * 0.60;
    final double bottleW = w * 0.50;
    final double bottleX = (w - bottleW) / 2;

    // Cork Stopper
    final double corkH = bottleH * 0.12;
    final double corkW = bottleW * 0.36;
    final double corkX = (w - corkW) / 2;
    final double corkY = h * 0.10;

    // Bottle Neck
    final double neckH = bottleH * 0.16;
    final double neckW = bottleW * 0.38;
    final double neckX = (w - neckW) / 2;
    final double neckY = corkY + corkH;

    // Bottle Body
    final double bodyY = neckY + neckH;
    final double bodyH = bottleH - (corkH + neckH);

    // ── 0. Glow Aura for active playing level ───────────────────────────
    if (isPlaying) {
      final double glowRadius = w * 0.55 * glowValue;
      canvas.drawCircle(
        Offset(w * 0.5, bodyY + bodyH * 0.5),
        glowRadius,
        Paint()
          ..color = targetColor.withValues(alpha: 0.35 * glowValue)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * glowValue),
      );
    }

    // ── 1. Sliced Wooden Log Disk Pedestal Stand (Underneath Bottle) ──────
    final double pedestalY = h * 0.6;
    final double pedestalH = h * 0.32;
    final double pedestalW = w * 0.90;
    final double pedestalX = (w - pedestalW) / 2;

    // Drop shadow under wooden pedestal
    canvas.drawOval(
      Rect.fromLTWH(pedestalX, pedestalY + pedestalH * 0.4, pedestalW, pedestalH * 0.5),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Pedestal bottom plank thickness edge
    const woodRimColor = Color(0xFF8D6228);
    const woodTopColor = Color(0xFFC68B59);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pedestalX, pedestalY + 3, pedestalW, pedestalH - 3),
        Radius.circular(pedestalH * 0.5),
      ),
      Paint()..color = woodRimColor,
    );

    // Pedestal top log slice surface
    canvas.drawOval(
      Rect.fromLTWH(pedestalX, pedestalY, pedestalW, pedestalH * 0.75),
      Paint()..color = woodTopColor,
    );

    // Pedestal surface wood ring highlights
    canvas.drawOval(
      Rect.fromLTWH(pedestalX + 3, pedestalY + 1.5, pedestalW - 6, (pedestalH * 0.75) - 3),
      Paint()
        ..color = const Color(0xFFE5AA70).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // ── 2. Bottle Painting ────────────────────────────────────────────────
    final corkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(corkX, corkY, corkW, corkH),
      const Radius.circular(3),
    );

    canvas.drawRRect(
      corkRect,
      Paint()
        ..color = isLocked ? const Color(0xFF757575) : const Color(0xFFD4A055)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      corkRect,
      Paint()
        ..color = isLocked
            ? const Color(0xFF555555).withValues(alpha: 0.6)
            : const Color(0xFF8D6228).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Cork grain lines
    final grainPaint = Paint()
      ..color = isLocked
          ? const Color(0xFF444444).withValues(alpha: 0.35)
          : const Color(0xFF8D6228).withValues(alpha: 0.35)
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

    // Bottle Neck Painting
    final neckRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(neckX, neckY, neckW, neckH),
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
    );

    canvas.drawRRect(
      neckRect,
      Paint()
        ..color = isLocked
            ? Colors.white.withValues(alpha: 0.12)
            : const Color(0xFFD6EAF8).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      neckRect,
      Paint()
        ..color = isLocked
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Bottle Body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bottleX, bodyY, bottleW, bodyH),
      const Radius.circular(8),
    );

    // Glass body background
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = isLocked
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFD6EAF8).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    // Liquid Fill (Clipped to body)
    canvas.save();
    canvas.clipRRect(bodyRect);

    if (!isLocked) {
      const double fillRatio = 0.65;
      final double liquidTopY = bodyY + bodyH * (1.0 - fillRatio);

      final liquidPath = Path();
      liquidPath.moveTo(bottleX, liquidTopY + 3);
      for (double x = bottleX; x <= bottleX + bottleW; x += 2) {
        final y = liquidTopY + sin((x - bottleX) / bottleW * 2 * pi) * 2.5;
        liquidPath.lineTo(x, y);
      }
      liquidPath.lineTo(bottleX + bottleW, liquidTopY + bodyH);
      liquidPath.lineTo(bottleX, liquidTopY + bodyH);
      liquidPath.close();

      final Color liquidColor = targetColor == Colors.white
          ? const Color(0xFFEEEEEE).withValues(alpha: 0.9)
          : (targetColor == Colors.black
                ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                : targetColor.withValues(alpha: 0.85));

      canvas.drawPath(
        liquidPath,
        Paint()
          ..color = liquidColor
          ..style = PaintingStyle.fill,
      );

      // Liquid surface shimmer
      canvas.drawLine(
        Offset(bottleX + 4, liquidTopY + 2),
        Offset(bottleX + bottleW - 4, liquidTopY + 2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 1.5,
      );
    } else {
      // Locked state grayscale liquid fill
      final double liquidTopY = bodyY + bodyH * 0.35;
      canvas.drawRect(
        Rect.fromLTWH(bottleX, liquidTopY, bottleW, bodyH * 0.65),
        Paint()..color = Colors.white.withValues(alpha: 0.1),
      );
    }

    canvas.restore();

    // Body Border
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = isLocked
            ? Colors.white.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Label Area
    final double labelY = bodyY + bodyH * 0.28;
    final double labelH = bodyH * 0.34;
    final labelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bottleX + bottleW * 0.10, labelY, bottleW * 0.80, labelH),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      labelRect,
      Paint()
        ..color = Colors.white.withValues(alpha: isLocked ? 0.1 : 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      labelRect,
      Paint()
        ..color = Colors.white.withValues(alpha: isLocked ? 0.25 : 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Metallic Keyhole Padlock Icon for Locked State
    if (isLocked) {
      final lockW = bottleW * 0.30;
      final lockH = bodyH * 0.28;
      final lockX = (w - lockW) / 2;
      final lockY = labelY + (labelH - lockH * 0.75) / 2;

      // Shackle
      final shackleRect = Rect.fromLTWH(
        lockX + lockW * 0.2,
        lockY - lockH * 0.25,
        lockW * 0.6,
        lockH * 0.5,
      );
      canvas.drawArc(
        shackleRect,
        3.14,
        3.14,
        false,
        Paint()
          ..color = const Color(0xFFE0E0E0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      // Lock Body
      final lockBodyRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(lockX, lockY, lockW, lockH * 0.75),
        const Radius.circular(2.5),
      );

      canvas.drawRRect(
        lockBodyRect,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(lockBodyRect.outerRect),
      );

      // Keyhole
      canvas.drawCircle(
        Offset(w * 0.5, lockY + lockH * 0.3),
        1.5,
        Paint()..color = const Color(0xFF333333),
      );
      final keyholePath = Path()
        ..moveTo(w * 0.5 - 1.0, lockY + lockH * 0.3)
        ..lineTo(w * 0.5 + 1.0, lockY + lockH * 0.3)
        ..lineTo(w * 0.5 + 1.4, lockY + lockH * 0.48)
        ..lineTo(w * 0.5 - 1.4, lockY + lockH * 0.48)
        ..close();
      canvas.drawPath(keyholePath, Paint()..color = const Color(0xFF333333));
    }
  }

  @override
  bool shouldRepaint(covariant _HeroPotionBottlePainter oldDelegate) =>
      oldDelegate.targetColor != targetColor ||
      oldDelegate.isCompleted != isCompleted ||
      oldDelegate.isPlaying != isPlaying ||
      oldDelegate.isLocked != isLocked ||
      oldDelegate.glowValue != glowValue;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mode Segmented Switcher (Difficulty Modes vs 1000 Levels)
// ─────────────────────────────────────────────────────────────────────────────
