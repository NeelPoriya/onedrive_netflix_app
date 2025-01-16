import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';

class DeviceUtils {
  static final DeviceUtils instance = DeviceUtils._();
  DeviceUtils._();
  
  // Static method to determine if the device is a TV
  static Future<bool> isTVDevice(BuildContext context) async {
    // Check MediaQuery for TV-like characteristics
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // Initial heuristic based on screen size and pixel density
    if (screenWidth > 1200 && screenHeight > 600 && devicePixelRatio < 2) {
      return true;
    }

    // Use device-specific checks for Android TVs
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Android TV-specific feature detection
    if (androidInfo.systemFeatures.contains('android.software.leanback')) {
      return true;
    }

    // Add additional checks for other platforms if necessary

    return false;
  }
}
