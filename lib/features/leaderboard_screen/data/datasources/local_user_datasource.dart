import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

abstract class LocalUserDataSource {
  Future<User?> getCurrentUser();
  Future<bool> setNickname(String nickname);
  Future<bool> clearNickname();
}

class LocalUserDataSourceImpl implements LocalUserDataSource {
  final SharedPreferences _prefs;
  static const String _nicknameKey = 'user_nickname';

  LocalUserDataSourceImpl(this._prefs);

  @override
  Future<User?> getCurrentUser() async {
    final nickname = _prefs.getString(_nicknameKey);
    if (nickname != null && nickname.isNotEmpty) {
      return User(nickname: nickname, hasNickname: true);
    }
    return User(nickname: '', hasNickname: false);
  }

  @override
  Future<bool> setNickname(String nickname) async {
    return await _prefs.setString(_nicknameKey, nickname);
  }

  @override
  Future<bool> clearNickname() async {
    return await _prefs.remove(_nicknameKey);
  }
}
