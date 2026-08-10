import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../game/paint_background_game.dart';
import '../binding/statistic_screen_binding.dart';
import '../controller/statistic_screen_controller.dart';
import '../model/difficulty_stats_model.dart';

class StatisticScreen extends StatekitView<StatisticScreenController>
    implements StatisticScreenBinding {
  StatisticScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _StatisticScreenBody(controller: controller);
  }

  @override
  void selectFilter(DifficultyFilter filter) {
    controller.setFilter(filter);
  }
}

class _StatisticScreenBody extends StatefulWidget {
  final StatisticScreenController controller;
  const _StatisticScreenBody({required this.controller});

  @override
  State<_StatisticScreenBody> createState() => _StatisticScreenBodyState();
}

class _StatisticScreenBodyState extends State<_StatisticScreenBody> {
  late PaintBackgroundGame _bgGame;

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5E3C),
      body: StateBuilder<StatisticScreenController>(
        controller: widget.controller,
        builder: (context, ctrl, child) {
          final stats = ctrl.currentStats;
          final isAllFilter = ctrl.selectedFilter == DifficultyFilter.all;

          return Stack(
            children: [
              // ── Layer 1: Flame Warm Wood Background ─────────────────────
              Positioned.fill(child: GameWidget(game: _bgGame)),

              // ── Layer 2: Content Layout ─────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // ── Header Panel ──────────────────────────────────────
                    _Header(onBack: () => Navigator.pop(context)),

                    const SizedBox(height: 12),

                    // ── Difficulty Selector Tabs ──────────────────────────
                    _DifficultySelectorTabs(
                      selectedFilter: ctrl.selectedFilter,
                      onFilterSelected: (filter) => ctrl.setFilter(filter),
                    ),

                    const SizedBox(height: 12),

                    // ── Scrollable Body Content ───────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Card 1: Main Win Rate & Header Summary ──────
                            _OverviewHeaderCard(stats: stats),

                            const SizedBox(height: 16),

                            // ── Section Title: Key Metrics ────────────────
                            const _SectionTitle(
                              title: 'PERFORMANCE METRICS',
                              icon: Icons.analytics_rounded,
                            ),

                            const SizedBox(height: 10),

                            // ── Card 2: Key Metrics Grid ──────────────────
                            _MetricsGrid(stats: stats),

                            const SizedBox(height: 16),

                            // ── Section Title: Stars & Rating ─────────────
                            const _SectionTitle(
                              title: 'STAR RATINGS & ACCURACY',
                              icon: Icons.star_rounded,
                            ),

                            const SizedBox(height: 10),

                            // ── Card 3: Stars & Hints Breakdown ──────────
                            _StarsBreakdownCard(stats: stats),

                            if (isAllFilter) ...[
                              const SizedBox(height: 16),

                              // ── Section Title: Difficulty Comparison ──
                              const _SectionTitle(
                                title: 'DIFFICULTY TIER COMPARISON',
                                icon: Icons.leaderboard_rounded,
                              ),

                              const SizedBox(height: 10),

                              // ── Card 4: Difficulty Comparison Breakdown
                              _DifficultyComparisonList(controller: ctrl),
                            ],

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header Bar with Back Button
// ──────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          // 3D Back Button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5E3C), Color(0xFF5D4037)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFFFF1D6), size: 22),
            ),
          ),

          const SizedBox(width: 10),

          // Title Text
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PUZZLE STATISTICS',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 1.8,
                    shadows: [
                      Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Difficulty Breakdown & Performance',
                  style: TextStyle(
                    color: Color(0xFF8D6228),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          // Right Decorative Chart Badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A055),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B1E08).withValues(alpha: 0.25),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF3B1E08), size: 22),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Section Header Title
// ──────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 16),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFF1D6),
            fontWeight: FontWeight.w900,
            fontSize: 12.5,
            letterSpacing: 1.2,
            shadows: [
              Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 2),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Horizontal Difficulty Selector Tabs
// ──────────────────────────────────────────────────────────────────────────────
class _DifficultySelectorTabs extends StatelessWidget {
  final DifficultyFilter selectedFilter;
  final ValueChanged<DifficultyFilter> onFilterSelected;

  const _DifficultySelectorTabs({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: DifficultyFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          final color = filter.primaryColor;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [color, Color.lerp(color, Colors.black, 0.45)!],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF5D331A), Color(0xFF3D200E)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF8B5E3C),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 15,
                      color: isSelected ? Colors.white : const Color(0xFFD4A055),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter.displayName.toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFF5DEB3),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Overview Header Card (Win Rate & Overall Banner)
// ──────────────────────────────────────────────────────────────────────────────
class _OverviewHeaderCard extends StatelessWidget {
  final DifficultyStatsModel stats;
  const _OverviewHeaderCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final themeColor = stats.filter.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6E3B1C), Color(0xFF4A2510), Color(0xFF331707)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4A055), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241004).withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: themeColor.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: themeColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(stats.filter.icon, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${stats.filter.displayName.toUpperCase()} STATS',
                        style: const TextStyle(
                          color: Color(0xFFFFF1D6),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stats.filter.subtitle,
                    style: const TextStyle(
                      color: Color(0xFFD4A055),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              // Win Rate Circular/Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFD4A055)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFF1D6), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      stats.formattedWinRate,
                      style: const TextStyle(
                        color: Color(0xFF3B1E08),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'WIN RATE',
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.w900,
                        fontSize: 8.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Win / Loss Dual Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WINS: ${stats.totalWins}',
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'LOSSES: ${stats.totalLosses}',
                    style: const TextStyle(
                      color: Color(0xFFE57373),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 12,
                  color: const Color(0xFF3D1F0E),
                  child: Row(
                    children: [
                      if (stats.totalPlayed > 0) ...[
                        Expanded(
                          flex: (stats.winRatePercent * 10).round().clamp(1, 1000),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
                              ),
                            ),
                          ),
                        ),
                        if (stats.totalLosses > 0)
                          Expanded(
                            flex: ((100 - stats.winRatePercent) * 10).round().clamp(1, 1000),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFEF5350), Color(0xFFC62828)],
                                ),
                              ),
                            ),
                          ),
                      ] else
                        Expanded(
                          child: Container(color: const Color(0xFF532911)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Metrics Grid (2 or 3 Column Cards)
// ──────────────────────────────────────────────────────────────────────────────
class _MetricsGrid extends StatelessWidget {
  final DifficultyStatsModel stats;
  const _MetricsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Total Played, Total Wins, Perfect Plays
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.grid_view_rounded,
                badgeColor: const Color(0xFFFFD700),
                value: '${stats.totalPlayed}',
                label: 'TOTAL PLAYED',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.emoji_events_rounded,
                badgeColor: const Color(0xFFFFB703),
                value: '${stats.totalWins}',
                label: 'TOTAL WINS',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.auto_awesome_rounded,
                badgeColor: const Color(0xFF9D4EDD),
                value: '${stats.perfectPlays}',
                label: 'PERFECT PLAYS',
              ),
            ),
          ],
        ),

        const SizedBox(width: 8, height: 8),

        // Row 2: Best Streak, Current Streak, Best Time
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.local_fire_department_rounded,
                badgeColor: const Color(0xFFFF5722),
                value: '${stats.bestWinStreak}',
                label: 'BEST STREAK',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.bolt_rounded,
                badgeColor: const Color(0xFF29B6F6),
                value: '${stats.currentWinStreak}',
                label: 'CURRENT STREAK',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.timer_rounded,
                badgeColor: const Color(0xFF66BB6A),
                value: stats.formattedBestTime,
                label: 'BEST TIME',
              ),
            ),
          ],
        ),

        const SizedBox(width: 8, height: 8),

        // Row 3: Avg Time & Accuracy
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.hourglass_top_rounded,
                badgeColor: const Color(0xFFAB47BC),
                value: stats.formattedAvgTime,
                label: 'AVG TIME',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.gps_fixed_rounded,
                badgeColor: const Color(0xFF26A69A),
                value: '${stats.avgAccuracyPercent.toStringAsFixed(1)}%',
                label: 'ACCURACY',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color badgeColor;
  final String value;
  final String label;

  const _MetricTile({
    required this.icon,
    required this.badgeColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF381806)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241004).withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge Icon
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFF1D6), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF3B1E08), size: 16),
          ),

          const SizedBox(height: 6),

          // Numeric / Time Value
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFF1D6),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 0.4,
              shadows: [
                Shadow(color: Color(0x66000000), offset: Offset(0, 1.5), blurRadius: 3),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF5DEB3),
              fontWeight: FontWeight.w900,
              fontSize: 8.5,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Stars & Hints Breakdown Card
