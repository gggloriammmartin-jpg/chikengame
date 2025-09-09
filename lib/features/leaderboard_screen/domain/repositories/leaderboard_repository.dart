import '../entities/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  /// Получить топ игроков лидерборда
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 15});
  
  /// Получить поток обновлений лидерборда
  Stream<List<LeaderboardEntry>> getLeaderboardStream({int limit = 15});
  
  /// Обновить счет игрока
  Future<bool> updatePlayerScore(String nickname, int score);
  
  /// Проверить доступность ника
  Future<bool> isNicknameAvailable(String nickname);
  
  /// Создать нового игрока
  Future<bool> createPlayer(String nickname);
}
