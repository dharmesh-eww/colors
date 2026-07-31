import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service for managing level progress and unlocked levels.
class LevelStorageService {
  static const String _unlockedLevelKey = 'current_unlocked_level';
  final FlutterSecureStorage _storage;

  LevelStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Retrieves the highest unlocked level (default: 1).
  Future<int> getUnlockedLevel() async {
    try {
      final String? value = await _storage.read(key: _unlockedLevelKey);
      if (value != null) {
        final int? parsed = int.tryParse(value);
        if (parsed != null && parsed >= 1) {
          return parsed;
        }
      }
    } catch (_) {
      // Fallback on error/null
    }
    return 1;
  }

  /// Saves the specified [levelNumber] as the unlocked level.
  Future<void> saveUnlockedLevel(int levelNumber) async {
    try {
      await _storage.write(
        key: _unlockedLevelKey,
        value: levelNumber.toString(),
      );
    } catch (_) {}
  }

  /// Unlocks the next level if [completedLevel] is equal to or greater than current unlocked level.
  Future<int> unlockNextLevel(int completedLevel) async {
    final currentUnlocked = await getUnlockedLevel();
    if (completedLevel >= currentUnlocked) {
      final nextLevel = completedLevel + 1;
      await saveUnlockedLevel(nextLevel);
      return nextLevel;
    }
    return currentUnlocked;
  }

  /// Resets unlocked level back to 1.
  Future<void> resetProgress() async {
    try {
      await _storage.delete(key: _unlockedLevelKey);
    } catch (_) {}
  }
}
