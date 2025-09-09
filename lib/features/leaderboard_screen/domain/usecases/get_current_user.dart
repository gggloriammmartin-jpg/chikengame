import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetCurrentUser {
  final UserRepository _repository;

  GetCurrentUser(this._repository);

  Future<User?> call() async {
    return await _repository.getCurrentUser();
  }
}
