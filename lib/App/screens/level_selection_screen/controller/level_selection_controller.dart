import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../routes/app_routes.dart';
import '../binding/level_selection_binding.dart';

class LevelSelectionController
    extends StateController<LevelSelectionBinding> {
  Future<void> onLevelTapped(BuildContext context, int levelIndex) async {
    await Navigator.pushNamed(
      context,
      Routes.playScreen,
      arguments: levelIndex + 1,
    );
  }
}