// ──────────────────────────────────────────────────────────────────────────────
class _StarsBreakdownCard extends StatelessWidget {
  final DifficultyStatsModel stats;
  const _StarsBreakdownCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF381806)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241004).withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total Stars Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 6),
                  const Text(
                    'TOTAL STARS EARNED',
                    style: TextStyle(
                      color: Color(0xFFFFF1D6),
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '★ ${stats.totalStars}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF8B5E3C), height: 1),
          const SizedBox(height: 12),

          // Star Ratings Distribution
          Row(
            children: [
              Expanded(
                child: _StarCountBadge(
                  starCount: 3,
                  wins: stats.threeStarWins,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StarCountBadge(
                  starCount: 2,
                  wins: stats.twoStarWins,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StarCountBadge(
                  starCount: 1,
                  wins: stats.oneStarWins,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hint Usage Info Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1E08).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF8B5E3C), width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB703), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Total Hints Used',
                      style: TextStyle(
                        color: Color(0xFFF5DEB3),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${stats.totalHintsUsed} Hints',
                  style: const TextStyle(
                    color: Color(0xFFFFF1D6),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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

class _StarCountBadge extends StatelessWidget {
  final int starCount;
  final int wins;

  const _StarCountBadge({required this.starCount, required this.wins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF3D200E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4A055).withValues(alpha: 0.6), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              starCount,
              (index) => const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 12),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$wins Wins',
            style: const TextStyle(
              color: Color(0xFFFFF1D6),
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Difficulty Comparison Breakdown (Visible when "ALL" tab is selected)
// ──────────────────────────────────────────────────────────────────────────────
class _DifficultyComparisonList extends StatelessWidget {
  final StatisticScreenController controller;
  const _DifficultyComparisonList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = DifficultyFilter.values.where((f) => f != DifficultyFilter.all).toList();

    return Column(
      children: filters.map((filter) {
        final stats = controller.getStatsFor(filter);
        final color = filter.primaryColor;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6E3B1C), Color(0xFF4A2510)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4A055), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(filter.icon, color: Colors.white, size: 16),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filter.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFFFFF1D6),
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          filter.subtitle,
                          style: const TextStyle(
                            color: Color(0xFFD4A055),
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        stats.formattedWinRate,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${stats.totalWins}/${stats.totalPlayed} Wins',
                        style: const TextStyle(
                          color: Color(0xFFF5DEB3),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Mini Win Rate Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 6,
                  color: const Color(0xFF3D1F0E),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (stats.winRatePercent * 10).round().clamp(1, 1000),
                        child: Container(color: color),
                      ),
                      if (stats.totalLosses > 0)
                        Expanded(
                          flex: ((100 - stats.winRatePercent) * 10).round().clamp(1, 1000),
                          child: Container(color: const Color(0xFF3D1F0E)),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Bottom Stats Row: Best Time & Perfect Plays
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Best Time: ${stats.formattedBestTime}',
                    style: const TextStyle(
                      color: Color(0xFFF5DEB3),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Perfect Plays: ${stats.perfectPlays}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}