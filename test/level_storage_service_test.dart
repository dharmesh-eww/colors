import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:colors/core/services/level_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LevelStorageService Tests', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('Default unlocked level is 1', () async {
      final service = LevelStorageService();
      final level = await service.getUnlockedLevel();
      expect(level, equals(1));
    });

    test('Saving and retrieving unlocked level', () async {
      final service = LevelStorageService();
      await service.saveUnlockedLevel(16);
      final level = await service.getUnlockedLevel();
      expect(level, equals(16));
    });

    test('unlockNextLevel updates storage when completing current highest level', () async {
      final service = LevelStorageService();
      await service.saveUnlockedLevel(5);

      final next = await service.unlockNextLevel(5);
      expect(next, equals(6));

      final stored = await service.getUnlockedLevel();
      expect(stored, equals(6));
    });

    test('unlockNextLevel does not downgrade when completing an earlier level', () async {
      final service = LevelStorageService();
      await service.saveUnlockedLevel(10);

      final result = await service.unlockNextLevel(3);
      expect(result, equals(10));

      final stored = await service.getUnlockedLevel();
      expect(stored, equals(10));
    });
  });
}
