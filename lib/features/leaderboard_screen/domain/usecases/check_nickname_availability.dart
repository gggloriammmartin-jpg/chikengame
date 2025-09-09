import '../repositories/leaderboard_repository.dart';

class CheckNicknameAvailability {
  final LeaderboardRepository _repository;

  CheckNicknameAvailability(this._repository);

  Future<bool> call(String nickname) async {
    return await _repository.isNicknameAvailable(nickname);
  }
}
