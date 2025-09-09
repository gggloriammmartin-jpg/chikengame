enum BonusType {
  goldenEgg,
  shield,
  life,
}




class BonusData {
  final double x;
  final double y;
  final BonusType type;
  final bool isCollected;

  BonusData({
    required this.x,
    required this.y,
    required this.type,
    this.isCollected = false,
  });

  BonusData copyWith({
    double? x,
    double? y,
    BonusType? type,
    bool? isCollected,
  }) {
    return BonusData(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      isCollected: isCollected ?? this.isCollected,
    );
  }
}