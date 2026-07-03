import 'dart:math' as math;
import 'dart:ui' as ui;
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
                // Aurora orbs
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
        // Frost overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              color: cs.surface.withAlpha((255 * widget.opacity).round()),
            ),
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

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final radius = borderRadius ?? 20;

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundColor ?? g.glassSurface,
        border: Border.all(
          color: borderColor ?? g.glassBorder,
          width: 0.5,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: g.glassShadow,
            blurRadius: g.glassBlur,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: g.glassShadowStrong,
            blurRadius: g.glassBlur * 0.5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class FloatingClouds extends StatefulWidget {
  final int count;
  final double speed;

  const FloatingClouds({
    super.key,
    this.count = 3,
    this.speed = 1.0,
  });

  @override
  State<FloatingClouds> createState() => _FloatingCloudsState();
}

class _FloatingCloudsState extends State<FloatingClouds>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return CustomPaint(
          painter: _CloudPainter(
            animation: _controller.value,
            count: widget.count,
            speed: widget.speed,
            isDark: isDark,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double animation;
  final int count;
  final double speed;
  final bool isDark;

  _CloudPainter({
    required this.animation,
    required this.count,
    required this.speed,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < count; i++) {
      final y = rng.nextDouble() * size.height * 0.6;
      final cloudWidth = rng.nextDouble() * 100 + 80;
      final cloudHeight = rng.nextDouble() * 30 + 20;
      final x = ((animation * speed + i * 0.3) * (size.width + cloudWidth * 2)) %
              (size.width + cloudWidth * 2) -
          cloudWidth;

      final paint = Paint()
        ..color = (isDark ? Colors.white : Colors.black)
            .withAlpha((rng.nextDouble() * 15 + 5).round());

      final center = Offset(x, y);
      final circles = [
        Offset(-cloudWidth * 0.2, 0),
        Offset(cloudWidth * 0.2, -cloudHeight * 0.3),
        Offset(cloudWidth * 0.4, 0),
        Offset(cloudWidth * 0.6, -cloudHeight * 0.2),
        Offset(cloudWidth * 0.3, cloudHeight * 0.2),
      ];

      for (final c in circles) {
        canvas.drawCircle(
          center + c,
          cloudHeight * 0.6,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}