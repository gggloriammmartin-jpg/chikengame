import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../bloc/webview_bloc.dart';
import '../bloc/webview_event.dart';
import '../bloc/webview_state.dart';
import '../data/services/leaderboard_service.dart';
import '../data/services/webview_service.dart';
import '../data/utils/html_generator.dart';
import '../../set_nick_screen/view/set_nick_screen.dart';
import '../../global/services/app_settings_service.dart';
import 'widgets/webview_loading_widget.dart';
import 'widgets/webview_overlay_widget.dart';

class LeaderboardWebViewScreen extends StatefulWidget {
  final bool showWelcome;

  const LeaderboardWebViewScreen({super.key, this.showWelcome = true});

  @override
  State<LeaderboardWebViewScreen> createState() =>
      _LeaderboardWebViewScreenState();
}

class _LeaderboardWebViewScreenState extends State<LeaderboardWebViewScreen> {
  late final WebViewBloc _webViewBloc;
  late final WebViewService _webViewService;
  WebViewController? _controller;
  String? _lastLoadedUrl;

  @override
  void initState() {
    super.initState();
    _webViewService = WebViewService();
    _webViewBloc = WebViewBloc(
      leaderboardService: LeaderboardService(),
      appSettingsService: AppSettingsService(),
    );
    _webViewBloc.add(const WebViewInitialized());
  }

  @override
  void dispose() {
    _webViewService.dispose();
    _webViewBloc.close();
    super.dispose();
  }

  void _initializeWebView(WebViewState state) {
    if (_controller != null) return;

    _controller = _webViewService.createController(
      onPageStarted: (url) {
        _webViewBloc.add(WebViewPageStarted(url));
      },
      onPageFinished: (url) {
        _webViewBloc.add(WebViewPageFinished(url));
        _updateCanGoBack();
      },
      onNavigationRequest: (request) {
        print('WebView: Navigation request: ${request.url}');
        // Разрешаем навигацию для всех запросов
        return NavigationDecision.navigate;
      },
      onWebResourceError: (error) {
        // Игнорируем некоторые ошибки ресурсов для более плавной работы
        if (error.errorCode != -1009) {
          // Игнорируем ошибки сети
          _webViewBloc.add(
            WebViewError(error: error.description, errorCode: error.errorCode),
          );
        }
      },
      onUrlChange: (change) {
        print('WebView: URL changed to: ${change.url}');
      },
    );

    // Загружаем WebView только если у нас есть данные для лидерборда
    if (state.userNickname != null || state.isCustomUrl) {
      _loadWebView(state);
    }
  }

  Future<void> _loadWebView(WebViewState state) async {
    if (_controller == null) return;

    final url = _getWebViewUrl(state);
    
    // Предотвращаем повторную загрузку того же URL
    if (_lastLoadedUrl == url) return;
    
    _lastLoadedUrl = url;
    print('WebView: Loading URL: $url');

    try {
      // Загружаем URL асинхронно для более быстрого отклика UI
      unawaited(_webViewService.loadUrl(url));
    } catch (e) {
      _webViewBloc.add(WebViewError(error: 'Failed to load URL: $e'));
    }
  }


  String _getWebViewUrl(WebViewState state) {
    // Если включен fallback режим, всегда показываем HTML лидерборд
    if (state.isFallbackMode) {
      return _getLeaderboardUrl(state);
    }

    // Если URL пустой или содержит только "Loading...", генерируем лидерборд
    if (state.webViewUrl.isEmpty ||
        state.webViewUrl.contains('Loading...') ||
        state.webViewUrl ==
            'data:text/html;charset=utf-8,<html><body><h1>Loading...</h1></body></html>') {
      return _getLeaderboardUrl(state);
    }

    // Если URL начинается с 'data:', это HTML контент (дефолтный лидерборд)
    if (state.webViewUrl.startsWith('data:')) {
      return state.webViewUrl;
    }

    // Если это внешний URL, проверяем, что он валидный
    try {
      final uri = Uri.parse(state.webViewUrl);
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        return state.webViewUrl;
      }
    } catch (e) {
      print('Invalid webview URL: ${state.webViewUrl}, error: $e');
    }

