import '../entities/leaderboard_entry.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboard {
  final LeaderboardRepository _repository;

  GetLeaderboard(this._repository);

  Future<List<LeaderboardEntry>> call({int limit = 15}) async {
    return await _repository.getLeaderboard(limit: limit);
  }
}
