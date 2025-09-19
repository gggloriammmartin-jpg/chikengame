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
      // В версии 5.2.1 API для аудио контекста может отличаться
      print('Music service initialized successfully');
    } catch (e) {
      print('Music service initialization failed: $e');
      // Продолжаем работу без специальных настроек контекста
    }
  }

  Future<void> play() async {
    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0.8);
      await player.play(AssetSource('sounds/game_music_loop.mp3'));
      print("🔊 Music started playing");
    } catch (e) {
      print("Failed to play music: $e");
      rethrow;
    }
  }

  Future<void> stop() async {
    try {
      await player.stop();
    } catch (e) {
      print("Failed to stop music: $e");
    }
  }

  Future<void> dispose() async {
    try {
      await player.stop(); 
      await player.dispose(); 
    } catch (e) {
      print("Failed to dispose music player: $e");
    }
  }
}
