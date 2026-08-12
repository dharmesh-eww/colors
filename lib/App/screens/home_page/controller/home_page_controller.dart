import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/puzzle/puzzle_model.dart';
import '../../../routes/app_routes.dart';
import '../binding/home_page_binding.dart';

class HomePageController extends StateController<HomePageBinding> {
  int _currentTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;

  void changeTab(int index) {
    _currentTabIndex = index;
    update();
  }

  void playButtonClicked(BuildContext context) {}

  void settingsButtonClicked(BuildContext context) {
    Navigator.pushNamed(context, Routes.settingsScreen);
  }

  void dailyChallengeClicked(BuildContext context) {
    Navigator.pushNamed(context, Routes.playScreen, arguments: DifficultyTier.dailyPuzzle);
  }

  void onDifficultyClicked(BuildContext context, DifficultyTier tier) {
    Navigator.pushNamed(context, Routes.playScreen, arguments: tier);
  }
}
