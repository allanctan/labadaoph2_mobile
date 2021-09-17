import 'package:labadaph2_mobile/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
// Latest Preferences Library; This class replaces PrefsService.
// Limit use of preferences only to data needed on phone.
// Otherwise, store to database to ensure consistency.

class Prefs {
  Prefs._();

  static Future<String> getTenantRef() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tenantRef = prefs.getString("tenantRef") ?? "";
    globals.tenantRef = tenantRef;
    return tenantRef;
  }

  static Future<bool> isRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    return prefs.getString("tenantRef")?.isNotEmpty ?? false;
    // always go to login
    return true;
  }

  static Future<void> saveTenantRef(String tenantRef) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    globals.tenantRef = tenantRef;
    prefs.setString("tenantRef", tenantRef);
    return;
  }

  static Future<bool> getIsDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('isDarkMode') ?? false);
  }

  static Future<bool> setIsDarkMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isDarkMode', isDarkMode);
  }

  static Future<bool> getIsWithNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('withNotifications') ?? false);
  }

  static Future<bool> setIsWithNotifications(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('withNotifications', isDarkMode);
  }

  static Future<bool> getOtpVerified() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("otpVerified") ?? false;
  }

  static Future<void> saveOtpVerified(bool verified) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("otpVerified", verified);
    return;
  }
}
