import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for persisting app and sound settings.
class SettingsStorageService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _soundVolumeKey = 'sound_volume';

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
}
