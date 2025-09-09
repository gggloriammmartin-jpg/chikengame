import 'package:chiken_odyssey/game_screen/models/bonus_data.dart';
import 'package:flutter/material.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

class BonusWidget extends StatelessWidget {
  final BonusType type;
  final double x;
  final double y;
  final double width;
  final double height;

  const BonusWidget({
    super.key,
    required this.type,
    required this.x,
    required this.y,
    this.width = 40.0,
    this.height = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Image.asset(
        _getBonusImage(),
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }

  String _getBonusImage() {
    switch (type) {
      case BonusType.goldenEgg:
        return ImageSource.goldEgg; // 'assets/png/shit.png' - золотое яйцо
      case BonusType.shield:
        return ImageSource.shit; // 'assets/png/gold_egg.png' - щит
      case BonusType.life:
        return ImageSource.anh; // 'assets/png/anh.png' - жизнь
    }
  }
}
