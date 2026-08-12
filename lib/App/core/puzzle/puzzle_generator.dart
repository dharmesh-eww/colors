import 'dart:math';
import 'package:flutter/material.dart';
import '../game_logic/color_mixer.dart';
import '../models/paint_model.dart';
import 'puzzle_model.dart';

/// Level-wise Deterministic Puzzle Generator.
///
/// Generates reproducible color mixing puzzles for levels 1 to N based on:
/// - Difficulty gap (default: 20 levels per difficulty tier)
/// - Increasing color mixture complexity (min 2, max 5-6 colors)
/// - Target color & recipe calculation
/// - Required option bottles + Extra distractor option bottles (1, 2, 3 extra)
class PuzzleGenerator {
  static const int defaultDifficultyGap = 20;
  static const int defaultMinColors = 2;
  static const int defaultMaxColors = 6;

  /// Default CMYK primary paint bottles
  static final Map<PaintType, PaintBottle> _defaultPrimaryBottles = {
    PaintType.cyan: PaintBottle(
      type: PaintType.cyan,
      name: 'Cyan',
      color: const Color(0xFF00FFFF),
      hexCode: '#00FFFF',
    ),
    PaintType.magenta: PaintBottle(
      type: PaintType.magenta,
      name: 'Magenta',
      color: const Color(0xFFFF00FF),
      hexCode: '#FF00FF',
    ),
    PaintType.yellow: PaintBottle(
      type: PaintType.yellow,
      name: 'Yellow',
      color: const Color(0xFFFFFF00),
      hexCode: '#FFFF00',
    ),
    PaintType.black: PaintBottle(
      type: PaintType.black,
      name: 'Black',
      color: const Color(0xFF000000),
      hexCode: '#000000',
    ),
    PaintType.white: PaintBottle(
      type: PaintType.white,
      name: 'White',
      color: const Color(0xFFFFFFFF),
      hexCode: '#FFFFFF',
    ),
  };

  /// Formats date into ddMMyy format level number (e.g. 010826 for 1st Aug 2026).
  static int getDailyPuzzleLevelNumber([DateTime? date]) {
    final now = date ?? DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = (now.year % 100).toString().padLeft(2, '0');
    return int.parse('$day$month$year');
  }

  /// Generates a random puzzle level tailored specifically for [tier].
  static PuzzleLevel generateRandomPuzzleForDifficulty(
    DifficultyTier tier, {
    int puzzleIndex = 1,
  }) {
    final int levelNum = (tier == DifficultyTier.dailyPuzzle)
        ? getDailyPuzzleLevelNumber()
        : puzzleIndex;

    final int seed = (tier == DifficultyTier.dailyPuzzle)
        ? (levelNum * 10007 + 7919)
        : (DateTime.now().microsecondsSinceEpoch ^ (puzzleIndex * 31));

    final Random random = Random(seed);

    final int requiredColorCount = tier.requiredColors;
    final int extraColorCount = tier.distractorColors;

    final List<PaintType> allTypes = List.from(PaintType.values);
    allTypes.shuffle(random);

    final List<PaintType> recipeTypes =
        allTypes.take(requiredColorCount.clamp(1, allTypes.length)).toList();

    final List<PaintType> distractorCandidates =
        allTypes.where((type) => !recipeTypes.contains(type)).toList();

    final Map<PaintType, double> targetRecipe = {};
    double cyanMl = 0.0;
    double magentaMl = 0.0;
    double yellowMl = 0.0;
    double blackMl = 0.0;
    double whiteMl = 0.0;

    for (var type in recipeTypes) {
      final double amountMl = (3 + random.nextInt(7)) * 5.0;
      targetRecipe[type] = amountMl;

      switch (type) {
        case PaintType.cyan:
          cyanMl = amountMl;
          break;
        case PaintType.magenta:
          magentaMl = amountMl;
          break;
        case PaintType.yellow:
          yellowMl = amountMl;
          break;
        case PaintType.black:
          blackMl = amountMl;
          break;
        case PaintType.white:
          whiteMl = amountMl;
          break;
      }
    }

    final Color targetColor = ColorMixer.mix(
      cyanMl: cyanMl,
      magentaMl: magentaMl,
      yellowMl: yellowMl,
      blackMl: blackMl,
      whiteMl: whiteMl,
    );

    final String targetHex = _colorToHex(targetColor);
    final List<PaintBottle> availableBottles = [];

    for (var type in recipeTypes) {
      final base = _defaultPrimaryBottles[type]!;
      availableBottles.add(base.copyWith(availableMl: 100.0, pouredMl: 0.0));
    }

    final int distractorCountToAdd = distractorCandidates.isEmpty
        ? 0
        : extraColorCount.clamp(0, distractorCandidates.length);
    for (int i = 0; i < distractorCountToAdd; i++) {
      final type = distractorCandidates[i];
      final base = _defaultPrimaryBottles[type]!;
      availableBottles.add(base.copyWith(availableMl: 100.0, pouredMl: 0.0));
    }

    availableBottles.shuffle(random);

    return PuzzleLevel(
      levelNumber: levelNum,
      tier: tier,
      difficultyName: tier.displayName,
      requiredColorCount: requiredColorCount,
      extraColorCount: distractorCountToAdd,
      targetColor: targetColor,
      targetHex: targetHex,
      targetRecipe: targetRecipe,
      availableBottles: availableBottles,
    );
  }

