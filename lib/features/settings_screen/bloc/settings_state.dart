class SettingsState {
  final bool isMusicEnabled;
  final bool isSoundFXEnabled;
  final bool isLoading;
  final bool isInitialized;
  final bool isPlaying;
  final String? error;

  const SettingsState({
    this.isMusicEnabled = false,
    this.isSoundFXEnabled = true, // По умолчанию включены
    this.isLoading = false,
    this.isInitialized = false,
    this.isPlaying = false,
    this.error,
  });

  SettingsState copyWith({
    bool? isMusicEnabled,
    bool? isSoundFXEnabled,
    bool? isLoading,
    bool? isInitialized,
    bool? isPlaying,
    String? error,
  }) {
    return SettingsState(
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSoundFXEnabled: isSoundFXEnabled ?? this.isSoundFXEnabled,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error,
    );
  }
}
