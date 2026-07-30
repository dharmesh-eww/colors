import 'package:statekit/statekit.dart';

abstract interface class LevelSelectionBinding implements StateBinding {
  void onLevelTapped(int levelIndex);
}
