import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/paint_model.dart';
import '../../../core/puzzle/puzzle_generator.dart';
import '../../../core/puzzle/puzzle_model.dart';
import '../../../game/paint_mixing_game.dart';
import '../binding/play_screen_binding.dart';
import '../repository/play_screen_repository.dart';
import '../../../core/services/level_storage_service.dart';

class PlayScreenController extends StateController<PlayScreenBinding> {
  final PlayScreenRepository _repository = PlayScreenRepository();
  final LevelStorageService _levelStorageService = LevelStorageService();

  int _currentLevelNumber = 1;
  PuzzleLevel? _currentPuzzle;

  Color _targetColor = const Color(0xFF008080);
  Color _mixedColor = const Color(0xFFFFFFFF);

  PaintType _selectedType = PaintType.cyan;
  double _accuracy = 0.0;
  bool _isMixed = false;
  bool _isCompleted = false;

  final Map<PaintType, PaintBottle> _bottles = {};

  PaintMixingGame? flameGame;

  PlayScreenController();

  // Getters
  int get currentLevelNumber => _currentLevelNumber;
  PuzzleLevel? get currentPuzzle => _currentPuzzle;
  Color get targetColor => _targetColor;
  Color get mixedColor => _mixedColor;
  PaintType get selectedType => _selectedType;
  double get accuracy => _accuracy;
  bool get isMixed => _isMixed;
  bool get isCompleted => _isCompleted;
  List<PaintBottle> get bottles => _bottles.values.toList();
  PaintBottle? get selectedBottle => _bottles[_selectedType];

  String get targetHex => _currentPuzzle?.targetHex ?? _colorToHex(_targetColor);

  @override
  void onInit() {
    super.onInit();
    loadLevel(1);
  }

  void attachFlameGame(PaintMixingGame game) {
    flameGame = game;
  }

  void loadLevel(int levelNumber) {
    _currentLevelNumber = levelNumber < 1 ? 1 : levelNumber;
    _currentPuzzle = PuzzleGenerator.generateLevel(_currentLevelNumber);
    _targetColor = _currentPuzzle!.targetColor;

    _bottles.clear();
    for (var bottle in _currentPuzzle!.availableBottles) {
      _bottles[bottle.type] = bottle.copyWith(availableMl: 100.0, pouredMl: 0.0);
    }

    if (_bottles.isNotEmpty) {
      _selectedType = _bottles.keys.first;
    }

    _resetPaintsInternal();
    _isCompleted = false;
    update();
  }

  void selectColorType(PaintType type) {
    _selectedType = type;
    update();
  }

  void initNewTarget() {
    loadLevel(_currentLevelNumber + 1);
  }

  void _resetPaintsInternal() {
    for (var bottle in _bottles.values) {
      bottle.availableMl = 100.0;
      bottle.pouredMl = 0.0;
    }
    _mixedColor = const Color(0xFFFFFFFF);
    _accuracy = 0.0;
    _isMixed = false;
  }

  /// Pours paint from the specified [type] bottle into the mixture.
  void pourPaintType(PaintType type, double amountMl) {
    final bottle = _bottles[type];
    if (bottle == null || bottle.availableMl <= 0 || amountMl <= 0) return;

    final double pourAmount = amountMl.clamp(0.0, bottle.availableMl);
    bottle.pouredMl += pourAmount;
    bottle.availableMl = (100.0 - bottle.pouredMl).clamp(0.0, 100.0);

    // Recalculate mixed color using CMYK subtractive model
    _mixedColor = _repository.mixPaints(
      cyan: _bottles[PaintType.cyan]?.pouredMl ?? 0.0,
      magenta: _bottles[PaintType.magenta]?.pouredMl ?? 0.0,
      yellow: _bottles[PaintType.yellow]?.pouredMl ?? 0.0,
      black: _bottles[PaintType.black]?.pouredMl ?? 0.0,
      white: _bottles[PaintType.white]?.pouredMl ?? 0.0,
    );

    _accuracy = _repository.calculateAccuracy(_targetColor, _mixedColor);
    _isMixed = true;

    flameGame?.triggerMixAnimation(_mixedColor);

    update();
  }

  /// Evaluates completion only when the user finishes dragging/pouring.
  void checkCompletionOnPourEnd() {
    if (_accuracy >= 95.0 && !_isCompleted) {
      _isCompleted = true;
      flameGame?.triggerVictoryCelebration(_mixedColor);

      // Save unlocked level progress securely
      _levelStorageService.unlockNextLevel(_currentLevelNumber);

      Future.delayed(const Duration(milliseconds: 2500), () {
        initNewTarget();
      });

      update();
    }
  }

  void resetMix() {
    _resetPaintsInternal();
    _isCompleted = false;
    update();
  }

  static String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }
}