import 'package:flutter/material.dart';

class GlassThemeExtension extends ThemeExtension<GlassThemeExtension> {
  final Color glassSurface;
  final Color glassSurfaceVariant;
  final Color glassBorder;
  final Color glassBorderStrong;
  final Color glassHighlight;
  final Color glassShadow;
  final Color glassShadowStrong;
  final double glassBlur;
  final double glassBlurStrong;
  final BorderRadius glassBorderRadius;
  final BorderRadius glassBorderRadiusSmall;
  final BorderRadius glassBorderRadiusLarge;

  const GlassThemeExtension({
    required this.glassSurface,
    required this.glassSurfaceVariant,
    required this.glassBorder,
    required this.glassBorderStrong,
    required this.glassHighlight,
    required this.glassShadow,
    required this.glassShadowStrong,
    required this.glassBlur,
    required this.glassBlurStrong,
    required this.glassBorderRadius,
    required this.glassBorderRadiusSmall,
    required this.glassBorderRadiusLarge,
  });

  @override
  GlassThemeExtension copyWith({
    Color? glassSurface,
    Color? glassSurfaceVariant,
    Color? glassBorder,
    Color? glassBorderStrong,
    Color? glassHighlight,
    Color? glassShadow,
    Color? glassShadowStrong,
    double? glassBlur,
    double? glassBlurStrong,
    BorderRadius? glassBorderRadius,
    BorderRadius? glassBorderRadiusSmall,
    BorderRadius? glassBorderRadiusLarge,
  }) {
    return GlassThemeExtension(
      glassSurface: glassSurface ?? this.glassSurface,
      glassSurfaceVariant: glassSurfaceVariant ?? this.glassSurfaceVariant,
      glassBorder: glassBorder ?? this.glassBorder,
      glassBorderStrong: glassBorderStrong ?? this.glassBorderStrong,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      glassShadow: glassShadow ?? this.glassShadow,
      glassShadowStrong: glassShadowStrong ?? this.glassShadowStrong,
      glassBlur: glassBlur ?? this.glassBlur,
      glassBlurStrong: glassBlurStrong ?? this.glassBlurStrong,
      glassBorderRadius: glassBorderRadius ?? this.glassBorderRadius,
      glassBorderRadiusSmall: glassBorderRadiusSmall ?? this.glassBorderRadiusSmall,
      glassBorderRadiusLarge: glassBorderRadiusLarge ?? this.glassBorderRadiusLarge,
    );
  }

