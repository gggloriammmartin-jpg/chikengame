import 'package:flutter/material.dart';

class DebugLayer extends StatelessWidget {
  final double chickenX;
  final double chickenY;
  final double cameraY;
  final double chickenSize;
  final double chickenCollisionWidth;
  final double chickenCollisionHeight;

  const DebugLayer({
    super.key,
    required this.chickenX,
    required this.chickenY,
    required this.cameraY,
    required this.chickenSize,
    required this.chickenCollisionWidth,
    required this.chickenCollisionHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: chickenX + (chickenSize - chickenCollisionWidth) / 2,
      top: (chickenY + (chickenSize - chickenCollisionHeight) / 2) - cameraY,
      child: Container(
        width: chickenCollisionWidth,
        height: chickenCollisionHeight,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
          color: Colors.red.withOpacity(0.1),
        ),
      ),
    );
  }
}
