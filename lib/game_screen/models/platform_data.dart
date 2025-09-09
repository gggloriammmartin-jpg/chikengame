import 'package:chiken_odyssey/game_screen/models/block_type.dart';

class PlatformData {
  final String id;
  final double x;
  final double y;
  final BlockType type;
  final bool isCracked;
  final double moveDirection;
  final double moveSpeed;

  PlatformData({
    required this.id,
    required this.x,
    required this.y,
    required this.type,
    this.isCracked = false,
    this.moveDirection = 0.0,
    this.moveSpeed = 0.0,
  });

  PlatformData copyWith({
    String? id,
    double? x,
    double? y,
    BlockType? type,
    bool? isCracked,
    double? moveDirection,
    double? moveSpeed,
  }) {
    return PlatformData(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      isCracked: isCracked ?? this.isCracked,
      moveDirection: moveDirection ?? this.moveDirection,
      moveSpeed: moveSpeed ?? this.moveSpeed,
    );
  }
}