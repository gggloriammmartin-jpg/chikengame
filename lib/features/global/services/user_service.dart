import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class UserService {
  static const String _nicknameKey = 'user_nickname';
  
  static Future<String?> getNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nicknameKey);
  }
  
  static Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nicknameKey, nickname);
  }
  
  static Future<bool> hasNickname() async {
    final nickname = await getNickname();
    return nickname != null && nickname.isNotEmpty;
  }
  
  static Future<void> clearNickname() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nicknameKey);
  }

  // Проверяем доступность ника в Firebase
  static Future<bool> isNicknameAvailable(String nickname) async {
    return await FirebaseService.isNicknameAvailable(nickname);
  }

  // Создаем игрока в Firebase
  static Future<bool> createPlayer(String nickname) async {
    return await FirebaseService.createPlayer(nickname);
  }

  // Обновляем счет игрока
  static Future<bool> updateScore(int score) async {
    final nickname = await getNickname();
    if (nickname != null) {
      return await FirebaseService.updatePlayerScore(nickname, score);
    }
    return false;
  }

  // Получаем данные игрока
  static Future<Map<String, dynamic>?> getPlayerData() async {
    final nickname = await getNickname();
    if (nickname != null) {
      final player = await FirebaseService.getPlayer(nickname);
      return player?.toMap();
    }
    return null;
  }
}
