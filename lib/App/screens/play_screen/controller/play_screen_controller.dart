import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/paint_model.dart';
import '../../../game/paint_mixing_game.dart';
import '../binding/play_screen_binding.dart';
import '../repository/play_screen_repository.dart';

class PlayScreenController extends StateController<PlayScreenBinding> {
  final PlayScreenRepository _repository = PlayScreenRepository();

  Color _targetColor = const Color(0xFFE6BE28);
  Color _mixedColor = const Color(0xFFFFFFFF);

  PaintType _selectedType = PaintType.red;
  double _accuracy = 0.0;
  bool _isMixed = false;
  bool _isCompleted = false;

  late final Map<PaintType, PaintBottle> _bottles;

  PaintMixingGame? flameGame;

  PlayScreenController() {
    _bottles = {
      PaintType.red: PaintBottle(
        type: PaintType.red,
        name: 'Red',
        color: const Color(0xFFFF7675),
        emoji: '🔴',
      ),
      PaintType.green: PaintBottle(
        type: PaintType.green,
        name: 'Green',
        color: const Color(0xFF55E6C1),
        emoji: '🟢',
      ),
      PaintType.blue: PaintBottle(
        type: PaintType.blue,
        name: 'Blue',
        color: const Color(0xFF74B9FF),
        emoji: '🔵',
      ),
      PaintType.white: PaintBottle(
        type: PaintType.white,
        name: 'White',
        color: const Color(0xFFF5F6FA),
        emoji: '⚪',
      ),
      PaintType.black: PaintBottle(
        type: PaintType.black,
        name: 'Black',
        color: const Color(0xFF2D3436),
        emoji: '⬛',
      ),
    };
  }

  // Getters
  Color get targetColor => _targetColor;
  Color get mixedColor => _mixedColor;
  PaintType get selectedType => _selectedType;
  double get accuracy => _accuracy;
  bool get isMixed => _isMixed;
  bool get isCompleted => _isCompleted;
  List<PaintBottle> get bottles => _bottles.values.toList();
  PaintBottle get selectedBottle => _bottles[_selectedType]!;

  @override
  void onInit() {
    super.onInit();
    initNewTarget();
  }

  void attachFlameGame(PaintMixingGame game) {
    flameGame = game;
  }

  void selectColorType(PaintType type) {
    _selectedType = type;
    update();
  }

  void initNewTarget() {
    _targetColor = _repository.generateTargetColor(previousColor: _targetColor);
    _resetPaintsInternal();
    _isCompleted = false;
    update();
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
  /// Updates live mixed color and live accuracy without triggering victory completion during active pouring.
  void pourPaintType(PaintType type, double amountMl) {
    final bottle = _bottles[type];
    if (bottle == null || bottle.availableMl <= 0 || amountMl <= 0) return;

    final double pourAmount = amountMl.clamp(0.0, bottle.availableMl);
    bottle.pouredMl += pourAmount;
    bottle.availableMl = (100.0 - bottle.pouredMl).clamp(0.0, 100.0);

    // Recalculate mixed color
    _mixedColor = _repository.mixPaints(
      red: _bottles[PaintType.red]!.pouredMl,
      green: _bottles[PaintType.green]!.pouredMl,
      blue: _bottles[PaintType.blue]!.pouredMl,
      white: _bottles[PaintType.white]!.pouredMl,
      black: _bottles[PaintType.black]!.pouredMl,
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

      Future.delayed(const Duration(milliseconds: 2200), () {
        initNewTarget();
      });

      update();
    }
  }

  void resetMix() {
    _resetPaintsInternal();
    update();
  }
}