import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/models/paint_model.dart';
import '../../../game/paint_mixing_game.dart';
import '../binding/play_screen_binding.dart';
import '../repository/play_screen_repository.dart';

class PlayScreenController extends StateController<PlayScreenBinding> {
  final PlayScreenRepository _repository = PlayScreenRepository();

  Color _targetColor = const Color(0xFF008080); // Teal default
  Color _mixedColor = const Color(0xFFFFFFFF);

  PaintType _selectedType = PaintType.cyan;
  double _accuracy = 0.0;
  bool _isMixed = false;
  bool _isCompleted = false;

  late final Map<PaintType, PaintBottle> _bottles;

  PaintMixingGame? flameGame;

  PlayScreenController() {
    _bottles = {
      PaintType.cyan: PaintBottle(
        type: PaintType.cyan,
        name: 'Cyan',
        color: const Color(0xFF00FFFF),
        hexCode: '#00FFFF',
      ),
      PaintType.magenta: PaintBottle(
        type: PaintType.magenta,
        name: 'Magenta',
        color: const Color(0xFFFF00FF),
        hexCode: '#FF00FF',
      ),
      PaintType.yellow: PaintBottle(
        type: PaintType.yellow,
        name: 'Yellow',
        color: const Color(0xFFFFFF00),
        hexCode: '#FFFF00',
      ),
      PaintType.black: PaintBottle(
        type: PaintType.black,
        name: 'Black',
        color: const Color(0xFF000000),
        hexCode: '#000000',
      ),
      PaintType.white: PaintBottle(
        type: PaintType.white,
        name: 'White',
        color: const Color(0xFFFFFFFF),
        hexCode: '#FFFFFF',
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

  String get targetHex {
    final r = (targetColor.r * 255).round();
    final g = (targetColor.g * 255).round();
    final b = (targetColor.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

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
  void pourPaintType(PaintType type, double amountMl) {
    final bottle = _bottles[type];
    if (bottle == null || bottle.availableMl <= 0 || amountMl <= 0) return;

    final double pourAmount = amountMl.clamp(0.0, bottle.availableMl);
    bottle.pouredMl += pourAmount;
    bottle.availableMl = (100.0 - bottle.pouredMl).clamp(0.0, 100.0);

    // Recalculate mixed color using CMYK subtractive model
    _mixedColor = _repository.mixPaints(
      cyan: _bottles[PaintType.cyan]!.pouredMl,
      magenta: _bottles[PaintType.magenta]!.pouredMl,
      yellow: _bottles[PaintType.yellow]!.pouredMl,
      black: _bottles[PaintType.black]!.pouredMl,
      white: _bottles[PaintType.white]!.pouredMl,
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

      Future.delayed(const Duration(milliseconds: 2500), () {
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