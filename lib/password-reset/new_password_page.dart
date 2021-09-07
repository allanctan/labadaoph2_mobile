import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/formfields/password_formfield.dart';

import 'password_reset_success_page.dart';

class NewPasswordPage extends StatefulWidget {
  static const String routeName = '/newpass';

  @override
  State<StatefulWidget> createState() => new _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = new GlobalKey<FormState>();

  User? _currentUser;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    _isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _isLoading = false;
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
        Opacity(opacity: _isLoading ? 0.3 : 1.0, child: _showForm()),
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
                child: Text(
                  "Change Password",
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .apply(color: Colors.black87),
                ),
              ),
              SizedBox(height: 30),
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
              PasswordFormField(_passwordController, labelText: "New Password"),
              PasswordFormField(
                _confirmPasswordController,
                labelText: "Confirm Password",
                validator: (value) {
                  if (value != _passwordController.text ||
                      (value?.isEmpty ?? true)) {
                    return 'Password don\'t match';
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  child: Text('Change Password',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => _doSubmit()),
            ],
          ),
        ),
      ),
    );
  }

  bool _doSubmit() {
    final form = _formKey.currentState;
    setState(() {
      _errorMessage = "";
    });
    if (form?.validate() ?? false) {
      form!.save();
      String password = _passwordController.text;
      _currentUser = _firebaseAuth.currentUser;
      Future<void> future = _currentUser!.updatePassword(password);
      future.whenComplete(() {
        print('Password updated to ' + password);
        Navigator.pushNamed(context, PasswordResetSuccessPage.routeName);
      });
      future.catchError((e) {
        setState(() {
          _errorMessage = e.message;
        });
      });
      return true;
    }
    return false;
  }
}
