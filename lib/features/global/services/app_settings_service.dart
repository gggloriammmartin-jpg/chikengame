import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettingsService {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _settingsCollection = 'app_settings';
  static const String _settingsDocument = 'webview_settings';

  // Дефолтный URL для webview (пустая строка означает использование лидерборда)
  static const String _defaultWebViewUrl = '';

  /// Получает URL для webview из Firestore
  /// Если URL не найден или произошла ошибка, возвращает дефолтный URL
  Future<String> getWebViewUrl() async {
    try {
      final doc = await _firestore
          .collection(_settingsCollection)
          .doc(_settingsDocument)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final url = data?['webview_url'] as String?;
        
        if (url != null && url.isNotEmpty) {
          print('AppSettingsService: Using custom webview URL: $url');
          return url;
        }
      }
      
      print('AppSettingsService: Using default webview URL');
      return _defaultWebViewUrl;
    } catch (e) {
      print('AppSettingsService: Error getting webview URL: $e');
      return _defaultWebViewUrl;
    }
  }

  /// Получает настройки webview в реальном времени
  Stream<String> getWebViewUrlStream() {
    return _firestore
        .collection(_settingsCollection)
        .doc(_settingsDocument)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final url = data?['webview_url'] as String?;
        
        if (url != null && url.isNotEmpty) {
          print('AppSettingsService: Stream - Using custom webview URL: $url');
          return url;
        }
      }
      
      print('AppSettingsService: Stream - Using default webview URL');
      return _defaultWebViewUrl;
    }).handleError((error) {
      print('AppSettingsService: Stream error: $error');
      return _defaultWebViewUrl;
    });
  }

}
