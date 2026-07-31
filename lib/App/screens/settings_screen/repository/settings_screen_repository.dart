import '../../../core/services/level_storage_service.dart';
import '../../../core/services/settings_storage_service.dart';

class SettingsScreenRepository {
  final SettingsStorageService _settingsStorage = SettingsStorageService();
  final LevelStorageService _levelStorage = LevelStorageService();

  Future<bool> loadSoundEnabled() => _settingsStorage.isSoundEnabled();
  Future<void> saveSoundEnabled(bool enabled) => _settingsStorage.setSoundEnabled(enabled);

  Future<double> loadSoundVolume() => _settingsStorage.getSoundVolume();
  Future<void> saveSoundVolume(double volume) => _settingsStorage.setSoundVolume(volume);

  Future<void> resetProgress() => _levelStorage.resetProgress();
}