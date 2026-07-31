import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../game/paint_background_game.dart';
import '../binding/level_selection_binding.dart';
import '../controller/level_selection_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Level Data Model (1000 levels)
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

// Generate 1000 levels: 1-15 completed, 16 current playing, 17-1000 locked
final List<_LevelData> _levels = List.generate(1000, (index) {
  final levelNum = index + 1;
  if (levelNum < 16) {
    // Completed level with 2 or 3 stars
    final stars = (levelNum % 3 == 0) ? 2 : 3;
    final hue = (levelNum * 25.0) % 360.0;
    final color = HSVColor.fromAHSV(1.0, hue, 0.75, 0.85).toColor();
    return _LevelData(
      number: levelNum,
      state: _LevelState.completed,
      stars: stars,
      targetColor: color,
    );
  } else if (levelNum == 16) {
    // Current on-going / active playing level
    return const _LevelData(
      number: 16,
      state: _LevelState.playing,
      stars: 0,
      targetColor: Color(0xFF008080),
    );
  } else {
    // Next locked levels
    return _LevelData(
      number: levelNum,
      state: _LevelState.locked,
      stars: 0,
      targetColor: const Color(0xFF4A4A4A),
    );
  }
});

// Grid configuration
const int _columns = 4;
const int _rows = 5;
const int _itemsPerPage = _columns * _rows; // 20 items per page

// ─────────────────────────────────────────────────────────────────────────────
// Screen Root Widget
// ─────────────────────────────────────────────────────────────────────────────

