import 'package:flutter/material.dart';
import '../../../core/enums/bottle_interaction_mode.dart';
import '../../../core/repository/color_repository.dart';
import '../../../core/services/settings_storage_service.dart';

class PlayScreenRepository {
  final ColorRepository _colorRepository = ColorRepository();
  final SettingsStorageService _settingsStorage = SettingsStorageService();

  Future<BottleInteractionMode> loadBottleInteractionMode() =>
      _settingsStorage.getBottleInteractionMode();

  Color generateTargetColor({Color? previousColor}) {
    return _colorRepository.generateTargetColor(previousColor: previousColor);
  }

  Color mixPaints({
    required double cyan,
    required double magenta,
    required double yellow,
    required double black,
    required double white,
  }) {
    return _colorRepository.mixPaints(
      cyan: cyan,
      magenta: magenta,
      yellow: yellow,
      black: black,
      white: white,
    );
  }

  double calculateAccuracy(Color target, Color mixed) {
    return _colorRepository.calculateAccuracy(target, mixed);
  }
}