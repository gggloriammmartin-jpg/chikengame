import 'package:flutter/material.dart';

class AnimatedTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final double scaleFactor;

  const AnimatedTap({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 100),
    this.scaleFactor = 0.9,
  });

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(_) {
    setState(() => _scale = widget.scaleFactor);
  }

  void _onTapUp(_) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  void _handleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        child: widget.child,
      ),
    );
  }
}
