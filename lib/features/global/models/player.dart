class Player {
  final String nickname;
  final int score;

  Player({
    required this.nickname,
    required this.score,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      nickname: map['nickname'] ?? '',
      score: map['score'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'score': score,
    };
  }

  Player copyWith({
    String? nickname,
    int? score,
  }) {
    return Player(
      nickname: nickname ?? this.nickname,
      score: score ?? this.score,
    );
  }
}
