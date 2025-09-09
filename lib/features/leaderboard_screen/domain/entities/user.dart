class User {
  final String nickname;
  final bool hasNickname;

  const User({
    required this.nickname,
    required this.hasNickname,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.nickname == nickname &&
        other.hasNickname == hasNickname;
  }

  @override
  int get hashCode {
    return nickname.hashCode ^ hasNickname.hashCode;
  }

  @override
  String toString() {
    return 'User(nickname: $nickname, hasNickname: $hasNickname)';
  }
}