// ignore: must_be_immutable
class LevelSelectionScreen extends StatekitView<LevelSelectionController>
    implements LevelSelectionBinding {
  LevelSelectionScreen({super.key, super.tag});

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
  late PaintBackgroundGame _bgGame;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late PageController _pageController;

  int _currentPage = 0;
  final int _totalPages = (_levels.length / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();

    // Pulse animation for current playing level highlight
    _glowController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // Default to the page containing the current playing level (Level 16 -> Page 0)
    final playingIndex = _levels.indexWhere((l) => l.state == _LevelState.playing);
    if (playingIndex != -1) {
      _currentPage = (playingIndex / _itemsPerPage).floor();
    }
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  int get _completedCount => _levels.where((l) => l.state == _LevelState.completed).length;

  void _goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
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
                _Header(completedCount: _completedCount, totalCount: _levels.length),

                const SizedBox(height: 6),

                // ── Total Progress Bar ────────────────────────────────────
                _ProgressBar(completed: _completedCount, total: _levels.length),

                const SizedBox(height: 8),

                // ── Legend Row (Completed, Playing, Locked) ───────────────
                const _LegendRow(),

                const SizedBox(height: 8),

                // ── Page View Grid with Silky Smooth Carousel Physics ──────
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
                            // Smooth Page Scale & Fade Transition
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
  /// Guarantees zero layout overflow on all device screen sizes.
  Widget _buildCustomGridPage(int pageIndex) {
    return Column(
      children: List.generate(_rows, (rowIndex) {
        return Expanded(
          child: Row(
            children: List.generate(_columns, (colIndex) {
              final itemIndex = pageIndex * _itemsPerPage + rowIndex * _columns + colIndex;

              if (itemIndex >= _levels.length) {
                return const Expanded(child: SizedBox());
              }

              final level = _levels[itemIndex];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.5),
                  child: _LevelCard(
                    level: level,
                    glowValue: _glowAnimation.value,
                    onTap: level.state != _LevelState.locked
                        ? () => widget.controller.onLevelTapped(context, itemIndex)
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
            onTap: () => Navigator.pop(context),
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
// Total Progress Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final double ratio = completed / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.01, 1.0),
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFF4CAF50)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Overall Progress: ${(ratio * 100).toStringAsFixed(1)}% ($completed / $total)',
            style: TextStyle(
              color: const Color(0xFFF5DEB3).withValues(alpha: 0.8),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend Row
// ─────────────────────────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF4CAF50), Icons.star_rounded, 'Completed'),
        const SizedBox(width: 16),
        _legendItem(const Color(0xFFFFD700), Icons.play_circle_fill_rounded, 'Playing'),
        const SizedBox(width: 16),
        _legendItem(const Color(0xFF8D6228), Icons.lock_rounded, 'Locked'),
      ],
    );
  }

  Widget _legendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFF5DEB3).withValues(alpha: 0.85),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
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
// Level Item Card Widget — Matches _Header Cream Tan Wood Theme
// ─────────────────────────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final _LevelData level;
  final double glowValue;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.glowValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = level.state == _LevelState.completed;
    final bool isPlaying = level.state == _LevelState.playing;
    final bool isLocked = level.state == _LevelState.locked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _cardGradient(isCompleted, isPlaying, isLocked),
          border: Border.all(
            color: _borderColor(isCompleted, isPlaying, isLocked, glowValue),
            width: isPlaying ? 2.5 : 1.6,
          ),
          boxShadow: _cardShadow(isCompleted, isPlaying, isLocked, glowValue),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Top: Target Color Swatch Dot ────────────────────────────
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isLocked
                    ? const Color(0xFF5D4037).withValues(alpha: 0.25)
                    : level.targetColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLocked
                      ? Colors.transparent
                      : const Color(0xFFD4A055).withValues(alpha: 0.6),
                  width: 1.0,
                ),
                boxShadow: isLocked
                    ? null
                    : [
                        BoxShadow(
                          color: level.targetColor.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
              ),
            ),

            // ── Center: Level Number ───────────────────────────────────
            Text(
              '${level.number}',
              style: TextStyle(
                color: isLocked
                    ? const Color(0xFFF5DEB3).withValues(alpha: 0.35)
                    : isPlaying
                        ? const Color(0xFF3B1E08)
                        : const Color(0xFF5D4037),
                fontWeight: FontWeight.w900,
                fontSize: level.number > 999 ? 12 : 14,
                letterSpacing: 0.5,
                shadows: isPlaying
                    ? [
                        Shadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ]
                    : (isCompleted
                        ? const [
                            Shadow(
                              color: Color(0x22000000),
                              offset: Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ]
                        : null),
              ),
            ),

            // ── Bottom: Status Element (Stars, Playing Badge, or Lock) ──
            _buildStatusFooter(isCompleted, isPlaying, isLocked),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFooter(bool isCompleted, bool isPlaying, bool isLocked) {
    if (isCompleted) {
      // 1 to 3 Golden Stars matching _Header wood palette
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (starIndex) {
          final bool active = starIndex < level.stars;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: Icon(
              Icons.star_rounded,
              size: 12,
              color: active ? const Color(0xFFE67E22) : const Color(0x335D4037),
            ),
          );
        }),
      );
    } else if (isPlaying) {
      // Active Playing Badge matching _Header theme
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withValues(alpha: glowValue),
              const Color(0xFFFF8F00).withValues(alpha: glowValue * 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: glowValue * 0.6),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              size: 10,
              color: Color(0xFF3B1E08),
            ),
            SizedBox(width: 1),
            Text(
              'PLAY',
              style: TextStyle(
                color: Color(0xFF3B1E08),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    } else {
      // Locked Status Icon
      return Icon(
        Icons.lock_rounded,
        size: 11,
        color: const Color(0xFFF5DEB3).withValues(alpha: 0.35),
      );
    }
  }

  LinearGradient _cardGradient(
      bool isCompleted, bool isPlaying, bool isLocked) {
    if (isPlaying) {
      // Bright active parchment gradient (matching _Header theme)
      return const LinearGradient(
        colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    if (isCompleted) {
      // Warm cream tan parchment gradient (EXACTLY matching _Header)
      return const LinearGradient(
        colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    // Locked — semi-transparent dark wood tan tint
    return LinearGradient(
      colors: [
        const Color(0xFF4A2F17).withValues(alpha: 0.55),
        const Color(0xFF3B1E08).withValues(alpha: 0.55),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Color _borderColor(
      bool isCompleted, bool isPlaying, bool isLocked, double glow) {
    if (isPlaying) {
      return const Color(0xFFFFD700).withValues(alpha: glow);
    }
    if (isCompleted) {
      return const Color(0xFFD4A055); // Matching _Header border color
    }
    return const Color(0xFFD4A055).withValues(alpha: 0.22);
  }

  List<BoxShadow> _cardShadow(
      bool isCompleted, bool isPlaying, bool isLocked, double glow) {
    if (isPlaying) {
      return [
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: glow * 0.5),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    }
    if (isCompleted) {
      return [
        BoxShadow(
          color: const Color(0xFF3B1E08).withValues(alpha: 0.25),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
    }
    return [];
  }
}

