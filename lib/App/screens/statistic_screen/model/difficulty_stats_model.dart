import 'package:flutter/material.dart';

enum DifficultyFilter {
  all,
  easy,
  medium,
  hard,
  expert,
  challenge,
}

extension DifficultyFilterX on DifficultyFilter {
  String get displayName {
    switch (this) {
      case DifficultyFilter.all:
        return 'All';
      case DifficultyFilter.easy:
        return 'Easy';
      case DifficultyFilter.medium:
        return 'Medium';
      case DifficultyFilter.hard:
        return 'Hard';
      case DifficultyFilter.expert:
        return 'Expert';
      case DifficultyFilter.challenge:
        return '2-Min Run';
    }
  }

  String get subtitle {
    switch (this) {
      case DifficultyFilter.all:
        return 'All Puzzles Combined';
      case DifficultyFilter.easy:
        return '2 Primary Paints';
      case DifficultyFilter.medium:
        return '3 Paints';
      case DifficultyFilter.hard:
        return '4 Paints';
      case DifficultyFilter.expert:
        return '5 Paints';
      case DifficultyFilter.challenge:
        return '2-Min Speed Run';
    }
  }

  Color get primaryColor {
    switch (this) {
      case DifficultyFilter.all:
        return const Color(0xFFFFD700); // Warm Gold
      case DifficultyFilter.easy:
        return const Color(0xFF4CAF50); // Emerald Green
      case DifficultyFilter.medium:
        return const Color(0xFFFFB703); // Amber Gold
      case DifficultyFilter.hard:
        return const Color(0xFFE63946); // Ruby Red
      case DifficultyFilter.expert:
        return const Color(0xFF9D4EDD); // Royal Purple
      case DifficultyFilter.challenge:
        return const Color(0xFFFF5722); // Flame Orange
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultyFilter.all:
        return Icons.auto_awesome_rounded;
      case DifficultyFilter.easy:
        return Icons.sentiment_satisfied_alt_rounded;
      case DifficultyFilter.medium:
        return Icons.extension_rounded;
      case DifficultyFilter.hard:
        return Icons.psychology_rounded;
      case DifficultyFilter.expert:
        return Icons.military_tech_rounded;
      case DifficultyFilter.challenge:
        return Icons.timer_rounded;
    }
  }
}

class DifficultyStatsModel {
  final DifficultyFilter filter;
  final int totalPlayed;
  final int totalWins;
  final int perfectPlays;
  final int bestWinStreak;
  final int currentWinStreak;
  final Duration? bestTime;
  final Duration? avgTime;
  final int totalStars;
  final int totalHintsUsed;
  final double avgAccuracyPercent;
  final int threeStarWins;
  final int twoStarWins;
  final int oneStarWins;

  const DifficultyStatsModel({
    required this.filter,
    required this.totalPlayed,
    required this.totalWins,
    required this.perfectPlays,
    required this.bestWinStreak,
    required this.currentWinStreak,
    this.bestTime,
    this.avgTime,
    required this.totalStars,
    required this.totalHintsUsed,
    required this.avgAccuracyPercent,
    required this.threeStarWins,
    required this.twoStarWins,
    required this.oneStarWins,
  });

  int get totalLosses => (totalPlayed - totalWins).clamp(0, totalPlayed);

  double get winRatePercent =>
      totalPlayed > 0 ? (totalWins / totalPlayed) * 100.0 : 0.0;

  String get formattedWinRate => '${winRatePercent.toStringAsFixed(1)}%';

  String get formattedBestTime {
    if (bestTime == null) return '--:--';
    final minutes = bestTime!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = bestTime!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get formattedAvgTime {
    if (avgTime == null) return '--:--';
    final minutes = avgTime!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = avgTime!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
