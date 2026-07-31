import 'package:audioplayers/audioplayers.dart';
import 'settings_storage_service.dart';

/// Central Audio Manager to handle playing background music and sound effects (SFX).
class AudioManager {
  static final AudioManager instance = AudioManager._internal();

  factory AudioManager() => instance;

  AudioManager._internal();

  final SettingsStorageService _settingsStorage = SettingsStorageService();

  // Players
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _mixingPlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isSoundEnabled = true;
  double _volume = 0.8;

  bool _isInitialized = false;

  // Sound File Paths (relative to assets/)
  static const String sfxButtonClick = 'audio/button_click.mp3';
  static const String sfxPuzzleComplete = 'audio/puzzle_complete.mp3';
  static const String sfxColorMixing = 'audio/color_mixing.mp3';
  static const String sfxLevelFail = 'audio/level_fail.mp3';
  static const String bgMusic = 'audio/bg_music.mp3';

  /// Initializes settings and pre-configures audio players.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isSoundEnabled = await _settingsStorage.isSoundEnabled();
    _volume = await _settingsStorage.getSoundVolume();

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _mixingPlayer.setReleaseMode(ReleaseMode.loop);

    _isInitialized = true;
  }

  /// Enable or disable sound effects & music.
  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    await _settingsStorage.setSoundEnabled(enabled);

    if (!enabled) {
      await stopBackgroundMusic();
      await stopColorMixingSound();
      await _sfxPlayer.stop();
    }
  }

  /// Set global sound volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _settingsStorage.setSoundVolume(_volume);

    await _sfxPlayer.setVolume(_volume);
    await _mixingPlayer.setVolume(_volume);
    await _bgmPlayer.setVolume(_volume);
  }

  /// Play button tap / click sound effect.
  Future<void> playButtonClick() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play(AssetSource(sfxButtonClick));
    } catch (_) {}
  }

  /// Play level/puzzle completion victory sound effect.
  Future<void> playPuzzleComplete() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play(AssetSource(sfxPuzzleComplete));
    } catch (_) {}
  }

  /// Start playing liquid mixing / pour loop sound.
  Future<void> startColorMixingSound() async {
    if (!_isSoundEnabled) return;
    try {
      if (_mixingPlayer.state != PlayerState.playing) {
        await _mixingPlayer.setVolume(_volume);
        await _mixingPlayer.play(AssetSource(sfxColorMixing));
      }
    } catch (_) {}
  }

  /// Stop the liquid mixing / pour sound effect.
  Future<void> stopColorMixingSound() async {
    try {
      await _mixingPlayer.stop();
    } catch (_) {}
  }

  /// Play level reset / fail sound effect.
  Future<void> playLevelFail() async {
    if (!_isSoundEnabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(_volume);
      await _sfxPlayer.play(AssetSource(sfxLevelFail));
    } catch (_) {}
  }

  /// Start playing background music loop.
  Future<void> startBackgroundMusic() async {
    if (!_isSoundEnabled) return;
    try {
      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.setVolume(_volume * 0.6); // Slightly lower volume for background music
        await _bgmPlayer.play(AssetSource(bgMusic));
      }
    } catch (_) {}
  }

  /// Stop playing background music.
  Future<void> stopBackgroundMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  /// Dispose of all audio players when no longer needed.
  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _mixingPlayer.dispose();
    await _bgmPlayer.dispose();
  }
}
