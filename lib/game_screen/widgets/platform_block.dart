import 'package:chiken_odyssey/game_screen/models/block_type.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

class PlatformBlock extends StatelessWidget {
  final BlockType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final bool isCracking;
  final double crackProgress; // От 0.0 до 1.0

  const PlatformBlock({
    super.key,
    required this.type,
    required this.x,
    required this.y,
    this.width = 100.0,
    this.height = 20.0,
    this.isCracking = false,
    this.crackProgress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Stack(
        children: [
          // Основное изображение платформы
          Image.asset(
            _getBlockImage(),
            width: width,
            height: height,
            fit: BoxFit.cover,
          ),
          // Индикатор трескания (красная полоска)
          if (isCracking && type == BlockType.cracking)
            Positioned(
              left: 0,
              top: height * (1 - crackProgress),
              child: Container(
                width: width,
                height: height * crackProgress,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getBlockImage() {
    switch (type) {
      case BlockType.normal:
        return ImageSource.normalBlock;
      case BlockType.cracking:
        return ImageSource.brockBlock; // Используем brock для трескающихся
      case BlockType.moving:
        return ImageSource.balkaBlock; // Используем balka для двигающихся
    }
  }
}
