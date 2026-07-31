import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/puzzle/puzzle_model.dart';
import '../../../routes/app_routes.dart';
import '../binding/level_selection_page.dart';

class LevelSelectionController extends StateController<LevelSelectionBinding> {
  Future<void> onLevelTapped(BuildContext context, int levelIndex) async {
    await Navigator.pushNamed(context, Routes.playScreen, arguments: levelIndex + 1);
  }

  Future<void> onDifficultySelected(BuildContext context, DifficultyTier tier) async {
    await Navigator.pushNamed(context, Routes.playScreen, arguments: tier);
  }
}
