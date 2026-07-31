import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

abstract interface class SettingsScreenBinding implements StateBinding {
  void toggleSound(bool value);
  void updateVolume(double value);
  void resetGameProgress(BuildContext context);
}