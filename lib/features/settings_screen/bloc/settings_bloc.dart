import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chiken_odyssey/features/global/services/music_service.dart';
import 'package:chiken_odyssey/features/global/services/sound_effect_service.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_state.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_event.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final MusicService _musicService = MusicService();
  final SoundEffectService _soundEffectService = SoundEffectService();
  SharedPreferences? _prefs;

  SettingsBloc() : super(const SettingsState()) {
    on<InitializeMusic>(_onInitializeMusic);
    on<LoadSettings>(_onLoadSettings);
    on<ToggleMusic>(_onToggleMusic);
    on<ToggleSoundFX>(_onToggleSoundFX);
    on<PlayerStateChanged>(_onPlayerStateChanged);
    on<ErrorOccurred>(_onErrorOccurred);

    // Безопасно слушаем изменения состояния плеера
    try {
      _musicService.player.onPlayerStateChanged.listen((playerState) {
        final isPlaying = playerState == PlayerState.playing;
        print('Player state changed: $playerState, isPlaying: $isPlaying');
        if (state.isPlaying != isPlaying) {
          add(PlayerStateChanged(isPlaying));
        }
      });
    } catch (e) {
      print('Failed to setup player state listener: $e');
    }
  }

  Future<void> _onInitializeMusic(
    InitializeMusic event,
    Emitter<SettingsState> emit,
  ) async {
    if (state.isInitialized) {
      return; // Музыка уже инициализирована
    }

    emit(state.copyWith(isLoading: true));

    try {
      // Инициализируем SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Загружаем сохраненные настройки
      final savedMusicEnabled = _prefs?.getBool('isMusicEnabled') ?? false;
      final savedSoundFXEnabled = _prefs?.getBool('isSoundFXEnabled') ?? true; // По умолчанию включены
      
      print('Loading saved settings: Music=$savedMusicEnabled, SoundFX=$savedSoundFXEnabled');
      
      // Инициализируем звуковые эффекты
      await _soundEffectService.init();

      // Настраиваем аудиоплеер
      await _musicService.player.setReleaseMode(ReleaseMode.loop);
      await _musicService.player.setVolume(0.8);

      emit(
        state.copyWith(
          isMusicEnabled: savedMusicEnabled,
          isSoundFXEnabled: savedSoundFXEnabled,
          isInitialized: true,
          isLoading: false,
          error: null,
        ),
      );

      // Если музыка была включена, запускаем её
      if (savedMusicEnabled) {
        await _playMusic();
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to initialize audio: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    if (!state.isInitialized) {
      add(InitializeMusic());
      return;
    }

    try {
      // Загружаем настройки из SharedPreferences
      final isMusicEnabled = _prefs?.getBool('isMusicEnabled') ?? false;
      final isSoundFXEnabled = _prefs?.getBool('isSoundFXEnabled') ?? true; // По умолчанию включены
      
      emit(state.copyWith(
        isMusicEnabled: isMusicEnabled,
        isSoundFXEnabled: isSoundFXEnabled,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to load settings: ${e.toString()}'));
    }
  }

  Future<void> _onToggleMusic(
    ToggleMusic event,
    Emitter<SettingsState> emit,
  ) async {
    print('ToggleMusic event: ${event.isEnabled}');
    emit(state.copyWith(isLoading: true));

    try {
      // Сохраняем настройку в SharedPreferences
      await _prefs?.setBool('isMusicEnabled', event.isEnabled);
      print('Saving music setting: ${event.isEnabled}');

      if (event.isEnabled) {
        print('Enabling music...');
        await _playMusic();
      } else {
        print('Disabling music...');
        await _stopMusic();
      }

      emit(
        state.copyWith(
          isMusicEnabled: event.isEnabled,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to toggle music: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onToggleSoundFX(
    ToggleSoundFX event,
    Emitter<SettingsState> emit,
  ) async {
    print('ToggleSoundFX event: ${event.isEnabled}');
    
    try {
      // Сохраняем настройку в SharedPreferences
      await _prefs?.setBool('isSoundFXEnabled', event.isEnabled);
      print('Saving sound FX setting: ${event.isEnabled}');

      emit(
        state.copyWith(
          isSoundFXEnabled: event.isEnabled,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: 'Failed to toggle sound FX: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onPlayerStateChanged(
    PlayerStateChanged event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isPlaying: event.isPlaying));
  }

  Future<void> _onErrorOccurred(
    ErrorOccurred event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(error: event.error));
  }

  Future<void> _playMusic() async {
    try {
      if (state.isPlaying) {
        print('Music is already playing, skipping...');
        return;
      }
      await _musicService.play();
      print('Music started playing');
    } catch (e) {
      add(ErrorOccurred('Failed to play music: ${e.toString()}'));
    }
  }

  Future<void> _stopMusic() async {
    try {
      if (!state.isPlaying) {
        print('Music is not playing, nothing to stop');
        return;
      }
      await _musicService.stop();
      print('Music stopped');
    } catch (e) {
      add(ErrorOccurred('Failed to stop music: ${e.toString()}'));
    }
  }

  // Методы для воспроизведения звуковых эффектов
  Future<void> playClick() async {
    if (state.isSoundFXEnabled) {
      try {
        await _soundEffectService.playClick();
      } catch (e) {
        print('Failed to play click sound: $e');
      }
    }
  }

  Future<void> playBonus() async {
    if (state.isSoundFXEnabled) {
      try {
        await _soundEffectService.playBonus();
      } catch (e) {
        print('Failed to play bonus sound: $e');
      }
    }
  }

  Future<void> playCrash() async {
    if (state.isSoundFXEnabled) {
      try {
        await _soundEffectService.playCrash();
      } catch (e) {
        print('Failed to play crash sound: $e');
      }
    }
  }

  Future<void> playGameOver() async {
    if (state.isSoundFXEnabled) {
      try {
        await _soundEffectService.playGameOver();
      } catch (e) {
        print('Failed to play game over sound: $e');
      }
    }
  }

  @override
  Future<void> close() async {
    await _musicService.dispose();
    await _soundEffectService.dispose();
    return super.close();
  }
}
