import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:labadaph2_mobile/common/prefs.dart';
import 'package:labadaph2_mobile/user/users_service.dart';

class AppStateNotifier extends ChangeNotifier {
  bool isDarkMode = false;
  bool isWithNotification = false;
  String profilePic = '';

  UsersService _userService = UsersService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AppStateNotifier() {
    Prefs.getIsDarkMode().then((value) {
      isDarkMode = value;
      notifyListeners();
    });
    Prefs.getIsWithNotifications().then((value) {
      isWithNotification = value;
      notifyListeners();
    });
    if (_firebaseAuth.currentUser != null) {
      _userService
          .getUser("User/" + _firebaseAuth.currentUser!.uid)
          .then((value) {
        profilePic = value?['profilePic'] ?? "";
        notifyListeners();
      });
    }
  }

  void updateTheme(bool isDarkMode) {
    this.isDarkMode = isDarkMode;
    Prefs.setIsDarkMode(isDarkMode);
    notifyListeners();
  }

  void toggleTheme() {
    this.isDarkMode = !this.isDarkMode;
    Prefs.setIsDarkMode(isDarkMode);
    notifyListeners();
  }

  void receiveNotification() {
    this.isWithNotification = true;
    Prefs.setIsWithNotifications(true);
    print('receiveNotification : ' + this.isWithNotification.toString());
    notifyListeners();
  }

  void clearNotifications() {
    this.isWithNotification = false;
    Prefs.setIsWithNotifications(false);
  }

  void updateProfilePic(String profilePicUrl) {
    profilePic = profilePicUrl;
    notifyListeners();
  }
}
