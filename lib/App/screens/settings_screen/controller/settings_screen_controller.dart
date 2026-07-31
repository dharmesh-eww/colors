import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../binding/settings_screen_binding.dart';
import '../repository/settings_screen_repository.dart';

class SettingsScreenController extends StateController<SettingsScreenBinding> {
  final SettingsScreenRepository _repository = SettingsScreenRepository();

  bool soundEnabled = true;
  double soundVolume = 0.8;
  bool isLoading = true;
  final String gameVersion = '1.0.0';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    isLoading = true;
    update();
    soundEnabled = await _repository.loadSoundEnabled();
    soundVolume = await _repository.loadSoundVolume();
    isLoading = false;
    update();
  }

  void toggleSound(bool value) async {
    soundEnabled = value;
    update();
    await _repository.saveSoundEnabled(value);
  }

  void updateVolume(double value) async {
    soundVolume = value.clamp(0.0, 1.0);
    update();
    await _repository.saveSoundVolume(soundVolume);
  }

  void resetGameProgress(BuildContext context) async {
    await _repository.resetProgress();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Game level progress has been reset!',
            style: TextStyle(color: Color(0xFFF5DEB3), fontWeight: FontWeight.w700),
          ),
          backgroundColor: const Color(0xFF3B1E08),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFD4A055), width: 1.5),
          ),
        ),
      );
    }
  }
}