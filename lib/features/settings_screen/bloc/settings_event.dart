abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ToggleMusic extends SettingsEvent {
  final bool isEnabled;
  
  ToggleMusic(this.isEnabled);
}

class ToggleSoundFX extends SettingsEvent {
  final bool isEnabled;
  
  ToggleSoundFX(this.isEnabled);
}

class InitializeMusic extends SettingsEvent {}

class PlayerStateChanged extends SettingsEvent {
  final bool isPlaying;
  
  PlayerStateChanged(this.isPlaying);
}

class ErrorOccurred extends SettingsEvent {
  final String error;
  
  ErrorOccurred(this.error);
}
