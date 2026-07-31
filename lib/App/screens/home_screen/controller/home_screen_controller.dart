import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../routes/app_routes.dart';
import '../binding/home_screen_binding.dart';

class HomeScreenController extends StateController<HomeScreenBinding> {
  void playButtonClicked(BuildContext context) {
    Navigator.pushNamed(context, Routes.levelSelectionScreen);
  }

  void settingsButtonClicked(BuildContext context) {
    Navigator.pushNamed(context, Routes.settingsScreen);
  }

  void dailyChallengeClicked(BuildContext context) {
    Navigator.pushNamed(context, Routes.playScreen, arguments: 1);
  }
}