    // Если URL невалидный, возвращаем дефолтный HTML лидерборд
    return _getLeaderboardUrl(state);
  }

  String _getLeaderboardUrl(WebViewState state) {
    return HtmlGenerator.generateLeaderboardUrl(
      nickname: state.userNickname ?? 'Guest',
      leaderboardData: state.leaderboardData,
      statusBarHeight: MediaQuery.of(context).padding.top,
      showWelcome: widget.showWelcome,
    );
  }

  Future<void> _updateCanGoBack() async {
    final canGoBack = await _webViewService.canGoBack();
    _webViewBloc.updateCanGoBack(canGoBack);
  }

  Future<void> _goBack() async {
    final canGoBack = await _webViewService.canGoBack();
    if (canGoBack) {
      // Если есть история навигации, возвращаемся назад
      _webViewService.goBack();
    } else {
      // Если некуда возвращаться, закрываем WebView
      _closeWebView();
    }
  }

  void _closeWebView() {
    Navigator.pushNamedAndRemoveUntil(context, '/menu', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _webViewBloc,
      child: PopScope(
        canPop: false, // Отключаем автоматическое закрытие
        onPopInvoked: (didPop) async {
          if (!didPop) {
            // Обрабатываем системную кнопку "назад"
            await _goBack();
          }
        },
        child: BlocListener<WebViewBloc, WebViewState>(
          listener: (context, state) {
            // Если нужно перейти к экрану ввода ника
            if (state.shouldNavigateToSetNick) {
              // Сбрасываем флаг навигации
              _webViewBloc.add(
                const WebViewUrlChanged(url: '', isCustomUrl: false),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SetNickScreen()),
              );
              return;
            }

            // Инициализируем WebView когда данные загружены
            if (state.isInitialized &&
                !state.isLoading &&
                _controller == null) {
              _initializeWebView(state);
            }

            // Загружаем WebView только при первой инициализации
            // Отключаем автоматическую перезагрузку для предотвращения циклических загрузок
            if (state.isInitialized &&
                _controller != null &&
                _lastLoadedUrl == null &&
                (state.userNickname != null || state.isCustomUrl || state.isFallbackMode)) {
              _loadWebView(state);
            }

            // Если переключились в fallback режим и у нас загружен внешний URL, перезагружаем с HTML лидербордом
            if (state.isFallbackMode && 
                _controller != null && 
                _lastLoadedUrl != null && 
                !_lastLoadedUrl!.startsWith('data:') &&
                state.webViewUrl.isNotEmpty &&
                !state.webViewUrl.startsWith('data:')) {
              _lastLoadedUrl = null; // Сбрасываем, чтобы можно было загрузить fallback
              _loadWebView(state);
            }
          },
          child: BlocBuilder<WebViewBloc, WebViewState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: (state.isCustomUrl && !state.isFallbackMode)
                    ? Colors.white
                    : const Color(0xFFE8F4FD),
                body: Stack(
                  children: [
                    // WebView
                    Positioned.fill(
                      child: state.isLoading || _controller == null
                          ? WebViewLoadingWidget(isCustomUrl: state.isCustomUrl && !state.isFallbackMode)
                          : Container(
                              decoration: BoxDecoration(
                                color: (state.isCustomUrl && !state.isFallbackMode)
                                    ? Colors.white
                                    : const Color(0xFFE8F4FD),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: (state.isCustomUrl && !state.isFallbackMode)
                                      ? MediaQuery.of(context).padding.top
                                      : 0,
                                ),
                                child: WebViewWidget(controller: _controller!),
                              ),
                            ),
                    ),

                    // Нативный оверлей с кнопками и заголовком
                    WebViewOverlayWidget(
                      isCustomUrl: state.isCustomUrl,
                      canGoBack: state.canGoBack,
                      onBackPressed: _goBack,
                      onClosePressed: _closeWebView,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
