import 'package:statekit/statekit.dart';
import '../binding/statistic_screen_binding.dart';
import '../model/difficulty_stats_model.dart';
import '../repository/statistic_screen_repository.dart';

class StatisticScreenController extends StateController<StatisticScreenBinding> {
  final StatisticScreenRepository _repository = StatisticScreenRepository();

  DifficultyFilter _selectedFilter = DifficultyFilter.all;
  late Map<DifficultyFilter, DifficultyStatsModel> _statsMap;

  StatisticScreenController() {
    _statsMap = _repository.fetchStatistics();
  }

  DifficultyFilter get selectedFilter => _selectedFilter;

  DifficultyStatsModel get currentStats =>
      _statsMap[_selectedFilter] ??
      _statsMap[DifficultyFilter.all] ??
      _emptyStats(_selectedFilter);

  DifficultyStatsModel getStatsFor(DifficultyFilter filter) =>
      _statsMap[filter] ?? currentStats;

  static DifficultyStatsModel _emptyStats(DifficultyFilter filter) {
    return DifficultyStatsModel(
      filter: filter,
      totalPlayed: 0,
      totalWins: 0,
      perfectPlays: 0,
      bestWinStreak: 0,
      currentWinStreak: 0,
      totalStars: 0,
      totalHintsUsed: 0,
      avgAccuracyPercent: 0,
      threeStarWins: 0,
      twoStarWins: 0,
      oneStarWins: 0,
    );
  }

  @override
  void onInit() {
    super.onInit();
    _statsMap = _repository.fetchStatistics();
  }

  void setFilter(DifficultyFilter filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    update();
  }
}