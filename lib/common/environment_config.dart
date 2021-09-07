import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';

enum Env { staging, production }

class EnvironmentConfig {
  static Env _env = Env.production;
  static Map<String, String> staging = {
    'fbAppClientId': "280838013399026",
    'fbAppClientSecret': "70f565979b68160ddb17bfd759d8a754",
    'pushNotifUrl':
        "https://us-central1-slingshot-8f5be.cloudfunctions.net/pushNotification",
    'postingUrl':
        "http://35.215.168.236:8008/run-now?token=UyJv8h7PHnV9AfFSG26e2SU6",
    'messengerHookUrl': "https://chatengine.avigate.io/",
    'webviewUrl': "https://avigate.ph/",
  };

  static Map<String, String> production = {
    'fbAppClientId': "348801536979908",
    'fbAppClientSecret': "9e31813d65e19218c356143637b056a1",
    'pushNotifUrl':
        "https://us-central1-slingshot-8f5be.cloudfunctions.net/pushNotification",
    'postingUrl':
        "https://avigate-app-scheduler.herokuapp.com/set-scheduled-post",
    'messengerHookUrl': "https://chatengine.avigate.io",
    'webviewUrl': "https://avigate.ph/",
  };

  static void init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    print(packageInfo.appName);
    if (packageInfo.appName.contains('Staging')) {
      _env = Env.staging;
    } else {
      _env = Env.production;
    }
    print('Environment: ' + describeEnum(_env));
  }

  static String? getEnv(String key) {
    if (_env == Env.staging) {
      return staging[key];
    } else {
      return production[key];
    }
  }
}
