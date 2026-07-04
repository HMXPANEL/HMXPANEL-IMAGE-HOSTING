import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'glass_components.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;
  final double opacity;

  // ponytail: static scene — animating 4 gradient shaders at 60fps was the #1
  // cause of GPU stalls during route transitions. The 20s cycle barely moves
  // per frame; a static render looks identical. Re-add animation only if a
  // profiler shows the GPU has headroom after the transition fix.
  const AuroraBackground({
    super.key,
    required this.child,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final a = context.aurora;

    return Stack(
      children: [
        SizedBox.expand(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AuroraScenePainter(
                blue: a.electricBlue,
                purple: a.electricPurple,
                pink: a.electricPink,
                cyan: a.electricCyan,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: cs.surface.withAlpha((255 * opacity).round()),
          ),
        ),
        RepaintBoundary(child: child),
      ],
    );
  }
}

class _AuroraScenePainter extends CustomPainter {
  final Color blue;
  final Color purple;
  final Color pink;
  final Color cyan;

  _AuroraScenePainter({
    required this.blue,
    required this.purple,
    required this.pink,
    required this.cyan,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintOrb(canvas, size, blue.withAlpha(80), 0.0, 0.7, 300);
    _paintOrb(canvas, size, purple.withAlpha(60), 0.5, 0.8, 250);
    _paintOrb(canvas, size, pink.withAlpha(50), 0.3, 0.6, 200);
    _paintOrb(canvas, size, cyan.withAlpha(50), 0.9, 0.4, 280);
  }

  void _paintOrb(Canvas canvas, Size canvasSize, Color color,
      double phase1, double phase2, double orbSize) {
    final center = Offset(
      canvasSize.width * (math.sin(phase1 * math.pi) * 0.3 + 0.5),
      canvasSize.height * (math.cos(phase2 * math.pi) * 0.3 + 0.5),
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha(200),
          color.withAlpha(120),
          color.withAlpha(40),
          color.withAlpha(0),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: orbSize));

    canvas.drawCircle(center, orbSize, paint);
  }

  @override
  bool shouldRepaint(_AuroraScenePainter old) => false;
}
