import 'package:flutter/material.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

enum ChickenState {
  idle,
  idleRight,
  jump,
  jumpRight,
  falling,
  fallingRight,
}

class ChickenWidget extends StatefulWidget {
  final ChickenState state;
  final double x;
  final double y;
  final double width;
  final double height;

  const ChickenWidget({
    super.key,
    required this.state,
    required this.x,
    required this.y,
    this.width = 95.0,
    this.height = 95.0,
  });

  @override
  State<ChickenWidget> createState() => _ChickenWidgetState();
}

class _ChickenWidgetState extends State<ChickenWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.x,
      top: widget.y,
      child: Image.asset(
        _getChickenImage(),
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
      ),
    );
  }

  String _getChickenImage() {
    switch (widget.state) {
      case ChickenState.idle:
        return ImageSource.chickenIdle;
      case ChickenState.idleRight:
        return ImageSource.chickenIdleRight;
      case ChickenState.jump:
        return ImageSource.chickenJump;
      case ChickenState.jumpRight:
        return ImageSource.chickenJumpRight;
      case ChickenState.falling:
        return ImageSource.chickenFalling;
      case ChickenState.fallingRight:
        return ImageSource.chickenFallingRight;
    }
  }
}
