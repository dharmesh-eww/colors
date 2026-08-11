import 'package:colors/App/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../binding/profile_page_binding.dart';
import '../controller/profile_page_controller.dart';

class ProfilePage extends StatekitView<ProfilePageController> implements ProfilePageBinding {
  ProfilePage({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _ProfilePageBody(controller: controller);
  }

  @override
  void signInWithGoogle() => controller.signInWithGoogle();

  @override
  void signOut() => controller.signOut();
}

class _ProfilePageBody extends StatefulWidget {
  final ProfilePageController controller;
  const _ProfilePageBody({required this.controller});

  @override
  State<_ProfilePageBody> createState() => _ProfilePageBodyState();
}

class _ProfilePageBodyState extends State<_ProfilePageBody> {
  @override
  Widget build(BuildContext context) {
    return StateBuilder<ProfilePageController>(
      controller: widget.controller,
      builder: (context, ctrl, child) {
        return SafeArea(
          child: Column(
            children: [
              // ── Header Panel ──────────────────────────────────────
              const _Header(),

              const SizedBox(height: 16),

              // ── Scrollable Body Content ───────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Card 1: Main Player Profile Card (Avatar + Name + Google Sign-In) ─────
                      _ProfileHeaderCard(ctrl: ctrl),

                      const SizedBox(height: 16),

                      // ── Card 2: Game Stats & Achievements (Levels + Stars + Puzzles) ──
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, Routes.statisticScreen),
                        child: _PlayerStatsCard(ctrl: ctrl),
                      ),

                      const SizedBox(height: 12),

                      // ── Button: View Detailed Statistics ──────────────
                      _ViewDetailedStatsButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.statisticScreen),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header — Matches Game Theme
// ──────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          // Left Icon Badge
          Container(
            width: 38,
            height: 38,
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
            child: const Icon(Icons.person_rounded, color: Color(0xFF5D4037), size: 24),
          ),

          // Title
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PLAYER PROFILE',
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 2.2,
                    shadows: [
                      Shadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Color Craft Account & Progress',
                  style: TextStyle(
                    color: Color(0xFF8D6228),
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Crown decorative badge
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
            child: const Icon(Icons.military_tech_rounded, color: Color(0xFF3B1E08), size: 22),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Main Profile Card (Avatar + Name + Integrated Google Sign-In Button)
// ──────────────────────────────────────────────────────────────────────────────

class _ProfileHeaderCard extends StatelessWidget {
  final ProfilePageController ctrl;
  const _ProfileHeaderCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          // ── Profile Avatar Frame (Clicking redirects to Edit Profile with Hero animation)
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.editProfileScreen),
            behavior: HitTestBehavior.opaque,
            child: Hero(
              tag: 'profile_avatar_hero',
              child: Material(
                type: MaterialType.transparency,
                child: Stack(
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFD4A055), Color(0xFF5D4037)],
                          stops: [0.6, 0.85, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: const Color(0xFF241004).withValues(alpha: 0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 98,
                          height: 98,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFF1D6), width: 2.5),
                            gradient: LinearGradient(
                              colors: ctrl.isSignedIn
                                  ? [const Color(0xFFD4A055), const Color(0xFF5D4037)]
                                  : [const Color(0xFF5D4037), const Color(0xFF3B1E08)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: ctrl.isSignedIn
                                ? const CircleAvatar(
                                    radius: 44,
                                    backgroundColor: Color(0xFF5D4037),
                                    child: Text(
                                      'AR',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 32,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 84,
                                    height: 84,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFFF5DEB3), Color(0xFFD4A055)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Center(
                                      child: ctrl.currentAvatarEmoji == "👤"
                                          ? const Icon(
                                              Icons.person_rounded,
                                              size: 58,
                                              color: Color(0xFF5D4037),
                                            )
                                          : Text(
                                              ctrl.currentAvatarEmoji,
                                              style: const TextStyle(fontSize: 44),
                                            ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Edit Badge Icon
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF3B1E08), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF241004).withValues(alpha: 0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFF3B1E08)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── User Name (Clicking redirects to Edit Profile) ─────────────────
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.editProfileScreen),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctrl.userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF5DEB3),
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 1.0,
                    shadows: [
                      Shadow(color: Color(0xFF241004), offset: Offset(0, 3), blurRadius: 8),
                      Shadow(color: Color(0xFFFFD700), offset: Offset(0, -1), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit_square, size: 18, color: Color(0xFFFFD700)),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Selected Country Badge ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1E08).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4A055).withValues(alpha: 0.6), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ctrl.userCountry.flag, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  ctrl.userCountry.name,
                  style: const TextStyle(
                    color: Color(0xFFF5DEB3),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Integrated Google Sign-In Button ──────────────────────────────
          _Google3DButton(
            isSignedIn: ctrl.isSignedIn,
            isLoading: ctrl.isLoading,
            onPressed: ctrl.isSignedIn ? null : () => ctrl.signInWithGoogle(),
          ),

          if (ctrl.isSignedIn) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: ctrl.isLoading ? null : () => ctrl.signOut(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.logout_rounded, size: 15, color: Color(0xFFF5DEB3)),
                    const SizedBox(width: 5),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: const Color(0xFFF5DEB3).withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFFF5DEB3).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 3D Game Style Google Sign-In Button (Compact size, Uses assets/images/google.png)
// ──────────────────────────────────────────────────────────────────────────────
class _Google3DButton extends StatefulWidget {
  final bool isSignedIn;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _Google3DButton({required this.isSignedIn, required this.isLoading, this.onPressed});

  @override
  State<_Google3DButton> createState() => _Google3DButtonState();
}

class _Google3DButtonState extends State<_Google3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 3 : 0, bottom: _isPressed ? 0 : 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: widget.isSignedIn
              ? const LinearGradient(
                  colors: [Color(0xFFFFF5DF), Color(0xFFE8C898)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFF5EBE1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.0, color: Color(0xFF5D4037)),
              )
            else
              // ── Downloaded Google Image Asset ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Image.asset('assets/images/google.png', width: 18, height: 18),
              ),

            const SizedBox(width: 8),

            // Button Label
            Text(
              widget.isLoading
                  ? 'Connecting...'
                  : (widget.isSignedIn ? 'Signed in with Google' : 'Sign in with Google'),
              style: const TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
                letterSpacing: 0.3,
              ),
            ),

            if (widget.isSignedIn && !widget.isLoading) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle_rounded, color: Color(0xFFD4A055), size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Player Statistics Row (Identical wood theme styling for all cards)
// ──────────────────────────────────────────────────────────────────────────────
class _PlayerStatsCard extends StatelessWidget {
  final ProfilePageController ctrl;
  const _PlayerStatsCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Card 1: Levels Cleared ───────────────────────────────────────────
        Expanded(
          child: _StatCardTile(
            gradientColors: const [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF381806)],
            borderColor: const Color(0xFFD4A055),
            badgeColor: const Color(0xFFFFD700),
            icon: Icons.grid_view_rounded,
            iconColor: const Color(0xFF3B1E08),
            value: '${ctrl.levelsCompleted}',
            valueColor: const Color(0xFFFFF1D6),
            label: 'LEVELS CLEARED',
            labelColor: const Color(0xFFF5DEB3),
            glowColor: const Color(0xFFD4A055).withValues(alpha: 0.25),
          ),
        ),

        const SizedBox(width: 8),

        // ── Card 2: Stars Earned ─────────────────────────────────────────────
        Expanded(
          child: _StatCardTile(
            gradientColors: const [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF381806)],
            borderColor: const Color(0xFFD4A055),
            badgeColor: const Color(0xFFFFD700),
            icon: Icons.star_rounded,
            iconColor: const Color(0xFF3B1E08),
            value: '${ctrl.starsEarned}',
            valueColor: const Color(0xFFFFF1D6),
            label: 'STARS EARNED',
            labelColor: const Color(0xFFF5DEB3),
            glowColor: const Color(0xFFD4A055).withValues(alpha: 0.25),
          ),
        ),

        const SizedBox(width: 8),

        // ── Card 3: Total Puzzles Played ──────────────────────────────────────
        Expanded(
          child: _StatCardTile(
            gradientColors: const [Color(0xFF6E3B1C), Color(0xFF532911), Color(0xFF381806)],
            borderColor: const Color(0xFFD4A055),
            badgeColor: const Color(0xFFFFD700),
            icon: Icons.extension_rounded,
            iconColor: const Color(0xFF3B1E08),
            value: '${ctrl.totalPuzzlesPlayed}',
            valueColor: const Color(0xFFFFF1D6),
            label: 'PUZZLES PLAYED',
            labelColor: const Color(0xFFF5DEB3),
            glowColor: const Color(0xFFD4A055).withValues(alpha: 0.25),
          ),
        ),
      ],
    );
  }
}

class _StatCardTile extends StatelessWidget {
  final List<Color> gradientColors;
  final Color borderColor;
  final Color badgeColor;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Color valueColor;
  final String label;
  final Color labelColor;
  final Color glowColor;

  const _StatCardTile({
    required this.gradientColors,
    required this.borderColor,
    required this.badgeColor,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.valueColor,
    required this.label,
    required this.labelColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF241004).withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(color: glowColor, blurRadius: 6, offset: const Offset(0, -1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D Circular Badge Icon
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
            child: Icon(icon, color: iconColor, size: 17),
          ),

          const SizedBox(height: 6),

          // Numeric Value
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(color: Color(0x66000000), offset: Offset(0, 1.5), blurRadius: 3),
              ],
            ),
          ),

          const SizedBox(height: 2),

          // Stat Label Text
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
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

class _ViewDetailedStatsButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ViewDetailedStatsButton({required this.onPressed});

  @override
  State<_ViewDetailedStatsButton> createState() => _ViewDetailedStatsButtonState();
}

class _ViewDetailedStatsButtonState extends State<_ViewDetailedStatsButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 3 : 0, bottom: _isPressed ? 0 : 3),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4A055), width: 1.8),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights_rounded, color: Color(0xFF5D4037), size: 18),
            SizedBox(width: 8),
            Text(
              'VIEW DETAILED STATISTICS',
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: Color(0xFFD4A055), size: 18),
          ],
        ),
      ),
    );
  }
}
