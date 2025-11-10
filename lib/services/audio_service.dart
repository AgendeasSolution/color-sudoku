import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage game sound effects
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  static AudioService get instance => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  static const String _soundEnabledKey = 'sound_enabled';
  bool? _soundEnabledCache;

  /// Initialize and load sound preference
  Future<void> initialize() async {
    await _loadSoundPreference();
  }

  /// Load sound preference from storage
  Future<void> _loadSoundPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabledCache = prefs.getBool(_soundEnabledKey);
      // Default to true if not set
      if (_soundEnabledCache == null) {
        _soundEnabledCache = true;
        await prefs.setBool(_soundEnabledKey, true);
      }
    } catch (e) {
      // Ignore errors, default to enabled
      _soundEnabledCache = true;
    }
  }

  /// Check if sound is enabled
  bool isSoundEnabled() {
    return _soundEnabledCache ?? true;
  }

  /// Enable sound
  Future<void> enableSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabledCache = true;
      await prefs.setBool(_soundEnabledKey, true);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Disable sound
  Future<void> disableSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabledCache = false;
      await prefs.setBool(_soundEnabledKey, false);
    } catch (e) {
      // Ignore errors
    }
  }

  // Play valid move sound
  Future<void> playValidMove() async {
    if (!isSoundEnabled()) return;
    try {
      await _player.play(AssetSource('audio/move_9.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play invalid move sound
  Future<void> playInvalidMove() async {
    if (!isSoundEnabled()) return;
    try {
      await _player.play(AssetSource('audio/block_2.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play button click sound
  Future<void> playButtonClick() async {
    if (!isSoundEnabled()) return;
    try {
      await _player.play(AssetSource('audio/mouse_click_3.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play win sound
  Future<void> playWin() async {
    if (!isSoundEnabled()) return;
    try {
      await _player.play(AssetSource('audio/win_2.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play fail sound
  Future<void> playFail() async {
    if (!isSoundEnabled()) return;
    try {
      await _player.play(AssetSource('audio/fail_1.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play mouse click sound (alias for button click)
  Future<void> playMouseClickSound() async {
    await playButtonClick();
  }

  // Dispose the audio player
  void dispose() {
    _player.dispose();
  }
}

