import 'package:flutter/material.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

class AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedBackground({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final offset = animation.value * screenHeight;
        
        return Positioned.fill(
          child: Stack(
            children: [
              // Первый слой фона
              Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  height: screenHeight * 2,
                  width: screenWidth,
                  child: Image.asset(
                    ImageSource.wallBg,
                    fit: BoxFit.cover,
                    width: screenWidth,
                    height: screenHeight * 2,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              // Второй слой фона для бесшовности
              Transform.translate(
                offset: Offset(0, offset + screenHeight),
                child: Container(
                  height: screenHeight * 2,
                  width: screenWidth,
                  child: Image.asset(
                    ImageSource.wallBg,
                    fit: BoxFit.cover,
                    width: screenWidth,
                    height: screenHeight * 2,
                    repeat: ImageRepeat.repeat,
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
