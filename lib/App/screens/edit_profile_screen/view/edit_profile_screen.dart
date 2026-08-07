import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import '../../../core/models/country_model.dart';
import '../../../game/paint_background_game.dart';
import '../binding/edit_profile_screen_binding.dart';
import '../controller/edit_profile_screen_controller.dart';

class EditProfileScreen extends StatekitView<EditProfileScreenController>
    implements EditProfileScreenBinding {
  EditProfileScreen({super.key, super.tag});

  @override
  Widget build(BuildContext context) {
    return _EditProfileScreenBody(controller: controller);
  }

  @override
  void selectCountry(Country country) => controller.selectCountry(country);

  @override
  void saveProfile(BuildContext context) => controller.saveProfile(context);
}

class _EditProfileScreenBody extends StatefulWidget {
  final EditProfileScreenController controller;
  const _EditProfileScreenBody({required this.controller});

  @override
  State<_EditProfileScreenBody> createState() => _EditProfileScreenBodyState();
}

class _EditProfileScreenBodyState extends State<_EditProfileScreenBody> {
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
      body: StateBuilder<EditProfileScreenController>(
        controller: widget.controller,
        builder: (context, ctrl, child) {
          return Stack(
            children: [
              // ── Layer 1: Flame Warm Wood Background ─────────────────────
              Positioned.fill(child: GameWidget(game: _bgGame)),

              // ── Layer 2: Content Layout ─────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // ── Top Header Bar ────────────────────────────────────
                    _Header(onBack: () => Navigator.pop(context)),

                    const SizedBox(height: 12),

                    // ── Scrollable Form Body ──────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Card 1: Avatar Selection Card ───────────────
                            _AvatarSelectionCard(controller: ctrl),

                            const SizedBox(height: 16),

                            // ── Card 2: Player Info Form Card ─────────────
                            _ProfileFormCard(
                              controller: ctrl,
                              onOpenCountryPicker: () =>
                                  _showCountrySearchBottomSheet(context, ctrl),
                            ),

                            const SizedBox(height: 24),

                            // ── 3D Save Button ────────────────────────────
                            _SaveButton(onPressed: () => ctrl.saveProfile(context)),

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

  // ────────────────────────────────────────────────────────────────────────────
  // Country Picker Searchable Bottom Sheet
  // ────────────────────────────────────────────────────────────────────────────
  void _showCountrySearchBottomSheet(BuildContext context, EditProfileScreenController ctrl) {
    ctrl.clearSearch();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF532911), Color(0xFF381806)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: const Border(top: BorderSide(color: Color(0xFFFFD700), width: 2.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Drag handle indicator
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A055).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title Header
                  const Text(
                    'SELECT YOUR COUNTRY',
                    style: TextStyle(
                      color: Color(0xFFFFF1D6),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(color: Color(0x66000000), offset: Offset(0, 1), blurRadius: 3),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Search Field Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF241004),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: ctrl.searchController,
                        style: const TextStyle(
                          color: Color(0xFFFFF1D6),
                          fontWeight: FontWeight.w700,
                        ),
                        cursorColor: const Color(0xFFFFD700),
                        onChanged: (query) {
                          ctrl.updateSearchQuery(query);
                          setBottomSheetState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by country name or code...',
                          hintStyle: TextStyle(
                            color: const Color(0xFFF5DEB3).withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5,
                          ),
                          icon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFFFFD700),
                            size: 22,
                          ),
                          border: InputBorder.none,
                          suffixIcon: ctrl.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFFD4A055),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    ctrl.clearSearch();
                                    setBottomSheetState(() {});
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Divider(color: const Color(0xFFD4A055).withValues(alpha: 0.3), height: 1),

                  // Filtered Countries List
                  Expanded(
                    child: ctrl.filteredCountries.isEmpty
                        ? const Center(
                            child: Text(
                              'No country matches search',
                              style: TextStyle(
                                color: Color(0xFFF5DEB3),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: ctrl.filteredCountries.length,
                            separatorBuilder: (context, index) => Divider(
                              color: const Color(0xFFD4A055).withValues(alpha: 0.15),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final country = ctrl.filteredCountries[index];
                              final bool isSelected = ctrl.selectedCountry.code == country.code;

                              return InkWell(
                                onTap: () {
                                  ctrl.selectCountry(country);
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(country.flag, style: const TextStyle(fontSize: 24)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          country.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFFFFD700)
                                                : const Color(0xFFFFF1D6),
                                            fontWeight: isSelected
                                                ? FontWeight.w900
                                                : FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        country.code,
                                        style: TextStyle(
                                          color: const Color(0xFFD4A055).withValues(alpha: 0.85),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFFFFD700),
                                          size: 20,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Header Panel — Matches Settings Header
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
            behavior: HitTestBehavior.opaque,
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
                  'EDIT PROFILE',
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
                  'Customize Avatar, Name & Country',
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

          // Decorative badge
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
            child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFF3B1E08), size: 20),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Card 1: Avatar Selection Card (32 Avatar Options)
// ──────────────────────────────────────────────────────────────────────────────
class _AvatarSelectionCard extends StatelessWidget {
  final EditProfileScreenController controller;
  const _AvatarSelectionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _ThemeCardContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _CardHeader(icon: Icons.face_rounded, title: 'SELECT AVATAR'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF5D4037).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4A055).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${EditProfileScreenController.avatarEmojis.length} AVATARS',
                  style: const TextStyle(
                    color: Color(0xFF8D6228),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Large Active Avatar Display Frame (Hero Animation Target)
          Hero(
            tag: 'profile_avatar_hero',
            child: Material(
              type: MaterialType.transparency,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFD4A055), Color(0xFF5D4037)],
                        stops: [0.6, 0.85, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFF3B1E08).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFF1D6), width: 2.5),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5D4037), Color(0xFF3B1E08)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFF5DEB3), Color(0xFFD4A055)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: controller.currentAvatarEmoji == "👤"
                              ? const Icon(Icons.person_rounded, size: 52, color: Color(0xFF5D4037))
                              : Text(
                                  controller.currentAvatarEmoji,
                                  style: const TextStyle(fontSize: 42),
                                ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF3B1E08), width: 1.5),
                      ),
                      child: const Icon(Icons.check_rounded, size: 14, color: Color(0xFF3B1E08)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2-Row Horizontal Scrollable Grid of 32 Avatar Options
          SizedBox(
            height: 114,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: EditProfileScreenController.avatarEmojis.length,
              itemBuilder: (context, index) {
                final emoji = EditProfileScreenController.avatarEmojis[index];
                final bool isSelected = controller.selectedAvatarIndex == index;

                return GestureDetector(
                  onTap: () => controller.selectAvatar(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFFFF1D6)
                          : const Color(0xFF5D4037).withValues(alpha: 0.1),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFD700)
                            : const Color(0xFFD4A055).withValues(alpha: 0.4),
                        width: isSelected ? 2.5 : 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: emoji == "👤"
                          ? Icon(
                              Icons.person_rounded,
                              size: 26,
                              color: isSelected ? const Color(0xFF5D4037) : const Color(0xFF8D6228),
                            )
                          : Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Card 2: Profile Form Card (Name + Country)
// ──────────────────────────────────────────────────────────────────────────────
class _ProfileFormCard extends StatelessWidget {
  final EditProfileScreenController controller;
  final VoidCallback onOpenCountryPicker;

  const _ProfileFormCard({required this.controller, required this.onOpenCountryPicker});

  @override
  Widget build(BuildContext context) {
    return _ThemeCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1 Title: Player Name
          const _CardHeader(icon: Icons.person_outline_rounded, title: 'PLAYER NAME'),
          const SizedBox(height: 10),

          // Name Input Box — Clean Cream Inset Matching Settings
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1D6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B1E08).withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.nameController,
              style: const TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
              cursorColor: const Color(0xFF8D6228),
              decoration: InputDecoration(
                hintText: 'Enter player name...',
                hintStyle: TextStyle(
                  color: const Color(0xFF8D6228).withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                icon: const Icon(Icons.badge_rounded, color: Color(0xFF8D6228), size: 22),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Section 2 Title: Country / Region
          const _CardHeader(icon: Icons.public_rounded, title: 'COUNTRY / REGION'),
          const SizedBox(height: 10),

          // Country Selector Box — Clean Cream Inset Button
          GestureDetector(
            onTap: onOpenCountryPicker,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1D6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4A055), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B1E08).withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(controller.selectedCountry.flag, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedCountry.name,
                          style: const TextStyle(
                            color: Color(0xFF5D4037),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ISO Code: ${controller.selectedCountry.code}',
                          style: TextStyle(
                            color: const Color(0xFF8D6228).withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A055),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.0),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF3B1E08),
                      size: 20,
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
// 3D Unity Wooden Slice Save Button — Matches Game Play & Action Buttons
// ──────────────────────────────────────────────────────────────────────────────
class _SaveButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7A4522), // Carved wood top highlight
                Color(0xFF582D13), // Mid oak plank
                Color(0xFF3C1B08), // Dark bottom bevel
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.9), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0xFF1E0B02).withValues(alpha: 0.6),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left Stud Rivet
              _buildRivet(),
              const SizedBox(width: 12),

              // Button Label Text
              const Expanded(
                child: Text(
                  'SAVE CHANGES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFF1D6),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                    shadows: [
                      Shadow(color: Color(0xFF1E0B02), offset: Offset(0, 2), blurRadius: 4),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),
              // Right Stud Rivet
              _buildRivet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRivet() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB87333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF381806), width: 0.8),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared Theme Card Container & Card Header — Identical to SettingsScreen
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
