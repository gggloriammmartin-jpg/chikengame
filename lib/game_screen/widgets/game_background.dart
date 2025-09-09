import 'package:flutter/material.dart';
import 'package:chiken_odyssey/game_screen/widgets/animated_background.dart';
import 'package:chiken_odyssey/game_screen/widgets/animated_wall.dart';
import 'package:chiken_odyssey/game_screen/widgets/game_app_bar.dart';
import 'package:chiken_odyssey/constants/image_source.dart';

class GameBackground extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Function(double deltaX)? onPanUpdate;
  final VoidCallback? onPanStart;
  final VoidCallback? onBack;
  final VoidCallback? onPause;
  final bool isPaused;
  final int score;
  final int lives;
  final bool hasShield;

  const GameBackground({
    super.key,
    required this.child,
    this.onTap,
    this.onPanUpdate,
    this.onPanStart,
    this.onBack,
    this.onPause,
    this.isPaused = false,
    required this.score,
    required this.lives,
    required this.hasShield,
  });

  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _wallController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _wallAnimation;

  @override
  void initState() {
    super.initState();

    // Контроллер для основного фона (движется вверх)
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Контроллер для стенок (движутся вниз)
    _wallController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Анимация для фона (от 0 до -1, чтобы двигаться вверх)
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: -1.0,
    ).animate(_backgroundController);

    // Анимация для стенок (от 0 до 1, чтобы двигаться вниз)
    _wallAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_wallController);

    // Запускаем анимации в бесконечном цикле только если игра не на паузе
    if (!widget.isPaused) {
      _backgroundController.repeat();
      _wallController.repeat();
    }
  }

  @override
  void didUpdateWidget(GameBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Останавливаем или возобновляем анимации в зависимости от состояния паузы
    if (widget.isPaused && !oldWidget.isPaused) {
      // Полностью останавливаем анимации
      print('GameBackground: Stopping animations (game paused)');
      _backgroundController.stop();
      _wallController.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      // Возобновляем анимации с текущей позиции
      print('GameBackground: Resuming animations (game resumed)');
      _backgroundController.repeat();
      _wallController.repeat();
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _wallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanStart: (details) {
        // Вызываем обработчик начала жеста
        if (widget.onPanStart != null) {
          widget.onPanStart!();
        }
      },
      onPanUpdate: (details) {
        if (widget.onPanUpdate != null) {
          widget.onPanUpdate!(details.delta.dx);
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Основной фон с анимацией (только если не на паузе)
            if (!widget.isPaused)
              AnimatedBackground(animation: _backgroundAnimation)
            else
              // Статичный фон во время паузы
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  ImageSource.wallBg,
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            // Левая стенка с анимацией (только если не на паузе)
            if (!widget.isPaused)
              AnimatedWall(
                animation: _wallAnimation,
                imagePath: ImageSource.wallSideLeft,
                width: 30,
                alignment: Alignment.centerLeft,
              )
            else
              // Статичная левая стенка во время паузы
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageSource.wallSideLeft),
                      repeat: ImageRepeat.repeatY,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            // Правая стенка с анимацией (только если не на паузе)
            if (!widget.isPaused)
              AnimatedWall(
                animation: _wallAnimation,
                imagePath: ImageSource.wallSideRight,
                width: 30,
                alignment: Alignment.centerRight,
              )
            else
              // Статичная правая стенка во время паузы
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageSource.wallSideRight),
                      repeat: ImageRepeat.repeatY,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            // Игровой контент
            widget.child,
            // AppBar поверх всего
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GameAppBar(
                onBack: widget.onBack,
                onPause: widget.onPause,
                isPaused: widget.isPaused,
                score: widget.score,
                lives: widget.lives,
                hasShield: widget.hasShield,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
