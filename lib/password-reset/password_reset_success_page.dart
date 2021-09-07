import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/celebration.dart';
import 'package:labadaph2_mobile/login/login_signup_page.dart';

class PasswordResetSuccessPage extends StatefulWidget {
  static const String routeName = '/password-reset-success';

  @override
  State<StatefulWidget> createState() => new _PasswordResetSuccessPageState();
}

class _PasswordResetSuccessPageState extends State<PasswordResetSuccessPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 3));

  @override
  void initState() {
    Celebration.sides = [5, 3, 5, 4];
    _confettiController.play();

    super.initState();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Celebration(
        confettiController: _confettiController,
        title: "Password Reset Successful",
        subtitle: "You can now login using your new password.",
        buttonTitle: "Back To Login",
        onExit: () async {
          // ensure logout and remove all past pages
          _firebaseAuth.signOut();
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginSignupPage()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }
}