  @override
  GlassThemeExtension lerp(ThemeExtension<GlassThemeExtension>? other, double t) {
    if (other is! GlassThemeExtension) return this;
    return GlassThemeExtension(
      glassSurface: Color.lerp(glassSurface, other.glassSurface, t)!,
      glassSurfaceVariant: Color.lerp(glassSurfaceVariant, other.glassSurfaceVariant, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassBorderStrong: Color.lerp(glassBorderStrong, other.glassBorderStrong, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      glassShadow: Color.lerp(glassShadow, other.glassShadow, t)!,
      glassShadowStrong: Color.lerp(glassShadowStrong, other.glassShadowStrong, t)!,
      glassBlur: lerpDouble(glassBlur, other.glassBlur, t)!,
      glassBlurStrong: lerpDouble(glassBlurStrong, other.glassBlurStrong, t)!,
      glassBorderRadius: BorderRadius.lerp(glassBorderRadius, other.glassBorderRadius, t)!,
      glassBorderRadiusSmall: BorderRadius.lerp(glassBorderRadiusSmall, other.glassBorderRadiusSmall, t)!,
      glassBorderRadiusLarge: BorderRadius.lerp(glassBorderRadiusLarge, other.glassBorderRadiusLarge, t)!,
    );
  }

  static GlassThemeExtension get light => const GlassThemeExtension(
    glassSurface: Color(0xCCFFFFFF),
    glassSurfaceVariant: Color(0x99FFFFFF),
    glassBorder: Color(0x33FFFFFF),
    glassBorderStrong: Color(0x66FFFFFF),
    glassHighlight: Color(0x44FFFFFF),
    glassShadow: Color(0x1A000000),
    glassShadowStrong: Color(0x33000000),
    glassBlur: 20,
    glassBlurStrong: 40,
    glassBorderRadius: BorderRadius.all(Radius.circular(20)),
    glassBorderRadiusSmall: BorderRadius.all(Radius.circular(12)),
    glassBorderRadiusLarge: BorderRadius.all(Radius.circular(28)),
  );

  static GlassThemeExtension get dark => const GlassThemeExtension(
    glassSurface: Color(0xCC0F172A),
    glassSurfaceVariant: Color(0x991E293B),
    glassBorder: Color(0x33FFFFFF),
    glassBorderStrong: Color(0x66FFFFFF),
    glassHighlight: Color(0x22FFFFFF),
    glassShadow: Color(0x4D000000),
    glassShadowStrong: Color(0x66000000),
    glassBlur: 20,
    glassBlurStrong: 40,
    glassBorderRadius: BorderRadius.all(Radius.circular(20)),
    glassBorderRadiusSmall: BorderRadius.all(Radius.circular(12)),
    glassBorderRadiusLarge: BorderRadius.all(Radius.circular(28)),
  );
}

class AuroraThemeExtension extends ThemeExtension<AuroraThemeExtension> {
  final Gradient primaryAurora;
  final Gradient secondaryAurora;
  final Gradient tertiaryAurora;
  final Gradient accentGlow;
  final Gradient successGlow;
  final Gradient warningGlow;
  final Gradient errorGlow;
  final Color electricBlue;
  final Color electricPurple;
  final Color electricPink;
  final Color electricCyan;

  const AuroraThemeExtension({
    required this.primaryAurora,
    required this.secondaryAurora,
    required this.tertiaryAurora,
    required this.accentGlow,
    required this.successGlow,
    required this.warningGlow,
    required this.errorGlow,
    required this.electricBlue,
    required this.electricPurple,
    required this.electricPink,
    required this.electricCyan,
  });

  @override
  AuroraThemeExtension copyWith({
    Gradient? primaryAurora,
    Gradient? secondaryAurora,
    Gradient? tertiaryAurora,
    Gradient? accentGlow,
    Gradient? successGlow,
    Gradient? warningGlow,
    Gradient? errorGlow,
    Color? electricBlue,
    Color? electricPurple,
    Color? electricPink,
    Color? electricCyan,
  }) {
    return AuroraThemeExtension(
      primaryAurora: primaryAurora ?? this.primaryAurora,
      secondaryAurora: secondaryAurora ?? this.secondaryAurora,
      tertiaryAurora: tertiaryAurora ?? this.tertiaryAurora,
      accentGlow: accentGlow ?? this.accentGlow,
      successGlow: successGlow ?? this.successGlow,
      warningGlow: warningGlow ?? this.warningGlow,
      errorGlow: errorGlow ?? this.errorGlow,
      electricBlue: electricBlue ?? this.electricBlue,
      electricPurple: electricPurple ?? this.electricPurple,
      electricPink: electricPink ?? this.electricPink,
      electricCyan: electricCyan ?? this.electricCyan,
    );
  }

  @override
  AuroraThemeExtension lerp(ThemeExtension<AuroraThemeExtension>? other, double t) {
    if (other is! AuroraThemeExtension) return this;
    return AuroraThemeExtension(
      primaryAurora: Gradient.lerp(primaryAurora, other.primaryAurora, t)!,
      secondaryAurora: Gradient.lerp(secondaryAurora, other.secondaryAurora, t)!,
      tertiaryAurora: Gradient.lerp(tertiaryAurora, other.tertiaryAurora, t)!,
      accentGlow: Gradient.lerp(accentGlow, other.accentGlow, t)!,
      successGlow: Gradient.lerp(successGlow, other.successGlow, t)!,
      warningGlow: Gradient.lerp(warningGlow, other.warningGlow, t)!,
      errorGlow: Gradient.lerp(errorGlow, other.errorGlow, t)!,
      electricBlue: Color.lerp(electricBlue, other.electricBlue, t)!,
      electricPurple: Color.lerp(electricPurple, other.electricPurple, t)!,
      electricPink: Color.lerp(electricPink, other.electricPink, t)!,
      electricCyan: Color.lerp(electricCyan, other.electricCyan, t)!,
    );
  }

  static AuroraThemeExtension get light => const AuroraThemeExtension(
    primaryAurora: LinearGradient(
      colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6), Color(0xFFEC4899)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    secondaryAurora: LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFFA855F7), Color(0xFFF472B6)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    tertiaryAurora: LinearGradient(
      colors: [Color(0xFF06B6D4), Color(0xFFD946EF), Color(0xFFF97316)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
    accentGlow: LinearGradient(
      colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGlow: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF34D399)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    warningGlow: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    errorGlow: LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    electricBlue: Color(0xFF0EA5E9),
    electricPurple: Color(0xFF8B5CF6),
    electricPink: Color(0xFFEC4899),
    electricCyan: Color(0xFF06B6D4),
  );

  static AuroraThemeExtension get dark => const AuroraThemeExtension(
    primaryAurora: LinearGradient(
      colors: [Color(0xFF0EA5E9), Color(0xFF8B5CF6), Color(0xFFEC4899)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    secondaryAurora: LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFFA855F7), Color(0xFFF472B6)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    tertiaryAurora: LinearGradient(
      colors: [Color(0xFF06B6D4), Color(0xFFD946EF), Color(0xFFF97316)],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
    accentGlow: LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF06B6D4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    successGlow: LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF34D399)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    warningGlow: LinearGradient(
      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    errorGlow: LinearGradient(
      colors: [Color(0xFFEF4444), Color(0xFFF87171)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    electricBlue: Color(0xFF22D3EE),
    electricPurple: Color(0xFFA855F7),
    electricPink: Color(0xFFF472B6),
    electricCyan: Color(0xFF22D3EE),
  );
}