import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/services/leaderboard_service.dart';
import '../data/services/url_checker_service.dart';
import '../../global/services/app_settings_service.dart';
import 'webview_event.dart';
import 'webview_state.dart';

class WebViewBloc extends Bloc<WebViewEvent, WebViewState> {
  final LeaderboardService _leaderboardService;
  final AppSettingsService _appSettingsService;
  Timer? _loadingTimeout;
  StreamSubscription<String>? _urlSubscription;

  WebViewBloc({
    required LeaderboardService leaderboardService,
    required AppSettingsService appSettingsService,
  })  : _leaderboardService = leaderboardService,
        _appSettingsService = appSettingsService,
        super(const WebViewState()) {
    on<WebViewInitialized>(_onInitialized);
    on<WebViewUrlChanged>(_onUrlChanged);
    on<WebViewPageStarted>(_onPageStarted);
    on<WebViewPageFinished>(_onPageFinished);
    on<WebViewError>(_onError);
    on<WebViewLoadingTimeout>(_onLoadingTimeout);
    on<WebViewReloadRequested>(_onReloadRequested);
    on<WebViewCanGoBackChanged>(_onCanGoBackChanged);
    on<WebViewFallbackRequested>(_onFallbackRequested);
  }

  Future<void> _onInitialized(
    WebViewInitialized event,
    Emitter<WebViewState> emit,
  ) async {
    try {
      // Загружаем URL из настроек
      final url = await _appSettingsService.getWebViewUrl();
      final isCustomUrl = url.isNotEmpty && !url.startsWith('data:');
      
      // Если это внешний URL, проверяем его доступность
      if (isCustomUrl) {
        final isAccessible = await UrlCheckerService.isUrlAccessible(url);
        final is404 = await UrlCheckerService.isUrl404(url);
        
        if (is404) {
          // URL возвращает 404, сразу переключаемся в fallback режим
          print('WebView: URL returned 404, switching to fallback mode: $url');
          emit(state.copyWith(
            webViewUrl: url,
            isCustomUrl: false,
            isFallbackMode: true,
            isInitialized: true,
          ));
          
          // Загружаем данные лидерборда для fallback
          await _loadLeaderboardData(emit);
          return;
        } else if (!isAccessible) {
          // URL недоступен, но не 404 - пробуем загрузить в WebView
          // Возможно, это проблема с предварительной проверкой
          emit(state.copyWith(
            webViewUrl: url,
            isCustomUrl: isCustomUrl,
            isInitialized: true,
          ));
        } else {
          // URL доступен, загружаем его в WebView
          emit(state.copyWith(
            webViewUrl: url,
            isCustomUrl: isCustomUrl,
            isInitialized: true,
          ));
        }
      } else {
        // Локальный URL или пустой
        emit(state.copyWith(
          webViewUrl: url,
          isCustomUrl: isCustomUrl,
          isInitialized: true,
        ));
      }

      // Загружаем данные лидерборда (если еще не загружены)
      if (!state.isFallbackMode) {
        await _loadLeaderboardData(emit);
      }

      // Слушаем изменения URL
      _urlSubscription = _appSettingsService.getWebViewUrlStream().listen((url) {
        add(WebViewUrlChanged(
          url: url,
          isCustomUrl: url.isNotEmpty && !url.startsWith('data:'),
        ));
      });

    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to initialize: $e',
        isInitialized: true,
      ));
    }
  }

  void _onUrlChanged(
    WebViewUrlChanged event,
    Emitter<WebViewState> emit,
  ) {
    // Предотвращаем повторную обработку того же URL
    if (state.webViewUrl == event.url) {
      return;
    }
    
    // Если переключаемся с fallback режима на внешний URL, проверяем его доступность
    if (state.isFallbackMode && event.isCustomUrl) {
      // Асинхронно проверяем URL, но не блокируем UI
      _checkUrlAndEmit(event, emit);
    } else {
      emit(state.copyWith(
        webViewUrl: event.url,
        isCustomUrl: event.isCustomUrl,
      ));
    }
  }

  Future<void> _checkUrlAndEmit(WebViewUrlChanged event, Emitter<WebViewState> emit) async {
    try {
      final is404 = await UrlCheckerService.isUrl404(event.url);
      if (is404) {
        // URL возвращает 404, остаемся в fallback режиме
        emit(state.copyWith(
          webViewUrl: event.url,
          isCustomUrl: false,
          isFallbackMode: true,
        ));
      } else {
        // URL доступен, переключаемся на него
        emit(state.copyWith(
          webViewUrl: event.url,
          isCustomUrl: event.isCustomUrl,
          isFallbackMode: false,
        ));
      }
    } catch (e) {
      // В случае ошибки проверки, пробуем загрузить URL
      emit(state.copyWith(
        webViewUrl: event.url,
        isCustomUrl: event.isCustomUrl,
        isFallbackMode: false,
      ));
    }
  }

  void _onPageStarted(
    WebViewPageStarted event,
    Emitter<WebViewState> emit,
  ) {
    // Устанавливаем таймаут на 15 секунд для более быстрого отклика
    _loadingTimeout?.cancel();
    _loadingTimeout = Timer(const Duration(seconds: 15), () {
      add(const WebViewLoadingTimeout());
    });

    emit(state.copyWith(
      isLoading: true,
      error: null,
    ));
  }

  void _onPageFinished(
    WebViewPageFinished event,
    Emitter<WebViewState> emit,
  ) {
    _loadingTimeout?.cancel();
    emit(state.copyWith(
      isLoading: false,
    ));
  }

  void _onError(
    WebViewError event,
    Emitter<WebViewState> emit,
  ) {
    _loadingTimeout?.cancel();
    
    // Проверяем, является ли это ошибкой для внешнего URL
    // Некоторые коды ошибок, которые могут указывать на 404 или недоступность:
    // -1009: Нет интернет соединения
    // -1001: Тайм-аут
    // -1003: Хост не найден
    // -1004: Не удается подключиться к серверу
    final shouldFallback = state.isCustomUrl && !state.isFallbackMode && (
      event.errorCode == 404 || 
      event.errorCode == -1009 || 
      event.errorCode == -1001 || 
      event.errorCode == -1003 || 
      event.errorCode == -1004 ||
      event.error.toLowerCase().contains('404') ||
      event.error.toLowerCase().contains('not found')
    );

    if (shouldFallback) {
      // Переключаемся в fallback режим вместо показа ошибки
      print('WebView: Error detected, switching to fallback mode. Error: ${event.error}, Code: ${event.errorCode}');
      emit(state.copyWith(
        isFallbackMode: true,
        isCustomUrl: false,
        isLoading: false,
        error: null,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: event.error,
      ));
    }
  }

  void _onLoadingTimeout(
    WebViewLoadingTimeout event,
    Emitter<WebViewState> emit,
  ) {
    emit(state.copyWith(
      isLoading: false,
      error: 'Loading timeout reached',
    ));
  }

  void _onReloadRequested(
    WebViewReloadRequested event,
    Emitter<WebViewState> emit,
  ) {
    emit(state.copyWith(
      webViewUrl: event.url,
      isCustomUrl: !event.url.startsWith('data:'),
    ));
  }

  void _onCanGoBackChanged(
    WebViewCanGoBackChanged event,
    Emitter<WebViewState> emit,
  ) {
    emit(state.copyWith(canGoBack: event.canGoBack));
  }

  void _onFallbackRequested(
    WebViewFallbackRequested event,
    Emitter<WebViewState> emit,
  ) {
    emit(state.copyWith(
      isFallbackMode: true,
      isCustomUrl: false,
      error: null,
      isLoading: false,
    ));
  }

  Future<void> _loadLeaderboardData(Emitter<WebViewState> emit) async {
    try {
      final user = await _leaderboardService.getCurrentUser();
      final nickname = user?.nickname;

      if (nickname == null || nickname.isEmpty) {
        // Отправляем событие навигации только если еще не отправляли
        if (!state.shouldNavigateToSetNick) {
          emit(state.copyWith(
            shouldNavigateToSetNick: true,
            isLoading: false,
          ));
        }
        return;
      }

      final leaderboard = await _leaderboardService.getLeaderboard(limit: 15);

      emit(state.copyWith(
        userNickname: nickname,
        leaderboardData: leaderboard,
        isLoading: false,
        shouldNavigateToSetNick: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load leaderboard: $e',
        isLoading: false,
        shouldNavigateToSetNick: false,
      ));
    }
  }

  void updateCanGoBack(bool canGoBack) {
    add(WebViewCanGoBackChanged(canGoBack: canGoBack));
  }

  @override
  Future<void> close() {
    _loadingTimeout?.cancel();
    _urlSubscription?.cancel();
    return super.close();
  }
}
