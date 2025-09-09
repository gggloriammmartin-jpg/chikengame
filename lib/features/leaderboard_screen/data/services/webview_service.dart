import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewService {
  WebViewController? _controller;
  final StreamController<String> _urlController = StreamController<String>.broadcast();
  final StreamController<bool> _canGoBackController = StreamController<bool>.broadcast();

  Stream<String> get urlStream => _urlController.stream;
  Stream<bool> get canGoBackStream => _canGoBackController.stream;

  WebViewController? get controller => _controller;

  WebViewController createController({
    required Function(String) onPageStarted,
    required Function(String) onPageFinished,
    required FutureOr<NavigationDecision> Function(NavigationRequest) onNavigationRequest,
    required Function(WebResourceError) onWebResourceError,
    required Function(UrlChange) onUrlChange,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1')
      ..setBackgroundColor(const Color(0xFFE8F4FD))
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle JavaScript messages if needed
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _urlController.add(url);
            onPageStarted(url);
          },
          onPageFinished: (String url) {
            onPageFinished(url);
            _updateCanGoBack();
          },
          onNavigationRequest: onNavigationRequest,
          onWebResourceError: onWebResourceError,
          onUrlChange: onUrlChange,
        ),
      );

    return _controller!;
  }

  Future<void> loadUrl(String url) async {
    if (_controller == null) return;

    print('WebView: Loading URL: $url');
    
    try {
      await _controller!.loadRequest(
        Uri.parse(url),
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Cache-Control': 'max-age=300',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'none',
          'Sec-Fetch-User': '?1',
        },
      );
      
    } catch (e) {
      print('WebView load error: $e');
      rethrow;
    }
  }

  Future<void> goBack() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
    }
  }

  Future<bool> canGoBack() async {
    if (_controller == null) return false;
    return await _controller!.canGoBack();
  }

  Future<void> _updateCanGoBack() async {
    final canGoBackValue = await canGoBack();
    _canGoBackController.add(canGoBackValue);
  }

  void dispose() {
    _urlController.close();
    _canGoBackController.close();
  }
}
