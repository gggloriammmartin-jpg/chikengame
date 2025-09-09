import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<bool> setNickname(String nickname);
  Future<bool> clearNickname();
}
