import '../model/difficulty_stats_model.dart';

class StatisticScreenRepository {
  Map<DifficultyFilter, DifficultyStatsModel> fetchStatistics() {
    final easyStats = const DifficultyStatsModel(
      filter: DifficultyFilter.easy,
      totalPlayed: 32,
      totalWins: 30,
      perfectPlays: 22,
      bestWinStreak: 18,
      currentWinStreak: 6,
      bestTime: Duration(seconds: 18),
      avgTime: Duration(seconds: 34),
      totalStars: 88,
      totalHintsUsed: 3,
      avgAccuracyPercent: 97.5,
      threeStarWins: 26,
      twoStarWins: 4,
      oneStarWins: 0,
    );

    final mediumStats = const DifficultyStatsModel(
      filter: DifficultyFilter.medium,
      totalPlayed: 24,
      totalWins: 20,
      perfectPlays: 12,
      bestWinStreak: 10,
      currentWinStreak: 3,
      bestTime: Duration(seconds: 35),
      avgTime: Duration(minutes: 1, seconds: 05),
      totalStars: 54,
      totalHintsUsed: 8,
      avgAccuracyPercent: 94.2,
      threeStarWins: 14,
      twoStarWins: 5,
      oneStarWins: 1,
    );

    final hardStats = const DifficultyStatsModel(
      filter: DifficultyFilter.hard,
      totalPlayed: 16,
      totalWins: 12,
      perfectPlays: 5,
      bestWinStreak: 5,
      currentWinStreak: 1,
      bestTime: Duration(minutes: 1, seconds: 12),
      avgTime: Duration(minutes: 2, seconds: 15),
      totalStars: 30,
      totalHintsUsed: 14,
      avgAccuracyPercent: 90.8,
      threeStarWins: 6,
      twoStarWins: 4,
      oneStarWins: 2,
    );

    final expertStats = const DifficultyStatsModel(
      filter: DifficultyFilter.expert,
      totalPlayed: 8,
      totalWins: 5,
      perfectPlays: 2,
      bestWinStreak: 3,
      currentWinStreak: 0,
      bestTime: Duration(minutes: 2, seconds: 04),
      avgTime: Duration(minutes: 3, seconds: 40),
      totalStars: 12,
      totalHintsUsed: 11,
      avgAccuracyPercent: 86.4,
      threeStarWins: 2,
      twoStarWins: 2,
      oneStarWins: 1,
    );

    final challengeStats = const DifficultyStatsModel(
      filter: DifficultyFilter.challenge,
      totalPlayed: 10,
      totalWins: 7,
      perfectPlays: 3,
      bestWinStreak: 4,
      currentWinStreak: 2,
      bestTime: Duration(seconds: 48),
      avgTime: Duration(minutes: 1, seconds: 20),
      totalStars: 19,
      totalHintsUsed: 6,
      avgAccuracyPercent: 92.0,
      threeStarWins: 4,
      twoStarWins: 2,
      oneStarWins: 1,
    );

    final allStats = DifficultyStatsModel(
      filter: DifficultyFilter.all,
      totalPlayed: easyStats.totalPlayed +
          mediumStats.totalPlayed +
          hardStats.totalPlayed +
          expertStats.totalPlayed +
          challengeStats.totalPlayed,
      totalWins: easyStats.totalWins +
          mediumStats.totalWins +
          hardStats.totalWins +
          expertStats.totalWins +
          challengeStats.totalWins,
      perfectPlays: easyStats.perfectPlays +
          mediumStats.perfectPlays +
          hardStats.perfectPlays +
          expertStats.perfectPlays +
          challengeStats.perfectPlays,
      bestWinStreak: 18,
      currentWinStreak: 6,
      bestTime: const Duration(seconds: 18),
      avgTime: const Duration(minutes: 1, seconds: 16),
      totalStars: easyStats.totalStars +
          mediumStats.totalStars +
          hardStats.totalStars +
          expertStats.totalStars +
          challengeStats.totalStars,
      totalHintsUsed: easyStats.totalHintsUsed +
          mediumStats.totalHintsUsed +
          hardStats.totalHintsUsed +
          expertStats.totalHintsUsed +
          challengeStats.totalHintsUsed,
      avgAccuracyPercent: 93.8,
      threeStarWins: easyStats.threeStarWins +
          mediumStats.threeStarWins +
          hardStats.threeStarWins +
          expertStats.threeStarWins +
          challengeStats.threeStarWins,
      twoStarWins: easyStats.twoStarWins +
          mediumStats.twoStarWins +
          hardStats.twoStarWins +
          expertStats.twoStarWins +
          challengeStats.twoStarWins,
      oneStarWins: easyStats.oneStarWins +
          mediumStats.oneStarWins +
          hardStats.oneStarWins +
          expertStats.oneStarWins +
          challengeStats.oneStarWins,
    );

    return {
      DifficultyFilter.all: allStats,
      DifficultyFilter.easy: easyStats,
      DifficultyFilter.medium: mediumStats,
      DifficultyFilter.hard: hardStats,
      DifficultyFilter.expert: expertStats,
      DifficultyFilter.challenge: challengeStats,
    };
  }
}