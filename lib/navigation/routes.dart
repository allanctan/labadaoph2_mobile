import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/theme_testpage.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;
import 'package:labadaph2_mobile/login/login_signup_page.dart';
import 'package:labadaph2_mobile/map/map_page.dart';
import 'package:labadaph2_mobile/navigation/root_nav.dart';
import 'package:labadaph2_mobile/order/order_page.dart';
import 'package:labadaph2_mobile/order/orders_page.dart';
import 'package:labadaph2_mobile/password-reset/new_password_page.dart';
import 'package:labadaph2_mobile/password-reset/password_reset_success_page.dart';
import 'package:labadaph2_mobile/password-reset/reset_password_page.dart';
import 'package:labadaph2_mobile/register/register1_page.dart';
import 'package:labadaph2_mobile/user/users_service.dart';

import '../common/error_page.dart';
import '../common/prefs.dart';
import '../home/home_page.dart';

class Routes {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UsersService _userService = UsersService();

  Routes();

  static MaterialPageRoute onGenerateRoute(RouteSettings settings) {
    // Handle '/'
    if (settings.name == LoginSignupPage.routeName) {
      return MaterialPageRoute(builder: (context) => LoginSignupPage());
    } else if (settings.name == ThemeTestPage.routeName) {
      return MaterialPageRoute(builder: (context) => ThemeTestPage());
    } else if (settings.name == ResetPasswordPage.routeName) {
      return MaterialPageRoute(builder: (context) => ResetPasswordPage());
    } else if (settings.name == PasswordResetSuccessPage.routeName) {
      return MaterialPageRoute(
          builder: (context) => PasswordResetSuccessPage());
    } else if (settings.name == NewPasswordPage.routeName) {
      return MaterialPageRoute(builder: (context) => NewPasswordPage());
    } else if (settings.name == HomePage.routeName) {
      return MaterialPageRoute(builder: (context) => HomePage());
    } else if (settings.name == Register1Page.routeName) {
      return MaterialPageRoute(builder: (context) => Register1Page());
    } else if (settings.name == RootNav.routeName) {
      return MaterialPageRoute(builder: (context) => RootNav());
    } else if (settings.name == OrdersPage.routeName) {
      return MaterialPageRoute(
          builder: (context) =>
              OrdersPage(status: settings.arguments.toString()));
    } else if (settings.name == MapPage.routeName) {
      return MaterialPageRoute(
          builder: (context) =>
              MapPage(settings.arguments as Map<String, dynamic>));
    } else if (settings.name == OrderPage.routeName) {
      return MaterialPageRoute(
          builder: (context) =>
              OrderPage(settings.arguments as Map<String, dynamic>));
    }

    return MaterialPageRoute(
      builder: (context) =>
          ErrorPage("Invalid navigation route ${settings.name}"),
    );
  }

  Future<bool> initTenant() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null)
      return false;
    else {
      Map<String, dynamic>? userData =
          await _userService.getUser('User/' + user.uid);
      if (userData == null) {
        return false;
      } else {
        String? tenantRef = userData['tenantRef'];
        if (tenantRef == null) {
          return false;
        } else {
          globals.displayName = userData['branch'];
          globals.tenantRef = userData['tenantRef'];
          FirebaseCrashlytics.instance.setUserIdentifier(globals.displayName);
          Prefs.saveTenantRef(tenantRef);
          return true;
        }
      }
    }
  }

  Future<Widget> routeLogin() async {
    print('start routeLogin');
    await initTenant();
    User? user = _firebaseAuth.currentUser;
    if (user != null) FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    bool isOTPVerified = await Prefs.getOtpVerified();
    String tenantRef = await Prefs.getTenantRef();
    String userId = user?.uid ?? "empty";
    print(
        'routeLogin: userId: $userId, isOTPVerified $isOTPVerified, tenant $tenantRef');
    if (user != null) {
      if (isOTPVerified) {
        if (tenantRef.isEmpty) {
          return Register1Page();
        } else {
          return HomePage();
        }
      } else {
        return LoginSignupPage();
      }
    } else {
      return LoginSignupPage();
    }
  }
}
