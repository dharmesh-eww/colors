import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../game/paint_background_game.dart';
import '../binding/level_selection_binding.dart';
import '../controller/level_selection_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Level model (UI-only placeholder data)
// ─────────────────────────────────────────────────────────────────────────────
enum _LevelState { completed, playing, locked }

class _LevelData {
  final int number;
  final _LevelState state;
  final Color targetColor; // decorative only
  final String difficulty;

  const _LevelData({
    required this.number,
    required this.state,
    required this.targetColor,
    required this.difficulty,
  });
}

// Placeholder level list — 20 levels
final List<_LevelData> _levels = [
  const _LevelData(number: 1,  state: _LevelState.completed, targetColor: Color(0xFF008080), difficulty: 'Easy'),
  const _LevelData(number: 2,  state: _LevelState.completed, targetColor: Color(0xFFFF4500), difficulty: 'Easy'),
  const _LevelData(number: 3,  state: _LevelState.completed, targetColor: Color(0xFF9400D3), difficulty: 'Easy'),
  const _LevelData(number: 4,  state: _LevelState.completed, targetColor: Color(0xFF228B22), difficulty: 'Easy'),
  const _LevelData(number: 5,  state: _LevelState.completed, targetColor: Color(0xFF1E90FF), difficulty: 'Easy'),
  const _LevelData(number: 6,  state: _LevelState.completed, targetColor: Color(0xFFFF69B4), difficulty: 'Medium'),
  const _LevelData(number: 7,  state: _LevelState.completed, targetColor: Color(0xFFFFD700), difficulty: 'Medium'),
  const _LevelData(number: 8,  state: _LevelState.completed, targetColor: Color(0xFF8B4513), difficulty: 'Medium'),
  const _LevelData(number: 9,  state: _LevelState.playing,   targetColor: Color(0xFF006400), difficulty: 'Medium'),
  const _LevelData(number: 10, state: _LevelState.locked,    targetColor: Color(0xFFDC143C), difficulty: 'Medium'),
  const _LevelData(number: 11, state: _LevelState.locked,    targetColor: Color(0xFF00CED1), difficulty: 'Hard'),
  const _LevelData(number: 12, state: _LevelState.locked,    targetColor: Color(0xFF8A2BE2), difficulty: 'Hard'),
  const _LevelData(number: 13, state: _LevelState.locked,    targetColor: Color(0xFF2F4F4F), difficulty: 'Hard'),
  const _LevelData(number: 14, state: _LevelState.locked,    targetColor: Color(0xFFB8860B), difficulty: 'Hard'),
  const _LevelData(number: 15, state: _LevelState.locked,    targetColor: Color(0xFF4169E1), difficulty: 'Hard'),
  const _LevelData(number: 16, state: _LevelState.locked,    targetColor: Color(0xFF800000), difficulty: 'Expert'),
  const _LevelData(number: 17, state: _LevelState.locked,    targetColor: Color(0xFF556B2F), difficulty: 'Expert'),
  const _LevelData(number: 18, state: _LevelState.locked,    targetColor: Color(0xFF5F9EA0), difficulty: 'Expert'),
  const _LevelData(number: 19, state: _LevelState.locked,    targetColor: Color(0xFFA0522D), difficulty: 'Expert'),
  const _LevelData(number: 20, state: _LevelState.locked,    targetColor: Color(0xFF191970), difficulty: 'Expert'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
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

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  int get _completedCount =>
      _levels.where((l) => l.state == _LevelState.completed).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: Stack(
        children: [
          // ── Wood Background ───────────────────────────────────────────────
          Positioned.fill(child: GameWidget(game: _bgGame)),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────────────────────────
                _Header(completedCount: _completedCount),

                const SizedBox(height: 8),

                // ── Progress bar ────────────────────────────────────────────
                _ProgressBar(
                    completed: _completedCount, total: _levels.length),

                const SizedBox(height: 12),

                // ── Legend row ──────────────────────────────────────────────
                const _LegendRow(),

                const SizedBox(height: 12),

                // ── Levels Grid ─────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: _levels.length,
                          itemBuilder: (context, index) {
                            return _LevelCard(
                              level: _levels[index],
                              glowValue: _glowAnimation.value,
                              onTap: _levels[index].state !=
                                      _LevelState.locked
                                  ? () => widget.controller
                                      .onLevelTapped(context, index)
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — warm cream panel
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int completedCount;
  const _Header({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8C898),
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFFD4A055), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF5D4037),
                size: 26,
              ),
            ),
          ),

          // Title
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SELECT LEVEL',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 1),
                          blurRadius: 2),
                    ],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Color Lab · Mix & Match',
                  style: TextStyle(
                    color: Color(0xFF8D6228),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Completion badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$completedCount/${_levels.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'DONE',
                  style: TextStyle(
                    color: Color(0xFFB9F6CA),
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
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
// Progress bar
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;
  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final double ratio = completed / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 8,
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
          const SizedBox(height: 4),
          Text(
            '${(ratio * 100).round()}% complete  ·  $completed of $total levels',
            style: TextStyle(
              color: const Color(0xFFF5DEB3).withValues(alpha: 0.75),
              fontSize: 10,
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
// Legend row
// ─────────────────────────────────────────────────────────────────────────────
class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(
            const Color(0xFF4CAF50), Icons.check_circle_rounded, 'Completed'),
        const SizedBox(width: 18),
        _legendItem(
            const Color(0xFFFFD700), Icons.play_circle_rounded, 'Playing'),
        const SizedBox(width: 18),
        _legendItem(
            const Color(0xFF8D6228), Icons.lock_rounded, 'Locked'),
      ],
    );
  }

  Widget _legendItem(Color color, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFF5DEB3).withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level Card
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _cardGradient(isCompleted, isPlaying, isLocked),
          border: Border.all(
            color: _borderColor(isCompleted, isPlaying, isLocked),
            width: isPlaying ? 2.5 : 1.5,
          ),
          boxShadow: _cardShadow(isCompleted, isPlaying, isLocked),
        ),
        child: Stack(
          children: [
            // ── Difficulty color bar (top) ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: _difficultyColor(level.difficulty)
                      .withValues(alpha: isLocked ? 0.3 : 0.85),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15)),
                ),
              ),
            ),

            // ── Main content ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CenterIcon(
                    level: level,
                    isCompleted: isCompleted,
                    isPlaying: isPlaying,
                    isLocked: isLocked,
                    glowValue: glowValue,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isLocked ? '???' : 'LVL ${level.number}',
                    style: TextStyle(
                      color: isLocked
                          ? const Color(0xFFF5DEB3).withValues(alpha: 0.3)
                          : isPlaying
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFF5DEB3),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    isLocked ? 'LOCKED' : level.difficulty.toUpperCase(),
                    style: TextStyle(
                      color: isLocked
                          ? const Color(0xFFF5DEB3).withValues(alpha: 0.2)
                          : _difficultyColor(level.difficulty)
                              .withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                      fontSize: 8.5,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // ── PLAYING ribbon ──────────────────────────────────────────
            if (isPlaying)
              Positioned(
                top: 7,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '▶',
                    style: TextStyle(
                      color: Color(0xFF3B1E08),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  LinearGradient _cardGradient(
      bool isCompleted, bool isPlaying, bool isLocked) {
    if (isCompleted) {
      return const LinearGradient(
        colors: [Color(0xFF4E342E), Color(0xFF3E2723)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (isPlaying) {
      return const LinearGradient(
        colors: [Color(0xFF5D3A1A), Color(0xFF3E2723)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return LinearGradient(
      colors: [
        const Color(0xFF3B1E08).withValues(alpha: 0.65),
        const Color(0xFF2C1600).withValues(alpha: 0.65),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color _borderColor(bool isCompleted, bool isPlaying, bool isLocked) {
    if (isCompleted) return const Color(0xFF4CAF50).withValues(alpha: 0.65);
    if (isPlaying) return const Color(0xFFFFD700).withValues(alpha: glowValue);
    return const Color(0xFFD4A055).withValues(alpha: 0.2);
  }

  List<BoxShadow> _cardShadow(
      bool isCompleted, bool isPlaying, bool isLocked) {
    if (isPlaying) {
      return [
        BoxShadow(
          color: const Color(0xFFFFD700).withValues(alpha: glowValue * 0.55),
          blurRadius: 16,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ];
    }
    if (isCompleted) {
      return [
        BoxShadow(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    }
    return [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.25),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':   return const Color(0xFF4CAF50);
      case 'Medium': return const Color(0xFFFFB300);
      case 'Hard':   return const Color(0xFFFF5722);
      case 'Expert': return const Color(0xFFF44336);
      default:       return const Color(0xFF4CAF50);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Center icon for each card state
// ─────────────────────────────────────────────────────────────────────────────
class _CenterIcon extends StatelessWidget {
  final _LevelData level;
  final bool isCompleted;
  final bool isPlaying;
  final bool isLocked;
  final double glowValue;

  const _CenterIcon({
    required this.level,
    required this.isCompleted,
    required this.isPlaying,
    required this.isLocked,
    required this.glowValue,
  });

  @override
  Widget build(BuildContext context) {
    // ── Locked ──────────────────────────────────────────────────────────────
    if (isLocked) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF3B1E08).withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD4A055).withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.lock_rounded,
          color: const Color(0xFFF5DEB3).withValues(alpha: 0.28),
          size: 18,
        ),
      );
    }

    // ── Completed ────────────────────────────────────────────────────────────
    if (isCompleted) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: level.targetColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4CAF50), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: level.targetColor.withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.65),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ),
        ],
      );
    }

    // ── Playing ──────────────────────────────────────────────────────────────
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: glowValue * 0.9),
            const Color(0xFFFF8F00).withValues(alpha: glowValue * 0.45),
          ],
          stops: const [0.35, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: glowValue),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: glowValue * 0.6),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: const Color(0xFF3B1E08).withValues(alpha: 0.9),
        size: 24,
      ),
    );
  }
}