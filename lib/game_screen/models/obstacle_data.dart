enum ObstacleType {
  fallingRock,
  spearTrap,
  pendulumSpear,
}

class ObstacleData {
  final String id;
  final double x;
  final double y;
  final ObstacleType type;
  final double velocityX;
  final double velocityY;
  final bool isActive;
  final int activationTimer;
  final double startX;
  final double direction;

  ObstacleData({
    required this.id,
    required this.x,
    required this.y,
    required this.type,
    this.velocityX = 0.0,
    this.velocityY = 0.0,
    this.isActive = true,
    this.activationTimer = 0,
    this.startX = 0.0,
    this.direction = 1.0,
  });

  ObstacleData copyWith({
    String? id,
    double? x,
    double? y,
    ObstacleType? type,
    double? velocityX,
    double? velocityY,
    bool? isActive,
    int? activationTimer,
    double? startX,
    double? direction,
  }) {
    return ObstacleData(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      velocityX: velocityX ?? this.velocityX,
      velocityY: velocityY ?? this.velocityY,
      isActive: isActive ?? this.isActive,
      activationTimer: activationTimer ?? this.activationTimer,
      startX: startX ?? this.startX,
      direction: direction ?? this.direction,
    );
  }
}
