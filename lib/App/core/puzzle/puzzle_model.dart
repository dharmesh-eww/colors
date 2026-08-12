import 'package:flutter/material.dart';
import '../models/paint_model.dart';

enum DifficultyTier { easy, medium, hard, expert, challenge, dailyPuzzle }

extension DifficultyTierX on DifficultyTier {
  String get displayName {
    switch (this) {
      case DifficultyTier.easy:
        return 'Easy';
      case DifficultyTier.medium:
        return 'Medium';
      case DifficultyTier.hard:
        return 'Hard';
      case DifficultyTier.expert:
        return 'Expert';
      case DifficultyTier.challenge:
        return '2-Min Challenge';
      case DifficultyTier.dailyPuzzle:
        return 'Daily Puzzle';
    }
  }

  String get description {
    switch (this) {
      case DifficultyTier.easy:
        return '2 Primary Paints • Gentle Mix';
      case DifficultyTier.medium:
        return '3 Paints • Moderate Complexity';
      case DifficultyTier.hard:
        return '4 Paints • Advanced Crafting';
      case DifficultyTier.expert:
        return '5 Paints • Master Alchemist';
      case DifficultyTier.challenge:
        return '2 Minute Countdown • Race Against Time!';
      case DifficultyTier.dailyPuzzle:
        return 'Solve Today\'s Mystery Color Mix!';
    }
  }

  Color get primaryColor {
    switch (this) {
      case DifficultyTier.easy:
        return const Color(0xFF388E3C); // Alchemist Emerald Green
      case DifficultyTier.medium:
        return const Color(0xFFFFB703); // Warm Amber Gold
      case DifficultyTier.hard:
        return const Color(0xFFE63946); // Ruby Red
      case DifficultyTier.expert:
        return const Color(0xFF9D4EDD); // Royal Purple
      case DifficultyTier.challenge:
        return const Color(0xFFFF5722); // Flame Orange
      case DifficultyTier.dailyPuzzle:
        return const Color(0xFFFF9800); // Warm Daily Amber/Gold
    }
  }

  Color get gradientEnd {
    switch (this) {
      case DifficultyTier.easy:
        return const Color(0xFF1B5E20); // Dark Emerald Green
      case DifficultyTier.medium:
        return const Color(0xFFFB8500);
      case DifficultyTier.hard:
        return const Color(0xFF9E2A2B);
      case DifficultyTier.expert:
        return const Color(0xFF5A189A);
      case DifficultyTier.challenge:
        return const Color(0xFFD84315);
      case DifficultyTier.dailyPuzzle:
        return const Color(0xFFE65100);
    }
  }

  int get requiredColors {
    switch (this) {
      case DifficultyTier.easy:
        return 2;
      case DifficultyTier.medium:
        return 3;
      case DifficultyTier.hard:
        return 4;
      case DifficultyTier.expert:
        return 5;
      case DifficultyTier.challenge:
        return 3;
      case DifficultyTier.dailyPuzzle:
        return 3;
    }
  }

  int get distractorColors {
    switch (this) {
      case DifficultyTier.easy:
        return 1;
      case DifficultyTier.medium:
        return 1;
      case DifficultyTier.hard:
        return 2;
      case DifficultyTier.expert:
        return 3;
      case DifficultyTier.challenge:
        return 2;
      case DifficultyTier.dailyPuzzle:
        return 1;
    }
  }

  bool get isCountdown => this == DifficultyTier.challenge;

  int get countdownDurationSeconds => 120; // 2 minutes
}

/// Represents a generated puzzle level with target color, recipe, and options.
class PuzzleLevel {
  final int levelNumber;
  final DifficultyTier tier;
  final String difficultyName; // 'Easy', 'Medium', 'Hard', 'Expert', etc.
  final int requiredColorCount; // Number of required mixture colors (2 to 5-6)
  final int extraColorCount; // Number of extra distractor colors
  final Color targetColor;
  final String targetHex;
  final Map<PaintType, double> targetRecipe; // Recipe in ml per PaintType
  final List<PaintBottle> availableBottles; // Options displayed on Play Screen

  const PuzzleLevel({
    required this.levelNumber,
    required this.tier,
    required this.difficultyName,
    required this.requiredColorCount,
    required this.extraColorCount,
    required this.targetColor,
    required this.targetHex,
    required this.targetRecipe,
    required this.availableBottles,
  });
}

