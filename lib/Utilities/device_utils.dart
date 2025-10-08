import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get device details in a map
  static Future<Map<String, String>> getDeviceDetails() async {
    String devicename = "Unknown";
    String devicetype = "Unknown";
    String deviceos = "Unknown";

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      devicename = "${androidInfo.manufacturer} ${androidInfo.model}";
      devicetype = "mobile";
      deviceos = "android";
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      devicename = iosInfo.utsname.machine;
      devicetype = "mobile";
      deviceos = "ios";
    } else {
      devicename = "Unknown Device";
      devicetype = "web";
      deviceos = Platform.operatingSystem;
    }

    return {
      "devicename": devicename,
      "devicetype": devicetype,
      "deviceos": deviceos,
    };
  }
}
