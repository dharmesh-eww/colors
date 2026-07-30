import 'package:flutter/material.dart';
import '../../../core/repository/color_repository.dart';

class PlayScreenRepository {
  final ColorRepository _colorRepository = ColorRepository();

  Color generateTargetColor({Color? previousColor}) {
    return _colorRepository.generateTargetColor(previousColor: previousColor);
  }

  Color mixPaints({
    required double red,
    required double green,
    required double blue,
    required double white,
    required double black,
  }) {
    return _colorRepository.mixPaints(
      red: red,
      green: green,
      blue: blue,
      white: white,
      black: black,
    );
  }

  double calculateAccuracy(Color target, Color mixed) {
    return _colorRepository.calculateAccuracy(target, mixed);
  }
}