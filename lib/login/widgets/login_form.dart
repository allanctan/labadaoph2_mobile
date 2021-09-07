import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/formfields/password_formfield.dart';
import 'package:labadaph2_mobile/common/formfields/phone_no_formfield.dart';
import 'package:labadaph2_mobile/password-reset/reset_password_page.dart';
import 'package:provider/provider.dart';

import '../login_model.dart';

class LoginForm extends StatefulWidget {
  static const String routeName = '/login';

  LoginForm();

  @override
  State<StatefulWidget> createState() => new _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LoginModel model = Provider.of<LoginModel>(context, listen: false);
    return Container(
      child: new Form(
        key: _formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Login",
                      style: Theme.of(context).textTheme.headline3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Please sign in to continue.",
                      style: Theme.of(context).textTheme.bodyText2),
                ),
                SizedBox(height: 12),
                Visibility(
                  visible: (model.errorMessage.length > 0),
                  child: Text(
                    model.errorMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6!
                        .apply(color: Theme.of(context).errorColor),
                  ),
                ),
                SizedBox(height: 12),
                // MOBILE NUMBER
                PhoneNoFormField(model.mobileController,
                    labelText: "Mobile Number", required: true),
                // PASSWORD
                PasswordFormField(model.passwordController),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, ResetPasswordPage.routeName);
                    },
                    child: Text("Forgot Password?",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2!
                            .apply(color: Theme.of(context).accentColor)),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => model.login(context, _formKey),
                ),
                SizedBox(
                  height: 24,
                ),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Not yet registered? ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      TextSpan(
                        text: "Create your account.",
                        style: TextStyle(color: Theme.of(context).accentColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            model.switchToLogin(false);
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
