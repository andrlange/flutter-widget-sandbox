import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

class LayoutDevices {
  const LayoutDevices();

  DeviceInfo get smallPhone => _smallPhone;
  static final _smallPhone = DeviceInfo.genericPhone(
    platform: TargetPlatform.android,
    name: 'Small Phone',
    id: 'small',
    screenSize: const Size(385, 712),
    safeAreas: const EdgeInsets.only(
      left: 0.0,
      top: 24.0,
      right: 0.0,
      bottom: 0.0,
    ),
    rotatedSafeAreas: const EdgeInsets.only(
      left: 0.0,
      top: 24.0,
      right: 0.0,
      bottom: 0.0,
    ),
  );

  DeviceInfo get mediumPhone => _mediumPhone;
  static final _mediumPhone = DeviceInfo.genericPhone(
    platform: TargetPlatform.android,
    name: 'Medium Phone',
    id: 'medium',
    screenSize: const Size(412, 732),
    safeAreas: const EdgeInsets.only(
      left: 0.0,
      top: 24.0,
      right: 0.0,
      bottom: 0.0,
    ),
    rotatedSafeAreas: const EdgeInsets.only(
      left: 0.0,
      top: 24.0,
      right: 0.0,
      bottom: 0.0,
    ),
  );

  DeviceInfo get mediumTablet => _mediumTablet;
  static final _mediumTablet = DeviceInfo.genericTablet(
    platform: TargetPlatform.android,
    name: 'Medium Tablet',
    id: 'medium',
    screenSize: const Size(1024, 1350),
    safeAreas: const EdgeInsets.only(
      left: 0.0,
      top: 24.0,
      right: 0.0,
      bottom: 0.0,
    ),
    rotatedSafeAreas: const EdgeInsets.only(
      left: 0.0,
      top: 24.0,
      right: 0.0,
      bottom: 0.0,
    ),
  );

  DeviceInfo get mediumDesktop => _mediumDesktop;
  static final _mediumDesktop = DeviceInfo.genericDesktopMonitor(
    platform: TargetPlatform.windows,
    name: 'Full HD Desktop',
    id: 'large',
    screenSize: const Size(1920, 1080),
    windowPosition: Rect.fromCenter(
      center: const Offset(
        1920 * 0.5,
        1080 * 0.5,
      ),
      width: 1920,
      height: 1080,
    ),
  );
}
