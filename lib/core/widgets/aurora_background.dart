import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'glass_components.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final bool animate;

  const AuroraBackground({
    super.key,
    required this.child,
    this.blur = 120,
    this.opacity = 0.3,
    this.animate = true,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Stack(
              children: [
                _AuroraOrb(
                  color: context.aurora.electricBlue.withAlpha(80),
                  offset: Offset(
                    math.sin(_controller.value * math.pi * 2) * 0.3 + 0.5,
                    math.cos(_controller.value * math.pi * 2 * 0.7) * 0.3 + 0.5,
                  ),
                  size: 300,
                  blur: widget.blur,
                ),
                _AuroraOrb(
                  color: context.aurora.electricPurple.withAlpha(60),
                  offset: Offset(
                    math.cos(_controller.value * math.pi * 2 * 0.5) * 0.4 + 0.5,
                    math.sin(_controller.value * math.pi * 2 * 0.8) * 0.4 + 0.5,
                  ),
                  size: 250,
                  blur: widget.blur,
                ),
                _AuroraOrb(
                  color: context.aurora.electricPink.withAlpha(50),
                  offset: Offset(
                    math.sin(_controller.value * math.pi * 2 * 0.3 + 1) * 0.35 + 0.5,
                    math.cos(_controller.value * math.pi * 2 * 0.6 + 1) * 0.35 + 0.5,
                  ),
                  size: 200,
                  blur: widget.blur,
                ),
                _AuroraOrb(
                  color: context.aurora.electricCyan.withAlpha(50),
                  offset: Offset(
                    math.cos(_controller.value * math.pi * 2 * 0.9 + 2) * 0.25 + 0.5,
                    math.sin(_controller.value * math.pi * 2 * 0.4 + 2) * 0.25 + 0.5,
                  ),
                  size: 280,
                  blur: widget.blur,
                ),
              ],
            );
          },
        ),
        Positioned.fill(
          child: Container(
            color: cs.surface.withAlpha((255 * widget.opacity).round()),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  final Color color;
  final Offset offset;
  final double size;
  final double blur;

  const _AuroraOrb({
    required this.color,
    required this.offset,
    required this.size,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _OrbPainter(
          color: color,
          offset: offset,
          size: size,
          blur: blur,
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  final Color color;
  final Offset offset;
  final double size;
  final double blur;

  _OrbPainter({
    required this.color,
    required this.offset,
    required this.size,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(
      canvasSize.width * offset.dx,
      canvasSize.height * offset.dy,
    );

    final colors = [
      color.withAlpha(180),
      color.withAlpha(100),
      color.withAlpha(30),
      color.withAlpha(0),
    ];

    final stops = [0.0, 0.3, 0.6, 1.0];

    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: stops,
      ).createShader(Rect.fromCircle(center: center, radius: size));

    canvas.drawCircle(center, size, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.color != color;
  }
}
