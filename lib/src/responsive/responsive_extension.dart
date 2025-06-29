
import 'package:flutter/material.dart';

/// Breakpoint definitions
class Breakpoints {
  static const double tiny = 412;
  static const double mobile = 576;
  static const double tablet = 768;
  static const double desktop = 992;
  static const double largeDesktop = 1200;
}

/// Device type enum
enum DeviceType { tiny, mobile, tablet, desktop, largeDesktop }

/// Extension on BuildContext for responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get current screen width
  double get width => MediaQuery.of(this).size.width;

  /// Get current screen height
  double get height => MediaQuery.of(this).size.height;

  /// Get current device type based on width
  DeviceType get deviceType {
    final width = this.width;
    if (width < Breakpoints.tiny) return DeviceType.tiny;
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    if (width < Breakpoints.desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Check if current device is tiny
  bool get isTiny => deviceType == DeviceType.tiny;
  /// Check if current device is mobile
  bool get isMobile => deviceType == DeviceType.mobile;

  /// Check if current device is tablet
  bool get isTablet => deviceType == DeviceType.tablet;

  /// Check if current device is desktop
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// Check if current device is large desktop
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;

  /// Check if screen width is at least tablet size
  bool get isTabletOrLarger => width >= Breakpoints.tablet;

  /// Check if screen width is at least desktop size
  bool get isDesktopOrLarger => width >= Breakpoints.desktop;

  /// Get responsive value based on device type
  T responsive<T>({
    T? tiny,
    T? mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
    required T defaultValue,
  }) {
    switch (deviceType) {
      case DeviceType.tiny:
        return tiny ?? defaultValue;
      case DeviceType.mobile:
        return mobile ?? defaultValue;
      case DeviceType.tablet:
        return tablet ?? mobile ?? defaultValue;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? defaultValue;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile ?? defaultValue;
    }
  }

  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  /// Check if current theme is light mode
  bool get isLightMode {
    return Theme.of(this).brightness == Brightness.light;
  }
}

/// Extension on Widget for responsive behavior
extension ResponsiveWidget on Widget {
  /// Show widget only on specific device types
  Widget showOn(BuildContext context, List<DeviceType> deviceTypes) {
    return deviceTypes.contains(context.deviceType) ? this : const SizedBox.shrink();
  }

  /// Hide widget on specific device types
  Widget hideOn(BuildContext context, List<DeviceType> deviceTypes) {
    return !deviceTypes.contains(context.deviceType) ? this : const SizedBox.shrink();
  }

  /// Show widget only on tiny
  Widget showOnTiny(BuildContext context) {
    return context.isTiny ? this : const SizedBox.shrink();
  }
  /// Show widget only on mobile
  Widget showOnMobile(BuildContext context) {
    return context.isMobile ? this : const SizedBox.shrink();
  }

  /// Show widget only on tablet and larger
  Widget showOnTabletOrLarger(BuildContext context) {
    return context.isTabletOrLarger ? this : const SizedBox.shrink();
  }

  /// Show widget only on desktop and larger
  Widget showOnDesktopOrLarger(BuildContext context) {
    return context.isDesktopOrLarger ? this : const SizedBox.shrink();
  }

  /// Hide widget on mobile
  Widget hideOnMobile(BuildContext context) {
    return !context.isMobile ? this : const SizedBox.shrink();
  }

  /// Apply responsive padding
  Widget responsivePadding(
      BuildContext context, {
        EdgeInsets? tiny,
        EdgeInsets? mobile,
        EdgeInsets? tablet,
        EdgeInsets? desktop,
        EdgeInsets? largeDesktop,
        EdgeInsets defaultPadding = const EdgeInsets.all(16),
      }) {
    final padding = context.responsive<EdgeInsets>(
      tiny: tiny,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      defaultValue: defaultPadding,
    );
    return Padding(padding: padding, child: this);
  }

  /// Apply responsive margin using Container
  Widget responsiveMargin(
      BuildContext context, {
        EdgeInsets? tiny,
        EdgeInsets? mobile,
        EdgeInsets? tablet,
        EdgeInsets? desktop,
        EdgeInsets? largeDesktop,
        EdgeInsets defaultMargin = const EdgeInsets.all(8),
      }) {
    final margin = context.responsive<EdgeInsets>(
      tiny: tiny,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      defaultValue: defaultMargin,
    );
    return Container(margin: margin, child: this);
  }

  /// Apply responsive constraints
  Widget responsiveConstraints(
      BuildContext context, {
        BoxConstraints? tiny,
        BoxConstraints? mobile,
        BoxConstraints? tablet,
        BoxConstraints? desktop,
        BoxConstraints? largeDesktop,
        BoxConstraints? defaultConstraints,
      }) {
    final constraints = context.responsive<BoxConstraints?>(
      tiny: tiny,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      defaultValue: defaultConstraints,
    );

    return constraints != null
        ? ConstrainedBox(constraints: constraints, child: this)
        : this;
  }
}

/// Utility class for responsive sizing
class ResponsiveSize {
  /// Get responsive font size
  static double fontSize(
      BuildContext context, {
        double? tiny,
        double? mobile,
        double? tablet,
        double? desktop,
        double? largeDesktop,
        required double defaultSize,
      }) {
    return context.responsive<double>(
      tiny: tiny,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      defaultValue: defaultSize,
    );
  }

  /// Get responsive width as percentage of screen width
  static double widthPercent(BuildContext context, double percent) {
    return context.width * (percent / 100);
  }

  /// Get responsive height as percentage of screen height
  static double heightPercent(BuildContext context, double percent) {
    return context.height * (percent / 100);
  }

  /// Get responsive size based on screen width
  static double responsive(
      BuildContext context, {
        double? tiny,
        double? mobile,
        double? tablet,
        double? desktop,
        double? largeDesktop,
        required double defaultSize,
      }) {
    return context.responsive<double>(
      tiny: tiny,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      defaultValue: defaultSize,
    );
  }
}

/// Custom responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType)? builder;
  final Widget? tiny;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget? defaultWidget;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    this.tiny,
    this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.defaultWidget,
  }) : assert(
  builder != null || defaultWidget != null,
  'Either builder or defaultWidget must be provided',
  );

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(context, context.deviceType);
    }

    return context.responsive<Widget>(
      tiny: tiny,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
      defaultValue: defaultWidget ?? const SizedBox.shrink(),
    );
  }
}