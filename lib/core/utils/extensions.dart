import 'package:flutter/material.dart';
import 'responsive.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isDark => theme.brightness == Brightness.dark;

  bool get isSmall => ResponsiveUtils.isSmall(this);
  bool get isMedium => ResponsiveUtils.isMedium(this);
  bool get isLarge => ResponsiveUtils.isLarge(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  EdgeInsets get responsivePadding => ResponsiveUtils.padding(this);
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

extension FileNameX on String {
  String get fileName => split('/').last;
}