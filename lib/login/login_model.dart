import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/prefs.dart';
import 'package:labadaph2_mobile/home/home_page.dart';

import 'otp_page.dart';

class LoginModel extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool isBusy = false;
  String loadingLabel = "Loading...";

  bool? isLoginPage;
  bool agree = false;
  bool isFormSubmitted = false;
  String errorMessage = "";
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  switchToLogin(isLogin) {
    isFormSubmitted = false;
    isLoginPage = isLogin;
    notifyListeners();
  }

  setBusy(bool isBusy, {String loadingLabel = "Loading..."}) {
    print('setBusy $isBusy');
    this.isBusy = isBusy;
    this.loadingLabel = loadingLabel;
    notifyListeners();
  }

  login(BuildContext context, GlobalKey<FormState> form) {
    final FormState? formState = form.currentState;
    isFormSubmitted = true;
    errorMessage = "";
    this.setBusy(true, loadingLabel: "Logging in...");
    if (formState?.validate() ?? false) {
      print('validate');

      formState!.save();
      String mobile = mobileController.text.replaceFirst("09", "+639");
      String email = mobile + '@mailinator.com';
      // let's login and check if username and password is correct.
      _firebaseAuth
          .signInWithEmailAndPassword(
              email: email, password: passwordController.text)
          .then((value) async {
        bool otpVerifiied = await Prefs.getOtpVerified();
        if (otpVerifiied) {
          this.setBusy(false);
          Navigator.pushReplacementNamed(context, HomePage.routeName);
        } else {
          this.setBusy(false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  OTPPage(mobile, passwordController.text, 'login'),
            ),
          );
        }
      }).catchError(_handleLoginError, test: (e) => e is FirebaseAuthException);
    } else {
      this.setBusy(false);
    }
  }

  _handleLoginError(e) {
    print(e.toString() + 'SIGN-IN ERROR CODE:' + e.code);
    if (e.code == 'wrong-password') {
      errorMessage = "The password is incorrect. Please check your password.";
      this.setBusy(false);
    } else if (e.code == 'ERROR_USER_NOT_FOUND' || e.code == 'user-not-found') {
      //check user by phone number if existing
      isLoginPage = false;
      this.setBusy(false);
    } else {
      errorMessage = e.message;
      this.setBusy(false);
    }
  }

  register(BuildContext context, GlobalKey<FormState> form) {
    final FormState? formState = form.currentState;
    isFormSubmitted = true;
    errorMessage = "";
    this.setBusy(true, loadingLabel: "Checking...");

    if (formState?.validate() ?? false) {
      print('validate');
      if (!agree) {
        this.setBusy(false);
        return false;
      }

      formState!.save();
      String mobile = mobileController.text.replaceFirst("09", "+639");
      String email = mobile + '@mailinator.com';

      // user is registering, let's check if account is existing
      _firebaseAuth
          .signInWithEmailAndPassword(
              email: email, password: passwordController.text)
          .then((value) async {
        // sign-out and let user login again
        await _firebaseAuth.signOut();
        isLoginPage = true;
        errorMessage =
            "Mobile number already registered. Please sign-in below instead.";
        this.setBusy(false);
      }).catchError((e) {
        if (e.code == 'wrong-password' ||
            e.code == 'ERROR_CREDENTIAL_ALREADY_IN_USE') {
          isLoginPage = true;
          errorMessage =
              "Mobile number already registered. Please sign-in below instead.";
          this.setBusy(false);
        } else if (e.code == 'too-many-requests') {
          errorMessage =
              "We have blocked all requests from this device due to unusual activity. Try again later.";
          this.setBusy(false);
        } else {
          this.setBusy(false);
          // failed login means account is new, then proceed to OTP
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  OTPPage(mobile, passwordController.text, 'register'),
            ),
          );
        }
      });
    }
  }
}
