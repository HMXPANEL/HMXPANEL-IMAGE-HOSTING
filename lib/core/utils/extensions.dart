import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isSmallScreen => screenSize.width < 600;
  bool get isMediumScreen => screenSize.width >= 600 && screenSize.width < 900;
  bool get isLargeScreen => screenSize.width >= 900;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension StringX on String {
  bool get isValidEmail {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(this);
  }

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get maskApiKey {
    if (length <= 8) return '••••••••';
    return '••••••••${substring(length - 4)}';
  }
}

extension DateTimeX on DateTime {
  bool get isExpired => DateTime.now().isAfter(this);

  Duration get remaining => difference(DateTime.now());
}
