import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import '../../home_page/view/home_page.dart';
import '../../level_selection_page/view/level_selection_page.dart';
import '../../profile_page/view/profile_page.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

import 'package:flame/game.dart';
import '../../../game/paint_background_game.dart';

class HomeScreen extends StatekitView<HomeScreenController> implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _HomeScreenShell(controller: controller);
  }

  @override
  void doSomething() {}
}

class _HomeScreenShell extends StatefulWidget {
  final HomeScreenController controller;
  const _HomeScreenShell({required this.controller});

  @override
  State<_HomeScreenShell> createState() => _HomeScreenShellState();
}

class _HomeScreenShellState extends State<_HomeScreenShell> {
  late PaintBackgroundGame _bgGame;

  @override
  void initState() {
    super.initState();
    _bgGame = PaintBackgroundGame();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<HomeScreenController>(
      controller: widget.controller,
      builder: (context, ctrl, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF8B5E3C),
          body: Stack(
            children: [
              // Single global background game animation
              Positioned.fill(child: GameWidget(game: _bgGame)),

              // Foreground tab content + bottom navigation
              Column(
                children: [
                  Expanded(child: _AnimatedTabBody(ctrl: ctrl)),
                  _WoodenBottomNavigationBar(
                    currentIndex: ctrl.currentTabIndex,
                    onTap: (index) => ctrl.changeTab(index),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Smooth Animated Page View Wrapper for Tab Switching
// ──────────────────────────────────────────────────────────────────────────────
class _AnimatedTabBody extends StatefulWidget {
  final HomeScreenController ctrl;
  const _AnimatedTabBody({required this.ctrl});

  @override
  State<_AnimatedTabBody> createState() => _AnimatedTabBodyState();
}

class _AnimatedTabBodyState extends State<_AnimatedTabBody> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.ctrl.currentTabIndex);
  }

  @override
  void didUpdateWidget(covariant _AnimatedTabBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pageController.hasClients &&
        _pageController.page?.round() != widget.ctrl.currentTabIndex) {
      _pageController.animateToPage(
        widget.ctrl.currentTabIndex,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [HomePage(), LevelSelectionPage(), ProfilePage()],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 3D Wooden Bottom Navigation Bar (PLAY, LEVELS, PROFILE)
// ──────────────────────────────────────────────────────────────────────────────
class _WoodenBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _WoodenBottomNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SafeArea(
        top: false,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF5D3A1A), // Warm oak top
                Color(0xFF42240E), // Mid chocolate
                Color(0xFF2C1307), // Dark mahogany base
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFD4A055).withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A0903).withValues(alpha: 0.65),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFFF5DEB3).withValues(alpha: 0.12),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(index: 0, icon: Icons.sports_esports_rounded, label: 'PLAY'),
              ),
              Expanded(
                child: _buildNavItem(index: 1, icon: Icons.grid_view_rounded, label: 'LEVELS'),
              ),
              Expanded(
                child: _buildNavItem(index: 2, icon: Icons.person_rounded, label: 'PROFILE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFF5DEB3), Color(0xFFD4A055)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: const Color(0xFFFFE082), width: 1.5) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: isSelected ? 20 : 18,
                  color: isSelected
                      ? const Color(0xFF3B1E08)
                      : const Color(0xFFF5DEB3).withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF3B1E08)
                        : const Color(0xFFF5DEB3).withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
