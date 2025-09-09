import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  final AudioPlayer player = AudioPlayer();

  MusicService._internal() {
    _init();
  }

  Future<void> _init() async {
    try {
      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none, // Не перехватываем фокус
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers}, 
          ),
        ),
      );
    } catch (e) {
      print('Music service initialization failed: $e');
      // Продолжаем работу без специальных настроек контекста
    }
  }

  Future<void> play() async {
    await player.setReleaseMode(ReleaseMode.loop);
    await player.setVolume(0.8);
    await player.play(AssetSource('sounds/game_music_loop.mp3'));
    print("🔊 Music started playing");
  }

  Future<void> stop() async {
    await player.stop();
  }

  Future<void> dispose() async {
    await player.stop(); 
    await player.dispose(); 
  }
}
