import 'package:chiken_odyssey/constants/image_source.dart';
import 'package:chiken_odyssey/features/global/widgets/animated_tap.dart';
import 'package:chiken_odyssey/theme/app_colors.dart';
import 'package:chiken_odyssey/theme/app_styles.dart';
import 'package:chiken_odyssey/game_screen/widgets/animated_number.dart';
import 'package:flutter/material.dart';

class GameAppBar extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onPause;
  final bool isPaused;
  final int score;
  final int lives;
  final bool hasShield;

  const GameAppBar({
    super.key,
    this.onBack,
    this.onPause,
    this.isPaused = false,
    required this.score,
    required this.lives,
    required this.hasShield,
  });

  @override
  State<GameAppBar> createState() => _GameAppBarState();
}

class _GameAppBarState extends State<GameAppBar> with TickerProviderStateMixin {
  late AnimationController _shieldAnimationController;
  late Animation<double> _shieldAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация для индикатора щита
    _shieldAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shieldAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _shieldAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Запускаем анимацию если щит активен
    if (widget.hasShield) {
      _shieldAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GameAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Управляем анимацией в зависимости от состояния щита
    if (widget.hasShield && !oldWidget.hasShield) {
      // Щит появился - запускаем анимацию
      _shieldAnimationController.repeat(reverse: true);
    } else if (!widget.hasShield && oldWidget.hasShield) {
      // Щит исчез - останавливаем анимацию
      _shieldAnimationController.stop();
    }

    // Принудительно обновляем UI при изменении данных
    if (widget.score != oldWidget.score ||
        widget.lives != oldWidget.lives ||
        widget.hasShield != oldWidget.hasShield) {
      setState(() {
        // Данные обновлены, перерисовываем виджет
      });
    }
  }

  @override
  void dispose() {
    _shieldAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15,
        right: 15,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Кнопка паузы с анимацией
          AnimatedTap(
            onTap: () {
              widget.onPause?.call();
            },
            child: ContainerButton(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: Image.asset(ImageSource.pause, height: 40),
            ),
          ),

          // Кнопка жизней с анимацией
          AnimatedTap(
            onTap: () {
              // Здесь можно добавить функционал для жизней
            },
            child: ContainerButton(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ImageSource.heart, height: 35),
                  const SizedBox(width: 12),
                  AnimatedNumber(
                    value: widget.lives,
                    style: AppStyles.poppins32s500w,
                    duration: const Duration(milliseconds: 400),
                    highlightColor: Colors.red,
                    showHighlight: true,
                  ),
                ],
              ),
            ),
          ),

          // Кнопка счета с анимацией
          AnimatedTap(
            onTap: () {
              // Здесь можно добавить функционал для счета
            },
            child: ContainerButton(
              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ImageSource.star, height: 35),
                  const SizedBox(width: 12),
                  AnimatedNumber(
                    value: widget.score,
                    style: AppStyles.poppins32s500w,
                    duration: const Duration(milliseconds: 200),
                    highlightColor: AppColors.whiteColor,
                    showHighlight: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContainerButton extends StatelessWidget {
  const ContainerButton({
    super.key,
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.gameOverAlertColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
