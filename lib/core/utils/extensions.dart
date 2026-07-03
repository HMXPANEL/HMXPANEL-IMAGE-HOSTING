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

}

extension DateTimeX on DateTime {
  bool get isExpired => DateTime.now().isAfter(this);
}