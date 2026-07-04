import 'package:flutter/material.dart';

enum DeviceType { smallPhone, largePhone, tablet, desktop }

class AppBreakpoints {
  AppBreakpoints._();
  static const double smallPhone = 375;
  static const double largePhone = 430;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1440;
}

class AppSpacing {
  AppSpacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double grid = 12;
  static const double navGap = 8;
}

class AppRadius {
  AppRadius._();
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double pill = 100;
  static const double card = xxl;
  static const double button = xl;
  static const double input = lg;
  static const double chip = pill;
  static const double iconBg = md;
}

class AppAnimations {
  AppAnimations._();
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration spring = Duration(milliseconds: 400);
  static const Duration pageIn = Duration(milliseconds: 500);
}

class ResponsiveUtils {
  static DeviceType deviceType(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= AppBreakpoints.desktop) return DeviceType.desktop;
    if (w >= AppBreakpoints.tablet) return DeviceType.tablet;
    if (w >= AppBreakpoints.largePhone) return DeviceType.largePhone;
    return DeviceType.smallPhone;
  }

  static bool isSmallPhone(BuildContext context) =>
      deviceType(context) == DeviceType.smallPhone;

  static bool isLargePhone(BuildContext context) =>
      deviceType(context) == DeviceType.largePhone;

  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < AppBreakpoints.tablet;

  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.tablet &&
      MediaQuery.of(context).size.width < AppBreakpoints.desktop;

  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets padding(BuildContext context) {
    final w = screenWidth(context);
    if (w >= AppBreakpoints.wide) return const EdgeInsets.symmetric(horizontal: 64);
    if (w >= AppBreakpoints.desktop) return const EdgeInsets.symmetric(horizontal: 48);
    if (w >= AppBreakpoints.tablet) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  static int gridColumnCount(BuildContext context) {
    final w = screenWidth(context);
    if (w >= AppBreakpoints.wide) return 5;
    if (w >= AppBreakpoints.desktop) return 4;
    if (w >= AppBreakpoints.tablet) return 3;
    return 2;
  }

  static double bottomNavHeight(BuildContext context) {
    return kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 8;
  }

  static double bottomNavWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return double.infinity;
  }

  static double scaleFactor(BuildContext context) {
    final w = screenWidth(context);
    if (w >= AppBreakpoints.desktop) return 1.15;
    if (w >= AppBreakpoints.tablet) return 1.1;
    return 1.0;
  }

  static double imageCardAspectRatio(BuildContext context) {
    final cols = gridColumnCount(context);
    final p = padding(context);
    final hPad = p.left + p.right;
    final avail = screenWidth(context) - hPad;
    const spacing = AppSpacing.grid;
    final w = (avail - (cols - 1) * spacing) / cols;
    const imageAspect = 1.18;
    final sf = scaleFactor(context);
    final isSm = isSmall(context);
    final pad = isSm ? 6.0 : 8.0;
    const metaH = 16.0;
    const badgeH = 14.0;
    final textH = (isSm ? 11.0 : 12.0) * sf;
    final overhead = pad * 2 + textH + metaH + badgeH;
    final totalH = w / imageAspect + overhead;
    return (w / totalH).clamp(0.7, 1.0);
  }
}

class ResponsiveValues {
  final BuildContext context;
  ResponsiveValues(this.context);

  DeviceType get deviceType => ResponsiveUtils.deviceType(context);
  double get width => ResponsiveUtils.screenWidth(context);
  double get height => ResponsiveUtils.screenHeight(context);
  bool get isLandscape => ResponsiveUtils.isLandscape(context);
  bool get isTablet => ResponsiveUtils.isTablet(context);
  bool get isDesktop => ResponsiveUtils.isDesktop(context);
  double get scale => ResponsiveUtils.scaleFactor(context);

  EdgeInsets get padding => ResponsiveUtils.padding(context);
  double get horizontalPadding => padding.left + padding.right;

  int get gridColumns => ResponsiveUtils.gridColumnCount(context);
  double get gridSpacing => AppSpacing.grid;
  double get bottomNavHeight => ResponsiveUtils.bottomNavHeight(context);
  double get bottomNavWidth => ResponsiveUtils.bottomNavWidth(context);

  double get imageCardAspectRatio => ResponsiveUtils.imageCardAspectRatio(context);

  double get iconSm => AppSpacing.sm;
  double get iconMd => AppSpacing.md * 0.75;
  double get iconLg => AppSpacing.md;

  double get fabSize => isTablet ? 64 : 56;

  double get radiusXs => AppRadius.xs;
  double get radiusSm => AppRadius.sm;
  double get radiusMd => AppRadius.md;
  double get radiusLg => AppRadius.lg;
  double get radiusXl => AppRadius.xl;
  double get radiusCard => AppRadius.card;
  double get radiusButton => AppRadius.button;

  double get spacingXs => AppSpacing.xs;
  double get spacingSm => AppSpacing.sm;
  double get spacingMd => AppSpacing.md;
  double get spacingLg => AppSpacing.lg;
  double get spacingXl => AppSpacing.xl;
  double get spacingXxl => AppSpacing.xxl;

  EdgeInsets get edgeXs => EdgeInsets.all(AppSpacing.xs);
  EdgeInsets get edgeSm => EdgeInsets.all(AppSpacing.sm);
  EdgeInsets get edgeMd => EdgeInsets.all(AppSpacing.md);
  EdgeInsets get edgeLg => EdgeInsets.all(AppSpacing.lg);

  EdgeInsets get horizontalEdge => padding;

  double get cardPaddingVal => ResponsiveUtils.isSmall(context) ? AppSpacing.md : AppSpacing.lg - 4;
  EdgeInsets get cardPadding => EdgeInsets.all(cardPaddingVal);

  double get inputPaddingH => AppSpacing.lg - 6;
  double get inputPaddingV => AppSpacing.md;
  EdgeInsets get inputPadding => EdgeInsets.symmetric(horizontal: inputPaddingH, vertical: inputPaddingV);
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
    if (ResponsiveUtils.isLarge(context) && large != null) return large!(context);
    if (ResponsiveUtils.isMedium(context) && medium != null) return medium!(context);
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
    this.spacing = AppSpacing.grid,
    this.runSpacing = AppSpacing.grid,
    this.childAspectRatio,
    this.shrinkWrap = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.gridColumnCount(context);
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio ?? ResponsiveUtils.imageCardAspectRatio(context),
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
