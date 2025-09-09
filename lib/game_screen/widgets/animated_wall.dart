import 'package:flutter/material.dart';

class AnimatedWall extends StatelessWidget {
  final Animation<double> animation;
  final String imagePath;
  final double width;
  final Alignment alignment;

  const AnimatedWall({
    super.key,
    required this.animation,
    required this.imagePath,
    required this.width,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final offset = animation.value * screenHeight;
        
        return Positioned(
          left: alignment == Alignment.centerLeft ? 0 : null,
          right: alignment == Alignment.centerRight ? 0 : null,
          top: 0,
          bottom: 0,
          child: Stack(
            children: [
              // Первая стенка
              Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  width: width,
                  height: screenHeight * 2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      repeat: ImageRepeat.repeatY,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              // Вторая стенка для бесшовности
              Transform.translate(
                offset: Offset(0, offset - screenHeight),
                child: Container(
                  width: width,
                  height: screenHeight * 2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      repeat: ImageRepeat.repeatY,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
