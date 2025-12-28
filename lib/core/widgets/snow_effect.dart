import 'dart:math';
import 'package:flutter/material.dart';

/// A performant snow animation widget for winter theme
class SnowEffect extends StatefulWidget {
  final int snowflakeCount;
  final Color snowColor;
  final double maxRadius;
  final double minRadius;

  const SnowEffect({
    super.key,
    this.snowflakeCount = 25,
    this.snowColor = Colors.white,
    this.maxRadius = 4.0,
    this.minRadius = 1.5,
  });

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Snowflake> _snowflakes;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _snowflakes = List.generate(
      widget.snowflakeCount,
      (_) => _createSnowflake(),
    );
  }

  Snowflake _createSnowflake() {
    return Snowflake(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      radius:
          widget.minRadius +
          _random.nextDouble() * (widget.maxRadius - widget.minRadius),
      speed: 0.2 + _random.nextDouble() * 0.5,
      drift: (_random.nextDouble() - 0.5) * 0.3,
      opacity: 0.4 + _random.nextDouble() * 0.6,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SnowPainter(
            snowflakes: _snowflakes,
            progress: _controller.value,
            color: widget.snowColor,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Individual snowflake data
class Snowflake {
  double x;
  double y;
  final double radius;
  final double speed;
  final double drift;
  final double opacity;

  Snowflake({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.drift,
    required this.opacity,
  });
}

/// Custom painter for snow effect - optimized for performance
class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final double progress;
  final Color color;

  SnowPainter({
    required this.snowflakes,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final snowflake in snowflakes) {
      // Calculate position with continuous movement
      final yOffset = (snowflake.y + progress * snowflake.speed) % 1.0;
      final xOffset =
          snowflake.x + sin(progress * 2 * pi + snowflake.drift * 10) * 0.02;

      final paint = Paint()
        ..color = color.withValues(alpha: snowflake.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset((xOffset % 1.0) * size.width, yOffset * size.height),
        snowflake.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
