class LeaderboardEntry {
  final String id;
  final String nickname;
  final int score;
  final int rank;

  const LeaderboardEntry({
    required this.id,
    required this.nickname,
    required this.score,
    required this.rank,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry &&
        other.id == id &&
        other.nickname == nickname &&
        other.score == score &&
        other.rank == rank;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nickname.hashCode ^
        score.hashCode ^
        rank.hashCode;
  }

  @override
  String toString() {
    return 'LeaderboardEntry(id: $id, nickname: $nickname, score: $score, rank: $rank)';
  }
}
