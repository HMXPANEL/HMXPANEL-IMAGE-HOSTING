import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/premium_extensions.dart';
import '../utils/responsive.dart';

extension ThemeContext on BuildContext {
  GlassThemeExtension get glass => Theme.of(this).extension<GlassThemeExtension>()!;
  AuroraThemeExtension get aurora => Theme.of(this).extension<AuroraThemeExtension>()!;
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? blur;
  final dynamic gradient;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? elevation;
  final Color? borderColor;
  final bool animateOnAppear;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.gradient,
    this.onTap,
    this.onLongPress,
    this.elevation,
    this.borderColor,
    this.animateOnAppear = true,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final radius = borderRadius ?? 20;

    Widget card = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: gradient is Gradient ? gradient : null,
        color: gradient is Color ? gradient : (gradient != null ? null : g.glassSurface),
        border: Border.all(
          color: borderColor ?? g.glassBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: g.glassShadow,
            blurRadius: blur ?? g.glassBlur,
            spreadRadius: -1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: g.glassShadowStrong,
            blurRadius: (blur ?? g.glassBlur) * 0.5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            if (gradient == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [g.glassHighlight, Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding ?? EdgeInsets.all(ResponsiveUtils.isSmall(context) ? 16 : 20),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(radius),
          splashColor: context.glass.glassHighlight,
          highlightColor: Colors.transparent,
          child: card,
        ),
      );
    }

    if (animateOnAppear) {
      card = card.animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).scaleXY(
        begin: 0.97,
        end: 1.0,
        duration: 400.ms,
        curve: Curves.easeOut,
      );
    }

    return card;
  }
}

class GlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;
  final double? borderRadius;
  final double fontSize;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
    this.borderRadius,
    this.fontSize = 15,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: 150.ms,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final a = context.aurora;
    final radius = widget.borderRadius ?? 16;

    Widget button = AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? (_) => _controller.forward() : null,
        onTapUp: widget.onPressed != null ? (_) => _controller.reverse() : null,
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: Container(
          width: widget.expanded ? double.infinity : null,
          padding: widget.padding ??
              EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.isSmall(context) ? 20 : 24,
                vertical: ResponsiveUtils.isSmall(context) ? 14 : 16,
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: widget.gradient ?? a.accentGlow,
            border: Border.all(
              color: widget.borderColor ?? g.glassBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: a.electricBlue.withAlpha(60),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: g.glassShadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.foregroundColor ?? Colors.white,
                  ),
                )
              else ...[
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20, color: widget.foregroundColor ?? Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w600,
                    color: widget.foregroundColor ?? Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ],
          ),
        ),
      ),
    );

    return button.animate().fadeIn(duration: 300.ms);
  }
}

class GlassFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double? size;

  const GlassFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add_rounded,
    this.size,
  });

  @override
  State<GlassFAB> createState() => _GlassFABState();
}

class _GlassFABState extends State<GlassFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: 200.ms,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aurora;
    final g = context.glass;
    final size = widget.size ?? 60;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: a.accentGlow,
            boxShadow: [
              BoxShadow(
                color: a.electricBlue.withAlpha(80),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: g.glassShadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: size * 0.45),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).shake(duration: 400.ms, hz: 0.5);
  }
}

class GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final a = context.aurora;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad > 0 ? bottomPad : 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: ResponsiveUtils.bottomNavWidth(context),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              colors: [
                g.glassSurface.withAlpha(240),
                g.glassSurfaceVariant.withAlpha(220),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: g.glassBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: g.glassShadowStrong,
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: g.glassShadow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final selected = i == selectedIndex;
                return Expanded(
                  child: _GlassNavItemWidget(
                    item: item,
                    selected: selected,
                    onTap: () {
                      onTap(i);
                      HapticFeedback.selectionClick();
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const GlassNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class _GlassNavItemWidget extends StatelessWidget {
  final GlassNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _GlassNavItemWidget({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aurora;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 20 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: selected ? a.accentGlow : null,
            color: selected ? null : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? item.selectedIcon : item.icon,
                size: 20,
                color: selected ? Colors.white : context.glass.glassBorderStrong,
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GlassStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient? gradient;
  final Color? iconColor;
  final Widget? trailing;

  const GlassStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.gradient,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final cs = Theme.of(context).colorScheme;
    final a = context.aurora;
    final gradient = this.gradient ?? a.primaryAurora;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      gradient: g.glassSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  State<GlassChip> createState() => _GlassChipState();
}

class _GlassChipState extends State<GlassChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: 100.ms, vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final a = context.aurora;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: widget.selected ? a.accentGlow : null,
            color: widget.selected ? null : g.glassSurface,
            border: Border.all(
              color: widget.selected ? Colors.transparent : g.glassBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 16,
                  color: widget.selected ? Colors.white : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.selected ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;

  const GlassBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final actualColor = color ?? context.aurora.electricBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [actualColor.withAlpha(30), actualColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: actualColor.withAlpha(50), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: actualColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: actualColor,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const GlassSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class GlassProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Gradient? gradient;
  final bool animate;

  const GlassProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.gradient,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final a = context.aurora;

    Widget bar = ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: g.glassSurfaceVariant,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              gradient: gradient ?? a.accentGlow,
            ),
          ).animate(
            target: value,
            autoPlay: animate,
          ).shimmer(duration: 2000.ms, color: Colors.white.withAlpha(40)).custom(
            builder: (ctx, val, _) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: val,
            ),
          ),
        ],
      ),
    );

    return bar;
  }
}

class GlassDivider extends StatelessWidget {
  final double thickness;
  final double? indent;
  final double? endIndent;

  const GlassDivider({
    super.key,
    this.thickness = 0.5,
    this.indent,
    this.endIndent,
  });

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    return Padding(
      padding: EdgeInsets.only(left: indent ?? 0, right: endIndent ?? 0),
      child: Container(
        height: thickness,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [g.glassBorder, g.glassBorder.withAlpha(0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

class GlassLoading extends StatelessWidget {
  final double size;

  const GlassLoading({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final a = context.aurora;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: a.accentGlow,
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.7,
          height: size * 0.7,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().rotate(duration: 1000.ms);
  }
}

class GlassEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Gradient? iconGradient;

  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    final a = context.aurora;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: iconGradient ?? a.primaryAurora,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: a.electricBlue.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: Colors.white),
            ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.8, end: 1.0),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class GlassSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final a = context.aurora;
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 100,
        left: ResponsiveUtils.padding(context).left,
        right: ResponsiveUtils.padding(context).right,
        child: Material(
          color: Colors.transparent,
          child: _GlassSnackBarWidget(
            message: message,
            isError: isError,
            icon: icon,
            actionLabel: actionLabel,
            onAction: onAction,
            gradient: isError ? a.errorGlow : null,
            onDismiss: () => entry.remove(),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(3.seconds, () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _GlassSnackBarWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Gradient? gradient;
  final VoidCallback onDismiss;

  const _GlassSnackBarWidget({
    required this.message,
    required this.isError,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.gradient,
    required this.onDismiss,
  });

  @override
  State<_GlassSnackBarWidget> createState() => _GlassSnackBarWidgetState();
}

class _GlassSnackBarWidgetState extends State<_GlassSnackBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: 300.ms, vsync: this);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.glass;
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: widget.gradient != null ? null : g.glassSurface,
            gradient: widget.gradient,
            border: Border.all(color: g.glassBorder, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: g.glassShadowStrong,
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: cs.onSurface),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.actionLabel != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    widget.onAction?.call();
                    widget.onDismiss();
                  },
                  child: Text(
                    widget.actionLabel!,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}