import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../routes/app_routes.dart';
import '../binding/level_selection_binding.dart';

class LevelSelectionController
    extends StateController<LevelSelectionBinding> {
  void onLevelTapped(BuildContext context, int levelIndex) {
    Navigator.pushNamed(context, Routes.playScreen);
  }
}
