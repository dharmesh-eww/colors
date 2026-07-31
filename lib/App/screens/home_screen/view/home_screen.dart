import 'package:statekit/statekit.dart';
import 'package:flutter/material.dart';
import '../../home_page/view/home_page.dart';
import '../../level_selection_page/view/level_selection_page.dart';
import '../../profile_page/view/profile_page.dart';
import '../binding/home_screen_binding.dart';
import '../controller/home_screen_controller.dart';

class HomeScreen extends StatekitView<HomeScreenController> implements HomeScreenBinding {
  HomeScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return StateBuilder<HomeScreenController>(
      controller: controller,
      builder: (context, ctrl, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF8B5E3C),
          body: switch (ctrl.currentTabIndex) {
            0 => HomePage(),
            1 => LevelSelectionPage(),
            2 => ProfilePage(),
            _ => SizedBox(),
          },
          bottomNavigationBar: _WoodenBottomNavigationBar(
            currentIndex: ctrl.currentTabIndex,
            onTap: (index) => ctrl.changeTab(index),
          ),
        );
      },
    );
  }

  @override
  void doSomething() {}
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
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6E3B1C), // Deep chocolate top
            Color(0xFF532911), // Mid warm oak
            Color(0xFF381806), // Dark wood base
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(top: BorderSide(color: Color(0xFFFFD700), width: 2.0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241004).withValues(alpha: 0.7),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(index: 0, icon: Icons.sports_esports_rounded, label: 'PLAY'),
          _buildNavItem(index: 1, icon: Icons.grid_view_rounded, label: 'LEVELS'),
          _buildNavItem(index: 2, icon: Icons.person_rounded, label: 'PROFILE'),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFF3B1E08)
                  : const Color(0xFFF5DEB3).withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF3B1E08)
                    : const Color(0xFFF5DEB3).withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
