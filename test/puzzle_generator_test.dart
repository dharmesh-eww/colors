import 'package:flutter_test/flutter_test.dart';
import 'package:colors/core/puzzle/puzzle_generator.dart';

void main() {
  group('PuzzleGenerator Tests', () {
    test('Levels 1-20 have 2 required colors (Easy)', () {
      for (int level = 1; level <= 20; level++) {
        final puzzle = PuzzleGenerator.generateLevel(level);
        expect(puzzle.requiredColorCount, equals(2));
        expect(puzzle.difficultyName, equals('Easy'));
        expect(puzzle.availableBottles.length, greaterThan(2));
      }
    });

    test('Levels 21-40 have 3 required colors (Medium)', () {
      for (int level = 21; level <= 40; level++) {
        final puzzle = PuzzleGenerator.generateLevel(level);
        expect(puzzle.requiredColorCount, equals(3));
        expect(puzzle.difficultyName, equals('Medium'));
      }
    });

    test('Levels 41-60 have 4 required colors (Hard)', () {
      for (int level = 41; level <= 60; level++) {
        final puzzle = PuzzleGenerator.generateLevel(level);
        expect(puzzle.requiredColorCount, equals(4));
        expect(puzzle.difficultyName, equals('Hard'));
      }
    });

    test('Levels 61-80 have 5 required colors (Expert)', () {
      for (int level = 61; level <= 80; level++) {
        final puzzle = PuzzleGenerator.generateLevel(level);
        expect(puzzle.requiredColorCount, equals(5));
        expect(puzzle.difficultyName, equals('Expert'));
      }
    });

    test('Custom difficulty gap scales correctly', () {
      // Custom gap of 10
      final p1 = PuzzleGenerator.generateLevel(1, difficultyGap: 10);
      final p11 = PuzzleGenerator.generateLevel(11, difficultyGap: 10);

      expect(p1.requiredColorCount, equals(2));
      expect(p11.requiredColorCount, equals(3));
    });

    test('Deterministic generation: Same level yields identical puzzle every time', () {
      final p1a = PuzzleGenerator.generateLevel(42);
      final p1b = PuzzleGenerator.generateLevel(42);

      expect(p1a.targetColor, equals(p1b.targetColor));
      expect(p1a.targetHex, equals(p1b.targetHex));
      expect(p1a.requiredColorCount, equals(p1b.requiredColorCount));
      expect(p1a.availableBottles.length, equals(p1b.availableBottles.length));

      for (int i = 0; i < p1a.availableBottles.length; i++) {
        expect(p1a.availableBottles[i].type, equals(p1b.availableBottles[i].type));
      }
    });

    test('Options contain ALL required recipe colors (solvable puzzle)', () {
      for (int level = 1; level <= 100; level++) {
        final puzzle = PuzzleGenerator.generateLevel(level);
        final optionTypes = puzzle.availableBottles.map((b) => b.type).toSet();

        for (var requiredType in puzzle.targetRecipe.keys) {
          expect(optionTypes.contains(requiredType), isTrue,
              reason: 'Option bottles for Level $level must contain required color $requiredType');
        }
      }
    });
  });
}
