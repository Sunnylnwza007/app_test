import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= AppConstants.tabletBreakpoint) return DeviceType.desktop;
    if (width >= AppConstants.mobileBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= AppConstants.mobileBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
        return desktop;
      }
      if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
        return tablet ?? desktop;
      }
      return mobile;
    });
  }
}
