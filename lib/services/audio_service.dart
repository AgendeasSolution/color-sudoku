import 'package:audioplayers/audioplayers.dart';

/// Service to manage game sound effects
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  // Play valid move sound
  Future<void> playValidMove() async {
    try {
      await _player.play(AssetSource('audio/move_9.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play invalid move sound
  Future<void> playInvalidMove() async {
    try {
      await _player.play(AssetSource('audio/block_2.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play button click sound
  Future<void> playButtonClick() async {
    try {
      await _player.play(AssetSource('audio/mouse_click_3.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play win sound
  Future<void> playWin() async {
    try {
      await _player.play(AssetSource('audio/win_2.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Play fail sound
  Future<void> playFail() async {
    try {
      await _player.play(AssetSource('audio/fail_1.mp3'));
    } catch (e) {
      // Ignore errors silently
    }
  }

  // Dispose the audio player
  void dispose() {
    _player.dispose();
  }
}

