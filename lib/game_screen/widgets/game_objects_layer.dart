import 'package:chiken_odyssey/game_screen/models/bonus_data.dart';
import 'package:chiken_odyssey/game_screen/models/obstacle_data.dart';
import 'package:chiken_odyssey/game_screen/models/platform_data.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/game_screen/widgets/platform_block.dart';
import 'package:chiken_odyssey/game_screen/widgets/bonus_widget.dart';
import 'package:chiken_odyssey/game_screen/widgets/obstacle_widget.dart';

class GameObjectsLayer extends StatelessWidget {
  final List<PlatformData> platforms;
  final List<BonusData> bonuses;
  final List<ObstacleData> obstacles;
  final Map<String, int> crackingPlatforms;
  final double cameraY;

  const GameObjectsLayer({
    super.key,
    required this.platforms,
    required this.bonuses,
    required this.obstacles,
    required this.crackingPlatforms,
    required this.cameraY,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Платформы (с учетом камеры)
        ...platforms.map((platform) {
          final isCracking = crackingPlatforms.containsKey(platform.id);
          final crackProgress = isCracking
              ? (30 - crackingPlatforms[platform.id]!) / 30.0
              : 0.0;

          return PlatformBlock(
            type: platform.type,
            x: platform.x,
            y: platform.y - cameraY,
            isCracking: isCracking,
            crackProgress: crackProgress,
          );
        }),

        // Бонусы (с учетом камеры)
        ...bonuses.map(
          (bonus) => BonusWidget(
            type: bonus.type,
            x: bonus.x,
            y: bonus.y - cameraY - 10,
          ),
        ),

        // Препятствия (с учетом камеры)
        ...obstacles.map(
          (obstacle) =>
              ObstacleWidget(obstacle: obstacle, cameraY: cameraY),
        ),
      ],
    );
  }
}


