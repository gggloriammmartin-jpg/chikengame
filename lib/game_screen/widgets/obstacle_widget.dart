import 'package:chiken_odyssey/game_screen/models/obstacle_data.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

class ObstacleWidget extends StatelessWidget {
  final ObstacleData obstacle;
  final double cameraY;

  const ObstacleWidget({
    super.key,
    required this.obstacle,
    required this.cameraY,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: obstacle.x,
      top: obstacle.y - cameraY,
      child: Stack(
        children: [
          // Основное изображение препятствия (всегда показываем, но с разной прозрачностью)
          _buildObstacleImage(),

          // Тень для падающих камней
          if (obstacle.isActive && obstacle.type == ObstacleType.fallingRock)
            _buildFallingRockShadow(),
        ],
      ),
    );
  }

  Widget _buildObstacleImage() {
    final opacity = obstacle.isActive ? 1.0 : 0.3;
    
    Widget imageWidget;
    switch (obstacle.type) {
      case ObstacleType.fallingRock:
        // Используем изображение блока для падающего камня
        imageWidget = Image.asset(
          ImageSource.brockBlock,
          width: 40, // GameWorld.fallingRockSize
          height: 40,
          fit: BoxFit.cover,
        );
        break;
      case ObstacleType.spearTrap:
        // Создаем копье из балки
        imageWidget = Transform.rotate(
          angle: 0, // Горизонтальное копье
          child: Image.asset(
            ImageSource.balkaBlock,
            width: 60, // GameWorld.spearWidth
            height: 8, // GameWorld.spearHeight
            fit: BoxFit.cover,
          ),
        );
        break;
      case ObstacleType.pendulumSpear:
        // Создаем маятниковое копье из балки
        imageWidget = Transform.rotate(
          angle: 0, // Горизонтальное копье
          child: Image.asset(
            ImageSource.balkaBlock,
            width: 60, // GameWorld.spearWidth
            height: 8, // GameWorld.spearHeight
            fit: BoxFit.cover,
          ),
        );
        break;
    }
    
    return Opacity(
      opacity: opacity,
      child: imageWidget,
    );
  }

  Widget _buildFallingRockShadow() {
    // Создаем тень под падающим камнем
    return Positioned(
      left: 2,
      top: 40, // GameWorld.fallingRockSize
      child: Container(
        width: 36, // Немного меньше камня
        height: 8,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
