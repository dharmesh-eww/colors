import 'package:statekit/statekit.dart';
import '../model/difficulty_stats_model.dart';

abstract interface class StatisticScreenBinding implements StateBinding {
  void selectFilter(DifficultyFilter filter);
}