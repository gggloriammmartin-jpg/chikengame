import 'dart:io';
import 'package:http/http.dart' as http;

class UrlCheckerService {
  /// Проверяет доступность URL и возвращает HTTP статус код
  /// Возвращает null если произошла ошибка сети
  static Future<int?> checkUrlStatus(String url) async {
    try {
      // Добавляем таймаут для быстрой проверки
      final response = await http.head(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        },
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode;
    } on SocketException {
      // Нет интернет соединения
      return null;
    } on HttpException {
      // HTTP ошибка
      return null;
    } catch (e) {
      // Другие ошибки
      print('URL check error: $e');
      return null;
    }
  }

  /// Проверяет, является ли URL доступным (статус код 2xx)
  static Future<bool> isUrlAccessible(String url) async {
    final statusCode = await checkUrlStatus(url);
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  /// Проверяет, возвращает ли URL ошибку 404
  static Future<bool> isUrl404(String url) async {
    final statusCode = await checkUrlStatus(url);
    return statusCode == 404;
  }
}
