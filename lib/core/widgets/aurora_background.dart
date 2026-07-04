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
    final a = context.aurora;

    return Stack(
      children: [
        SizedBox.expand(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) {
                final v = _controller.value;
                return CustomPaint(
                  painter: _AuroraScenePainter(
                    v: v,
                    blue: a.electricBlue,
                    purple: a.electricPurple,
                    pink: a.electricPink,
                    cyan: a.electricCyan,
                    blur: widget.blur,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: cs.surface.withAlpha((255 * widget.opacity).round()),
          ),
        ),
        RepaintBoundary(child: widget.child),
      ],
    );
  }
}

class _AuroraScenePainter extends CustomPainter {
  final double v;
  final Color blue;
  final Color purple;
  final Color pink;
  final Color cyan;
  final double blur;

  _AuroraScenePainter({
    required this.v,
    required this.blue,
    required this.purple,
    required this.pink,
    required this.cyan,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintOrb(canvas, size, blue.withAlpha(80), v, 0.0, 0.7, 300);
    _paintOrb(canvas, size, purple.withAlpha(60), v, 0.5, 0.8, 250);
    _paintOrb(canvas, size, pink.withAlpha(50), v, 0.3, 0.6, 200);
    _paintOrb(canvas, size, cyan.withAlpha(50), v, 0.9, 0.4, 280);
  }

  void _paintOrb(Canvas canvas, Size canvasSize, Color color, double v,
      double phase1, double phase2, double orbSize) {
    final center = Offset(
      canvasSize.width * (math.sin(v * math.pi * 2 * phase1) * 0.3 + 0.5),
      canvasSize.height * (math.cos(v * math.pi * 2 * phase2) * 0.3 + 0.5),
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha(200),
          color.withAlpha(120),
          color.withAlpha(40),
          color.withAlpha(0),
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: orbSize));

    canvas.drawCircle(center, orbSize, paint);
  }

  @override
  bool shouldRepaint(_AuroraScenePainter old) => old.v != v;
}
