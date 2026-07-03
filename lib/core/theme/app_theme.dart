import 'package:flutter/material.dart';
import 'premium_extensions.dart';

class AppTheme {
  AppTheme._();

  static const _borderRadius = BorderRadius.all(Radius.circular(16));
  static const _primaryBg = Color(0xFF070B17);
  static const _surfaceDark = Color(0xFF0F172A);
  static const _cardDark = Color(0xFF1E293B);

  static ThemeData get light => _baseTheme(Brightness.light);
  static ThemeData get dark => _baseTheme(Brightness.dark);

  static ThemeData _baseTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? _primaryBg : const Color(0xFFF8FAFC),
      extensions: [
        isDark ? GlassThemeExtension.dark : GlassThemeExtension.light,
        isDark ? AuroraThemeExtension.dark : AuroraThemeExtension.light,
      ],
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        color: isDark ? _cardDark.withAlpha(200) : Colors.white.withAlpha(220),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: isDark ? _cardDark.withAlpha(200) : Colors.white.withAlpha(220),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? _cardDark.withAlpha(128) : Colors.white.withAlpha(128),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withAlpha(140),
          fontSize: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: isDark ? _cardDark : Colors.white,
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return colorScheme.primaryContainer;
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(12),
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w800,
          fontSize: 57,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          fontSize: 45,
          letterSpacing: -1.0,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          fontSize: 36,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          fontSize: 28,
          letterSpacing: -0.25,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  static const _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF0EA5E9),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF7DD3FC),
    onPrimaryContainer: Color(0xFF0F172A),
    secondary: Color(0xFF8B5CF6),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFC4B5FD),
    onSecondaryContainer: Color(0xFF0F172A),
    tertiary: Color(0xFFEC4899),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFF9A8D4),
    onTertiaryContainer: Color(0xFF0F172A),
    error: Color(0xFFEF4444),
    onError: Colors.white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF7F1D1D),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF0F172A),
    surfaceVariant: Color(0xFFF1F5F9),
    onSurfaceVariant: Color(0xFF64748B),
    outline: Color(0xFFCBD5E1),
    outlineVariant: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFF1F5F9),
    inverseSurface: Color(0xFF0F172A),
    onInverseSurface: Color(0xFFF8FAFC),
  );

  static const _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF22D3EE),
    onPrimary: Color(0xFF070B17),
    primaryContainer: Color(0xFF155E75),
    onPrimaryContainer: Color(0xFFA5F3FC),
    secondary: Color(0xFFA855F7),
    onSecondary: Color(0xFF070B17),
    secondaryContainer: Color(0xFF581C87),
    onSecondaryContainer: Color(0xFFD8B4FE),
    tertiary: Color(0xFFF472B6),
    onTertiary: Color(0xFF070B17),
    tertiaryContainer: Color(0xFF831843),
    onTertiaryContainer: Color(0xFFF9A8D4),
    error: Color(0xFFF87171),
    onError: Color(0xFF070B17),
    errorContainer: Color(0xFF7F1D1D),
    onErrorContainer: Color(0xFFFECACA),
    surface: Color(0xFF070B17),
    onSurface: Color(0xFFF1F5F9),
    surfaceVariant: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: Color(0xFF334155),
    outlineVariant: Color(0xFF1E293B),
    surfaceContainerHighest: Color(0xFF1E293B),
    inverseSurface: Color(0xFFF1F5F9),
    onInverseSurface: Color(0xFF070B17),
  );
}