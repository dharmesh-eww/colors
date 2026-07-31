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

  /// Generates a deterministic puzzle level for [levelNumber] (1 to N).
  ///
  /// - [levelNumber]: Target level number (1-based).
  /// - [difficultyGap]: Number of levels per difficulty group (default: 20).
  /// - [minColors]: Minimum required mixture colors for tier 0 (default: 2).
  /// - [maxColors]: Maximum mixture colors for high tiers (default: 6).
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

    // Difficulty tier name
    final String difficultyName = _getDifficultyName(groupIndex);

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
      difficultyName: difficultyName,
      requiredColorCount: requiredColorCount,
      extraColorCount: distractorCountToAdd,
      targetColor: targetColor,
      targetHex: targetHex,
      targetRecipe: targetRecipe,
      availableBottles: availableBottles,
    );
  }

  static String _getDifficultyName(int groupIndex) {
    switch (groupIndex) {
      case 0:
        return 'Easy';
      case 1:
        return 'Medium';
      case 2:
        return 'Hard';
      case 3:
        return 'Expert';
      case 4:
        return 'Master';
      default:
        return 'Grandmaster';
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
