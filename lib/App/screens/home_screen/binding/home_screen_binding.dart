import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

abstract interface class HomeScreenBinding implements StateBinding {
  void playButtonClicked(BuildContext context);
  void settingsButtonClicked(BuildContext context);
  void dailyChallengeClicked(BuildContext context);
}