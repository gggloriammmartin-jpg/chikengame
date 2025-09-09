import 'package:flutter/material.dart';

class AnimatedNumber extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Color? highlightColor;
  final bool showHighlight;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.highlightColor,
    this.showHighlight = true,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _previousValue = widget.value;

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.value != oldWidget.value) {
      _previousValue = _currentValue;
      _currentValue = widget.value;
      _controller.forward(from: 0.0);
    }
  }

  Color _getAnimatedColor() {
    if (!widget.showHighlight || widget.highlightColor == null) {
      return widget.style?.color ?? Colors.black;
    }
    
    // Создаем цветовую анимацию от обычного цвета к highlight цвету и обратно
    final progress = _animation.value;
    final baseColor = widget.style?.color ?? Colors.black;
    final highlightColor = widget.highlightColor!;
    
    if (progress < 0.5) {
      // Переход к highlight цвету
      return Color.lerp(baseColor, highlightColor, progress * 2) ?? baseColor;
    } else {
      // Возврат к обычному цвету
      return Color.lerp(highlightColor, baseColor, (progress - 0.5) * 2) ?? baseColor;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Создаем эффект "вылетания" старого числа и "влетания" нового
        final oldOpacity = 1.0 - _animation.value;
        final newOpacity = _animation.value;
        
        // Эффект масштабирования с пульсацией
        final oldScale = 1.0 - (_animation.value * 0.3);
        final newScale = 0.7 + (_animation.value * 0.3) + (0.1 * (1.0 - _animation.value));
        
        // Эффект смещения
        final oldOffset = _animation.value * 20.0;
        final newOffset = (1.0 - _animation.value) * -20.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Старое число (исчезает)
            Transform.translate(
              offset: Offset(0, oldOffset),
              child: Transform.scale(
                scale: oldScale,
                child: Opacity(
                  opacity: oldOpacity,
                  child: Text(
                    '$_previousValue',
                    style: widget.style,
                  ),
                ),
              ),
            ),
            // Новое число (появляется)
            Transform.translate(
              offset: Offset(0, newOffset),
              child: Transform.scale(
                scale: newScale,
                child: Opacity(
                  opacity: newOpacity,
                  child: Text(
                    '$_currentValue',
                    style: widget.style?.copyWith(color: _getAnimatedColor()),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
