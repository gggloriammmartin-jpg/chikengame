import 'dart:math';
import 'package:chiken_odyssey/game_screen/models/bonus_data.dart';
import 'package:flutter/material.dart';

class GameEffectsLayer extends StatelessWidget {
  final bool hasShield;
  final double chickenX;
  final double chickenY;
  final double cameraY;
  final double chickenSize;
  final Animation<double> shieldAnimation;
  final Animation<double> shieldAppearAnimation;
  final bool isBonusCollecting;
  final double bonusCollectX;
  final double bonusCollectY;
  final Animation<double> bonusCollectAnimation;
  final BonusType collectingBonusType;

  const GameEffectsLayer({
    super.key,
    required this.hasShield,
    required this.chickenX,
    required this.chickenY,
    required this.cameraY,
    required this.chickenSize,
    required this.shieldAnimation,
    required this.shieldAppearAnimation,
    required this.isBonusCollecting,
    required this.bonusCollectX,
    required this.bonusCollectY,
    required this.bonusCollectAnimation,
    required this.collectingBonusType,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Эффект щита вокруг курицы
        if (hasShield)
          AnimatedBuilder(
            animation: Listenable.merge([
              shieldAnimation,
              shieldAppearAnimation,
            ]),
            builder: (context, child) {
              final appearValue = shieldAppearAnimation.value;
              final pulseValue = shieldAnimation.value;

              return Positioned(
                left:
                    chickenX - 10, // Корректируем позицию для большего размера
                top: (chickenY - cameraY) - 10,
                child: Transform.scale(
                  scale: 0.95 + (0.1 * appearValue), // Масштаб от 0.95 до 1.05
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Внешний слой - основной эффект
                      Container(
                        width: chickenSize + 20,
                        height: chickenSize + 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.yellow.withOpacity(
                              0.2 * appearValue * (0.3 + 0.2 * pulseValue),
                            ),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(
                                0.15 * appearValue * pulseValue,
                              ),
                              blurRadius: 8 * appearValue * pulseValue,
                              spreadRadius: 1 * appearValue * pulseValue,
                            ),
                            BoxShadow(
                              color: Colors.amber.withOpacity(
                                0.1 * appearValue * pulseValue,
                              ),
                              blurRadius: 12 * appearValue * pulseValue,
                              spreadRadius: 2 * appearValue * pulseValue,
                            ),
                          ],
                        ),
                      ),
                      // Внутренний слой - дополнительное свечение
                      Container(
                        width: chickenSize + 10,
                        height: chickenSize + 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amber.withOpacity(
                              0.15 * appearValue * pulseValue,
                            ),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(
                                0.08 * appearValue * pulseValue,
                              ),
                              blurRadius: 6 * appearValue * pulseValue,
                              spreadRadius: 1 * appearValue * pulseValue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Анимация сбора бонусов
        if (isBonusCollecting)
          AnimatedBuilder(
            animation: bonusCollectAnimation,
            builder: (context, child) {
              final animationValue = bonusCollectAnimation.value;
              final bounceValue = Curves.elasticOut.transform(animationValue);
              
              return Stack(
                children: [
                  // Основной бонус
                  Positioned(
                    left: bonusCollectX - 20,
                    top: (bonusCollectY - cameraY) - 20 - (80 * animationValue),
                    child: Transform.scale(
                      scale: 1.0 + (0.5 * bounceValue),
                      child: Opacity(
                        opacity: 1.0 - (animationValue * 0.7),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getBonusAnimationColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getBonusAnimationColor().withOpacity(
                                  0.9 * (1.0 - animationValue),
                                ),
                                blurRadius: 15 * (1.0 - animationValue),
                                spreadRadius: 5 * (1.0 - animationValue),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(
                                  0.6 * (1.0 - animationValue),
                                ),
                                blurRadius: 8 * (1.0 - animationValue),
                                spreadRadius: 2 * (1.0 - animationValue),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getBonusAnimationIcon(),
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Частицы вокруг бонуса
                  ...List.generate(6, (index) {
                    final angle = (index * 60.0) * (3.14159 / 180.0);
                    final particleDistance = 30 * animationValue;
                    final particleX = bonusCollectX + (particleDistance * cos(angle)) - 5;
                    final particleY = (bonusCollectY - cameraY) + (particleDistance * sin(angle)) - 5;
                    
                    return Positioned(
                      left: particleX,
                      top: particleY,
                      child: Opacity(
                        opacity: (1.0 - animationValue) * 0.8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _getBonusAnimationColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getBonusAnimationColor().withOpacity(0.6),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Текст для разных типов бонусов
                  Positioned(
                    left: bonusCollectX - 15,
                    top: (bonusCollectY - cameraY) - 40 - (60 * animationValue),
                    child: Opacity(
                      opacity: 1.0 - (animationValue * 0.8),
                      child: Transform.scale(
                        scale: 1.0 + (0.3 * animationValue),
                        child: Text(
                          _getBonusText(),
                          style: TextStyle(
                            color: _getBonusAnimationColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Color _getBonusAnimationColor() {
    switch (collectingBonusType) {
      case BonusType.goldenEgg:
        return Colors.amber;
      case BonusType.shield:
        return Colors.blue;
      case BonusType.life:
        return Colors.red;
    }
  }

  IconData _getBonusAnimationIcon() {
    switch (collectingBonusType) {
      case BonusType.goldenEgg:
        return Icons.star;
      case BonusType.shield:
        return Icons.shield;
      case BonusType.life:
        return Icons.favorite;
    }
  }

  String _getBonusText() {
    switch (collectingBonusType) {
      case BonusType.goldenEgg:
        return '+50';
      case BonusType.shield:
        return 'SHIELD!';
      case BonusType.life:
        return '+1 LIFE';
    }
  }
}
