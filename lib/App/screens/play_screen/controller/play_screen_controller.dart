import 'dart:async';
import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';
import '../../../core/enums/bottle_interaction_mode.dart';
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
  DifficultyTier? _currentDifficultyTier;
  int _puzzleStreakCount = 1;
  PuzzleLevel? _currentPuzzle;

  Color _targetColor = const Color(0xFF008080);
  Color _mixedColor = const Color(0xFFFFFFFF);

  PaintType _selectedType = PaintType.cyan;
  double _accuracy = 0.0;
  bool _isMixed = false;
  bool _isCompleted = false;
  BottleInteractionMode _bottleInteractionMode = BottleInteractionMode.drag;

  int _restartCount = 0;
  int _earnedStars = 0;
  int _earnedCoins = 0;
  int _availableCoins = 0;

  final Map<PaintType, PaintBottle> _bottles = {};

  PaintMixingGame? flameGame;

  PlayScreenController();

  Timer? _timer;
  int _elapsedSeconds = 0;
  int _remainingSeconds = 120;
  bool _isTimeUp = false;

  @override
  void onInit() {
    super.onInit();
    _loadInteractionMode();
    _loadAvailableCoins();
  }

  Future<void> _loadInteractionMode() async {
    _bottleInteractionMode = await _repository.loadBottleInteractionMode();
    update();
  }

  Future<void> _loadAvailableCoins() async {
    _availableCoins = await _levelStorageService.getCoins();
    update();
  }

  // Getters
  int get currentLevelNumber => _currentLevelNumber;
  DifficultyTier? get currentDifficultyTier => _currentDifficultyTier;
  int get puzzleStreakCount => _puzzleStreakCount;
  bool get isDifficultyMode => _currentDifficultyTier != null;
  bool get isCountdownMode => _currentDifficultyTier?.isCountdown ?? false;
  int get remainingSeconds => _remainingSeconds;
  bool get isTimeUp => _isTimeUp;
  PuzzleLevel? get currentPuzzle => _currentPuzzle;
  Color get targetColor => _targetColor;
  Color get mixedColor => _mixedColor;
  PaintType get selectedType => _selectedType;
  double get accuracy => _accuracy;
  bool get isMixed => _isMixed;
  bool get isCompleted => _isCompleted;
  BottleInteractionMode get bottleInteractionMode => _bottleInteractionMode;
  int get restartCount => _restartCount;
  int get earnedStars => _earnedStars;
  int get earnedCoins => _earnedCoins;
  int get availableCoins => _availableCoins;
  List<PaintBottle> get bottles => _bottles.values.toList();
  PaintBottle? get selectedBottle => _bottles[_selectedType];

  int get elapsedSeconds => _elapsedSeconds;


  String get formattedTime {
    final int totalSecs = isCountdownMode ? _remainingSeconds : _elapsedSeconds;
    final minutes = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSecs % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get targetHex => _currentPuzzle?.targetHex ?? _colorToHex(_targetColor);

  void startTimer() {
    _timer?.cancel();
    _elapsedSeconds = 0;
    _remainingSeconds = _currentDifficultyTier?.countdownDurationSeconds ?? 120;
    _isTimeUp = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isCountdownMode) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          stopTimer();
          _isTimeUp = true;
        }
      } else {
        _elapsedSeconds++;
      }
      update();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void attachFlameGame(PaintMixingGame game) {
    flameGame = game;
  }

  void loadDifficulty(DifficultyTier tier) {
    _currentDifficultyTier = tier;
    _currentPuzzle = PuzzleGenerator.generateRandomPuzzleForDifficulty(
      tier,
      puzzleIndex: _puzzleStreakCount,
    );
    _targetColor = _currentPuzzle!.targetColor;

    _bottles.clear();
    for (var bottle in _currentPuzzle!.availableBottles) {
      _bottles[bottle.type] = bottle.copyWith(availableMl: 100.0, pouredMl: 0.0);
    }

    if (_bottles.isNotEmpty) {
      _selectedType = _bottles.keys.first;
    }

    _restartCount = 0;
    _earnedStars = 0;
    _resetPaintsInternal();
    _isCompleted = false;
    _isTimeUp = false;
    startTimer();
    update();
  }

  void retryChallenge() {
    _restartCount++;
    _resetPaintsInternal();
    _isCompleted = false;
    _isTimeUp = false;
    startTimer();
    update();
  }

  void loadLevel(int levelNumber) {
    _currentDifficultyTier = null;
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

    _restartCount = 0;
    _earnedStars = 0;
    _resetPaintsInternal();
    _isCompleted = false;
    startTimer();
    update();
  }

  void selectColorType(PaintType type) {
    _selectedType = type;
    update();
  }

  void initNewTarget() {
    if (_currentDifficultyTier != null) {
      _puzzleStreakCount++;
      loadDifficulty(_currentDifficultyTier!);
    } else {
      loadLevel(_currentLevelNumber + 1);
    }
  }

  void _resetPaintsInternal() {
    final keys = _bottles.keys.toList();
    for (var key in keys) {
      final bottle = _bottles[key];
      if (bottle != null) {
        _bottles[key] = bottle.copyWith(availableMl: 100.0, pouredMl: 0.0);
      }
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

  Future<int> _calculateEarnedStars() async {
    if (_currentDifficultyTier != null) return 0; // Stars only for level puzzles

    final bool isFirstTime = (await _levelStorageService.getLevelStars(_currentLevelNumber)) == 0;

    int stars = 1; // Base 1 star for completing (accuracy >= 95%)

    // Star 2 condition: Fast solve (<= 60s) with <= 1 restart, OR first-time play with <= 1 restart
    if (_elapsedSeconds <= 60 && _restartCount <= 1) {
      stars = 2;
    } else if (isFirstTime && _restartCount <= 1) {
      stars = 2;
    }

    // Star 3 condition: Master speed (<= 35s) with 0 restarts, OR first-time play in <= 45s with 0 restarts
    if (_elapsedSeconds <= 35 && _restartCount == 0) {
      stars = 3;
    } else if (isFirstTime && _elapsedSeconds <= 45 && _restartCount == 0) {
      stars = 3;
    }

    return stars.clamp(1, 3);
  }

  int _calculateEarnedCoins(int stars) {
    if (_currentDifficultyTier == null) {
      // Level complete: 1-2 coins based on performance & star
      return (stars >= 3) ? 2 : 1;
    } else {
      // Difficulty play:
      switch (_currentDifficultyTier!) {
        case DifficultyTier.easy:
        case DifficultyTier.medium:
          return 1; // Easy, Medium complete -> 1 coin
        case DifficultyTier.hard:
          return 2; // Hard complete -> 2 coins
        case DifficultyTier.expert:
        case DifficultyTier.challenge:
          // Expert & Challenge complete based on performance (1-3 coins):
          if (_accuracy >= 98.0 && _elapsedSeconds <= 45 && _restartCount == 0) {
            return 3;
          } else if (_accuracy >= 95.0 && _elapsedSeconds <= 70 && _restartCount <= 1) {
            return 2;
          } else {
            return 1;
          }
      }
    }
  }

  /// Evaluates completion only when the user finishes dragging/pouring.
  void checkCompletionOnPourEnd() async {
    if (_accuracy >= 95.0 && !_isCompleted) {
      _isCompleted = true;
      stopTimer();
      flameGame?.triggerVictoryCelebration(_mixedColor);

      if (_currentDifficultyTier == null) {
        _earnedStars = await _calculateEarnedStars();
        await _levelStorageService.saveLevelStars(_currentLevelNumber, _earnedStars);
        await _levelStorageService.unlockNextLevel(_currentLevelNumber);
      } else {
        _earnedStars = 0;
      }

      _earnedCoins = _calculateEarnedCoins(_earnedStars);
      _availableCoins = await _levelStorageService.addCoins(_earnedCoins);

      update();
    }
  }

  void resetMix() {
    _restartCount++;
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