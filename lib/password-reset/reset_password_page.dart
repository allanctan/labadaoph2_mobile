import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/formfields/phone_no_formfield.dart';
import 'package:labadaph2_mobile/login/otp_page.dart';

class ResetPasswordPage extends StatefulWidget {
  static const String routeName = '/password-reset';

  @override
  State<StatefulWidget> createState() => new _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final _formKey = new GlobalKey<FormState>();

  TextEditingController _mobileController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      children: <Widget>[
        Opacity(
          opacity: _isLoading ? 0.3 : 1.0,
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/password-bg.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
        _showCircularProgress(),
        Opacity(
          opacity: _isLoading ? 0.3 : 1.0,
          child: _showForm(),
        ),
      ],
    ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showForm() {
    return new Container(
      child: new Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: new ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 30.0),
                child: Image.asset('assets/logo.png'),
              ),
              Center(
                child: Text("Reset Password",
                    style: Theme.of(context).textTheme.headline3),
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: (_errorMessage.length > 0),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .apply(color: Theme.of(context).errorColor),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // MOBILE NUMBER
              PhoneNoFormField(_mobileController,
                  labelText: "Mobile Number", required: true),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  child: Text('Continue'), onPressed: () => _doSubmit()),
            ],
          ),
        ),
      ),
    );
  }

  bool _doSubmit() {
    final form = _formKey.currentState;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    if (form?.validate() ?? false) {
      form!.save();
      String mobile = _mobileController.text.replaceFirst("09", "+639");
      String email = mobile + '@mailinator.com';

      // check if number is existing.
      _firebaseAuth
          .fetchSignInMethodsForEmail(email)
          .then((List<String> value) {
        print(value);
        if (value.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "We are unable to verify your mobile number. Please check the number and try again.";
          });
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      OTPPage(mobile, null, "password-reset")));
        }
      }).catchError((e) {
        _isLoading = false;
        _errorMessage = e.message;
      });
      return true;
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    return false;
  }
}
