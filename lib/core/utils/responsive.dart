import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double small = 360;
  static const double medium = 600;
  static const double large = 900;
  static const double xlarge = 1200;
}

class ResponsiveUtils {
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < AppBreakpoints.medium;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.medium &&
      MediaQuery.of(context).size.width < AppBreakpoints.large;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.large;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.large;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets padding(BuildContext context) {
    final w = screenWidth(context);
    if (w >= AppBreakpoints.xlarge) return const EdgeInsets.symmetric(horizontal: 64);
    if (w >= AppBreakpoints.large) return const EdgeInsets.symmetric(horizontal: 48);
    if (w >= AppBreakpoints.medium) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  static double gridColumnCount(BuildContext context) {
    final w = screenWidth(context);
    if (w >= AppBreakpoints.xlarge) return 4;
    if (w >= AppBreakpoints.large) return 3;
    if (w >= AppBreakpoints.medium) return 2;
    return 2;
  }

  static EdgeInsets bottomNavPadding(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    if (isDesktop(context)) return EdgeInsets.only(bottom: bottom + 24, left: 48, right: 48);
    if (isTablet(context)) return EdgeInsets.only(bottom: bottom + 16, left: 32, right: 32);
    return EdgeInsets.only(bottom: bottom + 8, left: 16, right: 16);
  }

  static double bottomNavWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return double.infinity;
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}

class ResponsiveWidget extends StatelessWidget {
  final Widget Function(BuildContext context) small;
  final Widget Function(BuildContext context)? medium;
  final Widget Function(BuildContext context)? large;

  const ResponsiveWidget({
    super.key,
    required this.small,
    this.medium,
    this.large,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isLarge(context) && large != null) {
      return large!(context);
    }
    if (ResponsiveUtils.isMedium(context) && medium != null) {
      return medium!(context);
    }
    return small(context);
  }
}

class AdaptiveGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const AdaptiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.gridColumnCount(context).round();
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? (ResponsiveUtils.isSmall(context) ? 0.85 : 0.9),
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}