  /// Generates a deterministic puzzle level for [levelNumber] (1 to N).
  static PuzzleLevel generateLevel(
    int levelNumber, {
    int difficultyGap = defaultDifficultyGap,
    int minColors = defaultMinColors,
    int maxColors = defaultMaxColors,
  }) {
    final int validLevel = levelNumber < 1 ? 1 : levelNumber;

    // Determine difficulty group index (0 for 1-20, 1 for 21-40, 2 for 41-60...)
    final int groupIndex = (validLevel - 1) ~/ difficultyGap;

    // Required color complexity (min 2, max 5-6)
    final int requiredColorCount =
        (minColors + groupIndex).clamp(minColors, maxColors);

    // Extra distractor count (1 extra for early, 2 for mid, 3 for high)
    final int extraColorCount = (1 + groupIndex ~/ 2).clamp(1, 3);

    // Difficulty tier
    final DifficultyTier tier = _groupIndexToTier(groupIndex);
    final String difficultyName = tier.displayName;

    // Seeded PRNG for 100% deterministic puzzle generation per level
    final Random random = Random(validLevel * 10007 + 7919);

    // All available primary types
    final List<PaintType> allTypes = List.from(PaintType.values);
    allTypes.shuffle(random);

    // Pick required recipe types
    final List<PaintType> recipeTypes =
        allTypes.take(requiredColorCount.clamp(1, allTypes.length)).toList();

    // Remaining distractor candidate types
    final List<PaintType> distractorCandidates = allTypes
        .where((type) => !recipeTypes.contains(type))
        .toList();

    // Generate recipe amounts (ml) for each required color
    final Map<PaintType, double> targetRecipe = {};
    double cyanMl = 0.0;
    double magentaMl = 0.0;
    double yellowMl = 0.0;
    double blackMl = 0.0;
    double whiteMl = 0.0;

    for (var type in recipeTypes) {
      // Deterministic pour volume (15ml to 45ml in steps of 5ml)
      final double amountMl = (3 + random.nextInt(7)) * 5.0;
      targetRecipe[type] = amountMl;

      switch (type) {
        case PaintType.cyan:
          cyanMl = amountMl;
          break;
        case PaintType.magenta:
          magentaMl = amountMl;
          break;
        case PaintType.yellow:
          yellowMl = amountMl;
          break;
        case PaintType.black:
          blackMl = amountMl;
          break;
        case PaintType.white:
          whiteMl = amountMl;
          break;
      }
    }

    // Mix target color using CMYK subtractive physics
    final Color targetColor = ColorMixer.mix(
      cyanMl: cyanMl,
      magentaMl: magentaMl,
      yellowMl: yellowMl,
      blackMl: blackMl,
      whiteMl: whiteMl,
    );

    final String targetHex = _colorToHex(targetColor);

    // Build available option bottles (ALL required + Extra distractors)
    final List<PaintBottle> availableBottles = [];

    // 1. Add all required recipe bottles (fresh instances)
    for (var type in recipeTypes) {
      final base = _defaultPrimaryBottles[type]!;
      availableBottles.add(base.copyWith(availableMl: 100.0, pouredMl: 0.0));
    }

    // 2. Add extra distractor bottles based on difficulty
    final int distractorCountToAdd = distractorCandidates.isEmpty
        ? 0
        : extraColorCount.clamp(0, distractorCandidates.length);
    for (int i = 0; i < distractorCountToAdd; i++) {
      final type = distractorCandidates[i];
      final base = _defaultPrimaryBottles[type]!;
      availableBottles.add(base.copyWith(availableMl: 100.0, pouredMl: 0.0));
    }

    // Deterministically shuffle option bottles so correct colors aren't always first
    availableBottles.shuffle(random);

    return PuzzleLevel(
      levelNumber: validLevel,
      tier: tier,
      difficultyName: difficultyName,
      requiredColorCount: requiredColorCount,
      extraColorCount: distractorCountToAdd,
      targetColor: targetColor,
      targetHex: targetHex,
      targetRecipe: targetRecipe,
      availableBottles: availableBottles,
    );
  }

  static DifficultyTier _groupIndexToTier(int groupIndex) {
    switch (groupIndex) {
      case 0:
        return DifficultyTier.easy;
      case 1:
        return DifficultyTier.medium;
      case 2:
        return DifficultyTier.hard;
      case 3:
      default:
        return DifficultyTier.expert;
    }
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }
}
