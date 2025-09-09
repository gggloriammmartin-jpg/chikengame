import 'package:equatable/equatable.dart';
import '../domain/entities/leaderboard_entry.dart';

class WebViewState extends Equatable {
  final bool isLoading;
  final bool canGoBack;
  final String? userNickname;
  final List<LeaderboardEntry> leaderboardData;
  final String webViewUrl;
  final bool isCustomUrl;
  final String? error;
  final bool isInitialized;
  final bool shouldNavigateToSetNick;
  final bool isFallbackMode;

  const WebViewState({
    this.isLoading = true,
    this.canGoBack = false,
    this.userNickname,
    this.leaderboardData = const [],
    this.webViewUrl = '',
    this.isCustomUrl = false,
    this.error,
    this.isInitialized = false,
    this.shouldNavigateToSetNick = false,
    this.isFallbackMode = false,
  });

  WebViewState copyWith({
    bool? isLoading,
    bool? canGoBack,
    String? userNickname,
    List<LeaderboardEntry>? leaderboardData,
    String? webViewUrl,
    bool? isCustomUrl,
    String? error,
    bool? isInitialized,
    bool? shouldNavigateToSetNick,
    bool? isFallbackMode,
  }) {
    return WebViewState(
      isLoading: isLoading ?? this.isLoading,
      canGoBack: canGoBack ?? this.canGoBack,
      userNickname: userNickname ?? this.userNickname,
      leaderboardData: leaderboardData ?? this.leaderboardData,
      webViewUrl: webViewUrl ?? this.webViewUrl,
      isCustomUrl: isCustomUrl ?? this.isCustomUrl,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
      shouldNavigateToSetNick: shouldNavigateToSetNick ?? this.shouldNavigateToSetNick,
      isFallbackMode: isFallbackMode ?? this.isFallbackMode,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        canGoBack,
        userNickname,
        leaderboardData,
        webViewUrl,
        isCustomUrl,
        error,
        isInitialized,
        shouldNavigateToSetNick,
        isFallbackMode,
      ];
}
