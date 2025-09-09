import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local_user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalUserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<User?> getCurrentUser() async {
    return await _dataSource.getCurrentUser();
  }

  @override
  Future<bool> setNickname(String nickname) async {
    return await _dataSource.setNickname(nickname);
  }

  @override
  Future<bool> clearNickname() async {
    return await _dataSource.clearNickname();
  }
}
