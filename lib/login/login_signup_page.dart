import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/common/prefs.dart';
import 'package:labadaph2_mobile/login/widgets/create_account_form.dart';
import 'package:labadaph2_mobile/login/widgets/login_form.dart';
import 'package:provider/provider.dart';

import 'login_model.dart';

class LoginSignupPage extends StatefulWidget {
  static const String routeName = '/login';

  LoginSignupPage();

  @override
  State<StatefulWidget> createState() => new _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  Widget _buildForm(BuildContext context) {
    LoginModel model = Provider.of<LoginModel>(context, listen: false);
    return ListView(
      children: [
        SizedBox(height: 48),
        Image(
          image: AssetImage('assets/logo.png'),
        ),
        SizedBox(height: 24),
        FutureBuilder<bool>(
          future: Prefs.isRegistered(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              if (model.isLoginPage == null) model.isLoginPage = snapshot.data;
            }
            if (model.isLoginPage ?? false) {
              // login
              return LoginForm();
            } else {
              // register
              return CreateAccountForm("http://www.google.com");
            }
          },
        ),
        // TextButton(
        //   child: Text("Check Theme"),
        //   onPressed: () => Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => ThemeTestPage(),
        //     ),
        //   ),
        // ),
        // TextButton(
        //   child: Text("Error!!"),
        //   onPressed: () => Navigator.pushNamed(context, "/blah"),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ChangeNotifierProvider<LoginModel>(
          create: (context) => LoginModel(),
          child: Consumer<LoginModel>(
            builder: (context, model, child) => Stack(
              children: <Widget>[
                Opacity(
                  opacity: model.isBusy ? 0.3 : 1.0,
                  child: Container(
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        image: new AssetImage("assets/login-bg.png"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: model.isBusy ? 0.3 : 1.0,
                  child: _buildForm(context),
                ),
                LoadingPanel(
                  model.isBusy,
                  loadingLabel: model.loadingLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
