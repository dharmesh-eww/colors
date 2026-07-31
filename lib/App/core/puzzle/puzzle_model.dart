import 'package:flutter/material.dart';
import '../models/paint_model.dart';

/// Represents a generated puzzle level with target color, recipe, and options.
class PuzzleLevel {
  final int levelNumber;
  final String difficultyName; // 'Easy', 'Medium', 'Hard', 'Expert', etc.
  final int requiredColorCount; // Number of required mixture colors (2 to 5-6)
  final int extraColorCount; // Number of extra distractor colors
  final Color targetColor;
  final String targetHex;
  final Map<PaintType, double> targetRecipe; // Recipe in ml per PaintType
  final List<PaintBottle> availableBottles; // Options displayed on Play Screen

  const PuzzleLevel({
    required this.levelNumber,
    required this.difficultyName,
    required this.requiredColorCount,
    required this.extraColorCount,
    required this.targetColor,
    required this.targetHex,
    required this.targetRecipe,
    required this.availableBottles,
  });
}
