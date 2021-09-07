import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/common/prefs.dart';
import 'package:labadaph2_mobile/navigation/root_nav.dart';
import 'package:labadaph2_mobile/password-reset/new_password_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPPage extends StatefulWidget {
  static const String routeName = '/otp';

  final String mobile;
  final String? password;
  final String action;

  OTPPage(this.mobile, this.password, this.action);

  @override
  State<StatefulWidget> createState() =>
      new _OTPPageState(mobile, password, action);
}

class _OTPPageState extends State<OTPPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final RegExp _numeric = RegExp(r'^[0-9]+$');

  String mobile;
  final String? password;
  final String action;

  _OTPPageState(this.mobile, this.password, this.action);

  TextEditingController _pinCodeController = TextEditingController();
  String _verificationId = "";
  String _mainMessage = "";
  String _subMessage = "";
  String _errorMessage = "";
  bool _isLoading = false;
  bool _isTimedOut = false;

  @override
  void initState() {
    super.initState();
    if (this.mobile == null || this.mobile.isEmpty) {
      // if no mobile, let's get from auth
      User? user = _firebaseAuth.currentUser;
      String email = user?.email ?? "";
      this.mobile = email.substring(0, email.indexOf("@"));
    }
    print('OTP init with mobile: ' + this.mobile);
    setState(() {
      _mainMessage = "Verifying mobile number...";
    });
    _sendOTP();
  }

  _sendOTP() {
    print('sending OTP for mobile: ' + this.mobile);
    _firebaseAuth.verifyPhoneNumber(
      phoneNumber: this.mobile,
      timeout: Duration(seconds: 60),
      verificationCompleted: (authCredential) =>
          _verificationComplete(authCredential, context),
      verificationFailed: (authException) =>
          _verificationFailed(authException, context),
      codeAutoRetrievalTimeout: (verificationId) =>
          _codeAutoRetrievalTimeout(verificationId),
      // called when the SMS code is sent
      codeSent: (verificationId, [forceResendingToken]) =>
          _smsCodeSent(verificationId),
    );
  }

  _smsCodeSent(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _verificationId = verificationId;
    print('code sent');
    print(_verificationId);
    setState(() {
      _mainMessage = "Enter One-Time Pin";
      _subMessage = "sent to " + this.mobile;
      _isTimedOut = false;
    });
  }

  _verificationFailed(
      FirebaseAuthException authException, BuildContext context) {
    print('failed');
    print(authException.message.toString());
    setState(() {
      _errorMessage = authException.message!;
    });
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    print('timeout');
    setState(() {
      _isTimedOut = true;
    });
    // set the verification code so that we can use it to log the user in
    _verificationId = verificationId;
  }

  /// will get an AuthCredential object that will help with logging into Firebase.
  _verificationComplete(
      AuthCredential authCredential, BuildContext context) async {
    print("Verification Complete");
    _doSuccess(authCredential);
  }

  _linkEmailAccount(AuthCredential credential) {
    print("linkEmailAccount");
    String email = this.mobile + '@mailinator.com';
    _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password!)
        .then((UserCredential emailCredential) {
      // get current user which is the email user
      User? user = _firebaseAuth.currentUser;
      user?.linkWithCredential(credential).then((linkResult) {
        _proceed(credential);
      }).catchError(handleLinkWithError);
    }).catchError((e) async {
      if (e.code == "email-already-in-use") {
        _firebaseAuth
            .signInWithEmailAndPassword(email: email, password: password!)
            .then((UserCredential emailCredential) {
          // get current user which is the email user
          User? user = _firebaseAuth.currentUser;
          user?.linkWithCredential(credential).then((linkResult) {
            _proceed(credential);
          }).catchError(handleLinkWithError);
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
      await _firebaseAuth.signOut();
    });
  }

  _updateAccountPassword(AuthCredential credential) {
    print("Updating account...");
    _firebaseAuth.signInWithCredential(credential);
    setState(() {
      _isLoading = false;
    });
    Navigator.pushReplacementNamed(context, NewPasswordPage.routeName);
  }

  _proceed(AuthCredential credential) async {
    print("Proceed to next...");
    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacementNamed(context, RootNav.routeName);
  }

  _doSuccess(AuthCredential authCredential) {
    // Sign the user in (or link) with the credential
    print(this.action);
    Prefs.saveOtpVerified(true);
    User? user = _firebaseAuth.currentUser;
    if (user?.email == null) {
      _linkEmailAccount(authCredential);
    }

    if (this.action == 'password-reset') {
      _updateAccountPassword(authCredential);
    } else {
      _proceed(authCredential);
    }
  }

  void _manualSubmit() async {
    print('manual submit');
    AuthCredential authCredential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _pinCodeController.text.trim(),
    );

    await _firebaseAuth
        .signInWithCredential(authCredential)
        .then((value) async {
      _doSuccess(authCredential);
    }).catchError((e) {
      print(e.toString());
      if (e.code == 'invalid-verification-code') {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "The pin code you entered is incorrect. Please check and try again.";
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      }
    });
  }

  List<Widget> _buildPinCode() {
    return [
      Visibility(
        visible: (_subMessage.length > 0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
            child: Column(
              children: <Widget>[
                PinCodeTextField(
                  textStyle: Theme.of(context)
                      .textTheme
                      .headline4!
                      .apply(color: Colors.black87),
                  length: 6,
                  showCursor: true,
                  obscureText: false,
                  cursorColor: Theme.of(context).accentColor,
                  animationType: AnimationType.scale,
                  validator: (v) {
                    if ((v?.length ?? 0) < 6) {
                      return "Please fill up the 6 digit pin code.";
                    } else if (_numeric.hasMatch(v!) == false) {
                      return "Please enter numeric values only.";
                    }
                    return null;
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: Theme.of(context).accentColor,
                    activeFillColor:
                        Colors.white, // Theme.of(context).colorScheme.primary,
                    selectedColor: Colors
                        .black87, // Theme.of(context).colorScheme.onSecondary,
                    selectedFillColor: Colors
                        .white70, // Theme.of(context).colorScheme.secondary,
                    inactiveColor: Colors
                        .black87, //Theme.of(context).colorScheme.onSecondary,
                    inactiveFillColor:
                        Colors.white, //Theme.of(context).colorScheme.primary,
                  ),
                  keyboardType: TextInputType.phone,
                  animationDuration: Duration(milliseconds: 300),
                  controller: _pinCodeController,
                  onChanged: (e) {
                    setState(() {
                      _errorMessage = "";
                    });
                  },
                  beforeTextPaste: (text) {
                    return true;
                  },
                  appContext: context,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  // needed to expand button below
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        child: Text('Continue',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          final form = _formKey.currentState;
                          if (form?.validate() ?? false) {
                            setState(() {
                              _isLoading = true;
                            });
                            form!.save();
                            _manualSubmit();
                          }
                          setState(() {
                            _isTimedOut = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Visibility(
                  visible: (_subMessage.length > 0),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Didn't receive the pin? ",
                          style: TextStyle(color: Colors.black87),
                        ),
                        _isTimedOut
                            ? TextSpan(
                                text: "Resend pin.",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _sendOTP();
                                  })
                            : TextSpan(
                                text: "Please wait ... ",
                                style: TextStyle(color: Colors.black87),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  handleLinkWithError(e) async {
    await _firebaseAuth.signOut();
    if (e == null) {
      _isLoading = false;
      return;
    }
    print(e.toString());
    if (e?.code == "ERROR_INVALID_VERIFICATION_CODE" ||
        e?.code == "invalid-verification-code") {
      setState(() {
        _isLoading = false;
        _errorMessage = "Pin code is incorrect. Please try again.";
      });
    } else if (e?.code == "email-already-in-use") {
      setState(() {
        _isLoading = false;
        _errorMessage = "Mobile number already registered.";
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = e?.message ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LoadingPanel(true, loadingLabel: 'Please wait...'),
          Opacity(
            opacity: _isLoading ? 0.3 : 1.0,
            child: new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/otp-bg.png"),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          Opacity(
            opacity: _isLoading ? 0.3 : 1.0,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                      SizedBox(height: 100, width: double.infinity),
                      Text(
                        _mainMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .apply(color: Colors.black87),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _subMessage,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .apply(color: Colors.black87),
                      ),
                      SizedBox(height: 24),
                      Visibility(
                        visible: (_subMessage.length <= 0),
                        child: CircularProgressIndicator(),
                      ),
                      Visibility(
                        visible: (_errorMessage.length > 0),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                    ] +
                    _buildPinCode(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
