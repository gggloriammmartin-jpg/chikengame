import '../repositories/leaderboard_repository.dart';

class CreatePlayer {
  final LeaderboardRepository _repository;

  CreatePlayer(this._repository);

  Future<bool> call(String nickname) async {
    return await _repository.createPlayer(nickname);
  }
}
