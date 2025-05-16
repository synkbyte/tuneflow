import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';

class LikeAnimation extends StatefulWidget {
  const LikeAnimation({super.key, required this.position});
  final Offset position;

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 50,
      top: widget.position.dy - 50,
      child: CustomPaint(
        size: const Size(70, 70),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            Icons.favorite,
            size: 70,
            color: context.scheme.primary,
            shadows: [
              Shadow(
                blurRadius: 30,
                color: context.scheme.error,
                offset: const Offset(5, -5),
              ),
              Shadow(
                blurRadius: 60,
                color: context.scheme.error,
                offset: const Offset(-5, 5),
              ),
              Shadow(
                blurRadius: 90,
                color: context.scheme.onPrimary,
                offset: const Offset(-5, -5),
              ),
              Shadow(
                blurRadius: 120,
                color: context.scheme.onPrimary,
                offset: const Offset(5, 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
