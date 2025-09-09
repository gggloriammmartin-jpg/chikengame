import '../repositories/leaderboard_repository.dart';

class UpdatePlayerScore {
  final LeaderboardRepository _repository;

  UpdatePlayerScore(this._repository);

  Future<bool> call(String nickname, int score) async {
    return await _repository.updatePlayerScore(nickname, score);
  }
}
