import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/firebase_leaderboard_datasource.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirebaseLeaderboardDataSource _dataSource;

  LeaderboardRepositoryImpl(this._dataSource);

  @override
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 15}) async {
    return await _dataSource.getLeaderboard(limit: limit);
  }

  @override
  Stream<List<LeaderboardEntry>> getLeaderboardStream({int limit = 15}) {
    return _dataSource.getLeaderboardStream(limit: limit);
  }

  @override
  Future<bool> updatePlayerScore(String nickname, int score) async {
    return await _dataSource.updatePlayerScore(nickname, score);
  }

  @override
  Future<bool> isNicknameAvailable(String nickname) async {
    return await _dataSource.isNicknameAvailable(nickname);
  }

  @override
  Future<bool> createPlayer(String nickname) async {
    return await _dataSource.createPlayer(nickname);
  }
}
