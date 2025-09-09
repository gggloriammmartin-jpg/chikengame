import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_bloc.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  // Методы для воспроизведения звуков в игре
  static void playJumpSound(BuildContext context) {
    try {
      final settingsBloc = context.read<SettingsBloc>();
      print('AudioManager: Playing jump sound, SoundFX enabled: ${settingsBloc.state.isSoundFXEnabled}');
      settingsBloc.playClick();
    } catch (e) {
      print('AudioManager: Error playing jump sound: $e');
    }
  }

  static void playBonusSound(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.playBonus();
  }

  static void playCrashSound(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.playCrash();
  }

  static void playGameOverSound(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    settingsBloc.playGameOver();
  }
}
