import 'package:equatable/equatable.dart';

abstract class WebViewEvent extends Equatable {
  const WebViewEvent();

  @override
  List<Object?> get props => [];
}

class WebViewInitialized extends WebViewEvent {
  const WebViewInitialized();
}

class WebViewUrlChanged extends WebViewEvent {
  final String url;
  final bool isCustomUrl;

  const WebViewUrlChanged({
    required this.url,
    required this.isCustomUrl,
  });

  @override
  List<Object?> get props => [url, isCustomUrl];
}

class WebViewPageStarted extends WebViewEvent {
  final String url;

  const WebViewPageStarted(this.url);

  @override
  List<Object?> get props => [url];
}

class WebViewPageFinished extends WebViewEvent {
  final String url;

  const WebViewPageFinished(this.url);

  @override
  List<Object?> get props => [url];
}

class WebViewError extends WebViewEvent {
  final String error;
  final int? errorCode;

  const WebViewError({
    required this.error,
    this.errorCode,
  });

  @override
  List<Object?> get props => [error, errorCode];
}

class WebViewLoadingTimeout extends WebViewEvent {
  const WebViewLoadingTimeout();
}

class WebViewReloadRequested extends WebViewEvent {
  final String url;

  const WebViewReloadRequested(this.url);

  @override
  List<Object?> get props => [url];
}

class WebViewCanGoBackChanged extends WebViewEvent {
  final bool canGoBack;

  const WebViewCanGoBackChanged({required this.canGoBack});

  @override
  List<Object?> get props => [canGoBack];
}

class WebViewFallbackRequested extends WebViewEvent {
  const WebViewFallbackRequested();

  @override
  List<Object?> get props => [];
}
