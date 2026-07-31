import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../game/paint_background_game.dart';
import '../binding/settings_screen_binding.dart';
import '../controller/settings_screen_controller.dart';

class SettingsScreen extends StatekitView<SettingsScreenController> implements SettingsScreenBinding {
  SettingsScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _SettingsScreenBody(controller: controller);
  }

  @override
  void toggleSound(bool value) => controller.toggleSound(value);

  @override
  void updateVolume(double value) => controller.updateVolume(value);

  @override
  void resetGameProgress(BuildContext context) => controller.resetGameProgress(context);
}

class _SettingsScreenBody extends StatefulWidget {
  final SettingsScreenController controller;
  const _SettingsScreenBody({required this.controller});

  @override
  State<_SettingsScreenBody> createState() => _SettingsScreenBodyState();
}

class _SettingsScreenBodyState extends State<_SettingsScreenBody> {
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
      body: StateBuilder<SettingsScreenController>(
        controller: widget.controller,
        builder: (context, ctrl, child) {
          return Stack(
            children: [
              // ── Layer 1: Flame Warm Wood Background ─────────────────────
              Positioned.fill(child: GameWidget(game: _bgGame)),

              // ── Layer 2: UI Content ─────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // ── Top Header ─────────────────────────────────────────
                    _Header(onBack: () => Navigator.pop(context)),

                    const SizedBox(height: 12),

                    // ── Scrollable Settings List ───────────────────────────
                    Expanded(
                      child: ctrl.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                            )
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ── Card 1: Audio & Sound Settings ─────
                                  _SoundSettingsCard(
                                    soundEnabled: ctrl.soundEnabled,
                                    soundVolume: ctrl.soundVolume,
                                    onToggleSound: (val) => ctrl.toggleSound(val),
                                    onVolumeChanged: (val) => ctrl.updateVolume(val),
                                  ),

                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                    ),

                    // ── Screen Bottom: Game Version Display (1.0.0) ───────
                    _GameVersionFooter(version: ctrl.gameVersion),
                    const SizedBox(height: 8),
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
// Header — Matches Game Theme
// ──────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            onTap: onBack,
            child: Container(
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
              child: const Icon(Icons.chevron_left_rounded, color: Color(0xFF5D4037), size: 28),
            ),
          ),

          // Title
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SETTINGS',
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
                  'Color Craft Preferences',
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

          // Tune gear decorative badge
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
            child: const Icon(Icons.tune_rounded, color: Color(0xFF3B1E08), size: 22),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Card 1: Sound Settings Card
// ──────────────────────────────────────────────────────────────────────────────
class _SoundSettingsCard extends StatelessWidget {
  final bool soundEnabled;
  final double soundVolume;
  final ValueChanged<bool> onToggleSound;
  final ValueChanged<double> onVolumeChanged;

  const _SoundSettingsCard({
    required this.soundEnabled,
    required this.soundVolume,
    required this.onToggleSound,
    required this.onVolumeChanged,
  });

  IconData get _volumeIcon {
    if (!soundEnabled || soundVolume == 0.0) {
      return Icons.volume_off_rounded;
    } else if (soundVolume < 0.5) {
      return Icons.volume_down_rounded;
    } else {
      return Icons.volume_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int volumePercentage = (soundVolume * 100).round();

    return _ThemeCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Header
          _CardHeader(
            icon: Icons.graphic_eq_rounded,
            title: 'AUDIO & SOUND',
          ),
          const SizedBox(height: 14),

          // Row 1: Sound Enable / Disable Switch
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D4037).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4A055).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  color: soundEnabled ? const Color(0xFF5D4037) : const Color(0xFF8D6228),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sound Effects',
                      style: TextStyle(
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      soundEnabled ? 'Audio and game sound active' : 'All audio muted',
                      style: TextStyle(
                        color: const Color(0xFF8D6228).withValues(alpha: 0.9),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Switch
              Transform.scale(
                scale: 0.95,
                child: Switch.adaptive(
                  value: soundEnabled,
                  onChanged: onToggleSound,
                  activeThumbColor: const Color(0xFFFFD700),
                  activeTrackColor: const Color(0xFF5D4037),
                  inactiveThumbColor: const Color(0xFF8D6228),
                  inactiveTrackColor: const Color(0xFF3B1E08).withValues(alpha: 0.3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: const Color(0xFFD4A055).withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 16),

          // Row 2: Volume Slider
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: soundEnabled ? 1.0 : 0.45,
            child: IgnorePointer(
              ignoring: !soundEnabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _volumeIcon,
                            size: 20,
                            color: const Color(0xFF5D4037),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Sound Volume',
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      // Percentage Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B1E08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4A055), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B1E08).withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$volumePercentage%',
                          style: TextStyle(
                            color: soundEnabled ? const Color(0xFFFFD700) : Colors.white54,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 7.0,
                      activeTrackColor: const Color(0xFF5D4037),
                      inactiveTrackColor: const Color(0xFF8D6228).withValues(alpha: 0.25),
                      thumbColor: const Color(0xFFFFD700),
                      overlayColor: const Color(0xFFFFD700).withValues(alpha: 0.2),
                      thumbShape: const _CustomGoldSliderThumbShape(enabled: true),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: soundVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: soundEnabled ? onVolumeChanged : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom Game Version Footer Badge (1.0.0)
// ──────────────────────────────────────────────────────────────────────────────
class _GameVersionFooter extends StatelessWidget {
  final String version;
  const _GameVersionFooter({required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B1E08).withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videogame_asset_outlined, size: 14, color: Color(0xFFFFD700)),
          const SizedBox(width: 6),
          Text(
            'Version $version',
            style: const TextStyle(
              color: Color(0xFFF5DEB3),
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.0,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared Theme Card Container
// ──────────────────────────────────────────────────────────────────────────────
class _ThemeCardContainer extends StatelessWidget {
  final Widget child;
  const _ThemeCardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5DEB3), Color(0xFFE8C898)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD4A055), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B1E08).withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF5D4037)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// Custom 3D Gold Thumb Shape for Slider
class _CustomGoldSliderThumbShape extends SliderComponentShape {
  final bool enabled;
  const _CustomGoldSliderThumbShape({required this.enabled});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(22, 22);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Outer shadow
    canvas.drawCircle(
      center + const Offset(0, 2),
      11,
      Paint()
        ..color = const Color(0xFF3B1E08).withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Golden brass circle
    final thumbPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF5DF), Color(0xFFFFD700), Color(0xFFD4A055)],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 11));

    canvas.drawCircle(center, 11, thumbPaint);

    // Border
    canvas.drawCircle(
      center,
      11,
      Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }
}