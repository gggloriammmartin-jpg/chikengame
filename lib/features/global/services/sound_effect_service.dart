import 'package:audioplayers/audioplayers.dart';

class SoundEffectService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> init() async {
    try {
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: <AVAudioSessionOptions>{},
          ),
          android: AudioContextAndroid(
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain, // Перехватываем фокус для звуковых эффектов
          ),
        ),
      );
    } catch (e) {
      print('Sound effect service initialization failed: $e');
      // Продолжаем работу без специальных настроек контекста
    }
  }

  Future<void> playClick() async {
    await _player.play(AssetSource('sounds/jump.mp3'));
  }

  Future<void> playBonus() async {
    await _player.play(AssetSource('sounds/bonus.mp3'));
  }

  Future<void> playCrash() async {
    await _player.play(AssetSource('sounds/crash_platform.mp3'));
  }

  Future<void> playGameOver() async {
    await _player.play(AssetSource('sounds/falling_game_over.mp3'));
  }

  Future<void> play(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
