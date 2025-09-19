import 'package:audioplayers/audioplayers.dart';

class SoundEffectService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    try {
      // В версии 5.2.1 API для аудио контекста может отличаться
      print('Sound effect service initialized successfully');
    } catch (e) {
      print('Sound effect service initialization failed: $e');
      // Продолжаем работу без специальных настроек контекста
    }
  }

  Future<void> playClick() async {
    try {
      await _player.play(AssetSource('sounds/jump.mp3'));
    } catch (e) {
      print('Failed to play click sound: $e');
    }
  }

  Future<void> playBonus() async {
    try {
      await _player.play(AssetSource('sounds/bonus.mp3'));
    } catch (e) {
      print('Failed to play bonus sound: $e');
    }
  }

  Future<void> playCrash() async {
    try {
      await _player.play(AssetSource('sounds/crash_platform.mp3'));
    } catch (e) {
      print('Failed to play crash sound: $e');
    }
  }

  Future<void> playGameOver() async {
    try {
      await _player.play(AssetSource('sounds/falling_game_over.mp3'));
    } catch (e) {
      print('Failed to play game over sound: $e');
    }
  }

  Future<void> play(String assetPath) async {
    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      print('Failed to play sound $assetPath: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      print('Failed to dispose sound effect player: $e');
    }
  }
}
