import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/enums/bottle_interaction_mode.dart';
import '../../../core/models/paint_model.dart';
import '../../../core/services/level_storage_service.dart';
import '../../../game/paint_mixing_game.dart';
import '../../../routes/app_routes.dart';
import '../binding/tutorial_screen_binding.dart';

enum TutorialStep { pourRed, pourGreen, completed }

class TutorialScreenController extends StateController<TutorialScreenBinding> {
  final LevelStorageService _storageService = LevelStorageService();

  TutorialStep _currentStep = TutorialStep.pourRed;
  Color _mixedColor = const Color(0xFFFFFFFF);
  double _accuracy = 0.0;
  bool _isRedPoured = false;
  bool _isGreenPoured = false;

  final Color targetColor = const Color(0xFFFFFF00); // Yellow (Red + Green)
  final String targetHex = '#FFFF00';

  late final Map<PaintType, PaintBottle> _bottles;
  PaintMixingGame? flameGame;

  void attachFlameGame(PaintMixingGame game) {
    flameGame = game;
  }

  TutorialScreenController() {
    _bottles = {
      PaintType.magenta: PaintBottle(
        type: PaintType.magenta,
        name: 'RED',
        color: const Color(0xFFFF3333),
        hexCode: '#FF3333',
        availableMl: 100.0,
      ),
      PaintType.cyan: PaintBottle(
        type: PaintType.cyan,
        name: 'GREEN',
        color: const Color(0xFF33FF33),
        hexCode: '#33FF33',
        availableMl: 100.0,
      ),
      PaintType.yellow: PaintBottle(
        type: PaintType.yellow,
        name: 'BLUE',
        color: const Color(0xFF3333FF),
        hexCode: '#3333FF',
        availableMl: 100.0,
      ),
    };
  }

  TutorialStep get currentStep => _currentStep;
  Color get mixedColor => _mixedColor;
  double get accuracy => _accuracy;
  bool get isRedPoured => _isRedPoured;
  bool get isGreenPoured => _isGreenPoured;
  List<PaintBottle> get bottles => _bottles.values.toList();
  BottleInteractionMode get bottleInteractionMode => BottleInteractionMode.drag;

  void pourPaintType(PaintType type, double amountMl, BuildContext context) {
    if (_currentStep == TutorialStep.completed) return;

    if (type == PaintType.magenta && !_isRedPoured) {
      _isRedPoured = true;
      _mixedColor = const Color(0xFFFF3333);
      _accuracy = 50.0;
      _currentStep = TutorialStep.pourGreen;
      update();
    } else if (type == PaintType.cyan && _isRedPoured && !_isGreenPoured) {
      _isGreenPoured = true;
      _mixedColor = targetColor;
      _accuracy = 100.0;
      _currentStep = TutorialStep.completed;
      update();
      _completeTutorialAndGoHome(context);
    }
  }

  void _completeTutorialAndGoHome(BuildContext context) async {
    await _storageService.setTutorialCompleted();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.homeScreen);
    }
  }

  void skipTutorial(BuildContext context) async {
    await _storageService.setTutorialCompleted();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.homeScreen);
    }
  }

  void finishTutorialAndGoHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, Routes.homeScreen);
  }
}