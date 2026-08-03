import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../enums/bottle_interaction_mode.dart';

/// Service for persisting app and sound settings.
class SettingsStorageService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _soundVolumeKey = 'sound_volume';
  static const String _bottleInteractionModeKey = 'bottle_interaction_mode';

  final FlutterSecureStorage _storage;

  SettingsStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Retrieves whether sound is enabled (default: true).
  Future<bool> isSoundEnabled() async {
    try {
      final String? value = await _storage.read(key: _soundEnabledKey);
      if (value != null) {
        return value.toLowerCase() == 'true';
      }
    } catch (_) {}
    return true;
  }

  /// Saves the sound enabled state.
  Future<void> setSoundEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _soundEnabledKey,
        value: enabled.toString(),
      );
    } catch (_) {}
  }

  /// Retrieves the sound volume from 0.0 to 1.0 (default: 0.8).
  Future<double> getSoundVolume() async {
    try {
      final String? value = await _storage.read(key: _soundVolumeKey);
      if (value != null) {
        final double? parsed = double.tryParse(value);
        if (parsed != null) {
          return parsed.clamp(0.0, 1.0);
        }
      }
    } catch (_) {}
    return 0.8;
  }

  /// Saves the sound volume level (0.0 to 1.0).
  Future<void> setSoundVolume(double volume) async {
    try {
      await _storage.write(
        key: _soundVolumeKey,
        value: volume.clamp(0.0, 1.0).toString(),
      );
    } catch (_) {}
  }

  /// Retrieves the bottle interaction mode (default: BottleInteractionMode.drag).
  Future<BottleInteractionMode> getBottleInteractionMode() async {
    try {
      final String? value = await _storage.read(key: _bottleInteractionModeKey);
      if (value != null) {
        return BottleInteractionMode.values.firstWhere(
          (mode) => mode.name == value,
          orElse: () => BottleInteractionMode.drag,
        );
      }
    } catch (_) {}
    return BottleInteractionMode.drag;
  }

  /// Saves the bottle interaction mode.
  Future<void> setBottleInteractionMode(BottleInteractionMode mode) async {
    try {
      await _storage.write(
        key: _bottleInteractionModeKey,
        value: mode.name,
      );
    } catch (_) {}
  }
}

