import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/formfields/password_formfield.dart';
import 'package:labadaph2_mobile/common/formfields/phone_no_formfield.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../login_model.dart';

class CreateAccountForm extends StatefulWidget {
  static const String routeName = '/create-account';

  final String privacyUrl;
  CreateAccountForm(this.privacyUrl);

  @override
  State<StatefulWidget> createState() => new _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm>
    with TickerProviderStateMixin {
  final _formKey = new GlobalKey<FormState>();
  String _errorMessage = "";

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
                  child: Text("Create Account",
                      style: Theme.of(context).textTheme.headline3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("To get started, register new account.",
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
                SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: EdgeInsets.fromLTRB(4, 8, 16, 0),
                      child: Checkbox(
                        value: model.agree,
                        onChanged: (value) {
                          setState(() {
                            model.agree = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: "By signing up, you agree to our ",
                              style: TextStyle(color: Colors.black87),
                            ),
                            TextSpan(
                                text: "terms and conditions.",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    if (await canLaunch(widget.privacyUrl)) {
                                      await launch(widget.privacyUrl);
                                    } else {
                                      print(
                                          'Could not launch $widget.privacyUrl');
                                    }
                                  }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                    ),
                    Visibility(
                      visible: !model.agree && model.isFormSubmitted,
                      child: Expanded(
                        child: Text(
                          'You must accept term and conditions first.',
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .apply(color: Theme.of(context).errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
//                  subtitle: !_agree && _isFormSubmitted ? _acceptFirst() : null,
                SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    model.register(context, _formKey);
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      TextSpan(
                        text: "Sign-in now.",
                        style: TextStyle(color: Theme.of(context).accentColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            model.switchToLogin(true);
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
