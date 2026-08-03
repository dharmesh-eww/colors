import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service for managing level progress and unlocked levels.
class LevelStorageService {
  static const String _unlockedLevelKey = 'current_unlocked_level';
  static const String _levelStarsPrefix = 'level_stars_';
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
      await _storage.write(key: _unlockedLevelKey, value: levelNumber.toString());
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

  /// Retrieves earned stars for a level (default: 0).
  Future<int> getLevelStars(int levelNumber) async {
    try {
      final String? value = await _storage.read(key: '$_levelStarsPrefix$levelNumber');
      if (value != null) {
        final int? parsed = int.tryParse(value);
        if (parsed != null && parsed >= 1) {
          return parsed.clamp(1, 3);
        }
      }
    } catch (_) {}
    return 0;
  }

  /// Saves earned stars for a level (only updates if new stars > stored stars).
  Future<int> saveLevelStars(int levelNumber, int stars) async {
    final int currentStars = await getLevelStars(levelNumber);
    final int bestStars = max(currentStars, stars).clamp(1, 3);
    try {
      await _storage.write(key: '$_levelStarsPrefix$levelNumber', value: bestStars.toString());
    } catch (_) {}
    return bestStars;
  }

  /// Resets unlocked level back to 1.
  Future<void> resetProgress() async {
    try {
      await _storage.delete(key: _unlockedLevelKey);
    } catch (_) {}
  }
}
