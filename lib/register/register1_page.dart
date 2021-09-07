import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:labadaph2_mobile/common/formfields/stores_dropdown.dart';
import 'package:labadaph2_mobile/common/loading.dart';
import 'package:labadaph2_mobile/common/prefs.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;
import 'package:labadaph2_mobile/login/login_signup_page.dart';
import 'package:labadaph2_mobile/register/register_success_page.dart';
import 'package:labadaph2_mobile/user/users_service.dart';

class Register1Page extends StatefulWidget {
  static const String routeName = '/register1';

  @override
  State<StatefulWidget> createState() => new _Register1PageState();
}

class _Register1PageState extends State<Register1Page> {
  final _formKey = new GlobalKey<FormState>();

  UsersService _usersService = UsersService();

  User? _currentUser;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String? _tenantRef;
  String? _tenantName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    User? value = FirebaseAuth.instance.currentUser;
    if (value == null) {
      Navigator.pushReplacementNamed(context, LoginSignupPage.routeName);
    } else {
      _currentUser = value;
    }
  }

  Widget _showForm() {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("assets/registration-bg.png"),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomLeft,
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            SizedBox(height: 60),
            Center(
              child: Text(
                "Your Personal Details",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 24),
            TextFormField(
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: new InputDecoration(
                  labelText: 'First Name', icon: Icon(Icons.person)),
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return "First Name can\'t be empty.";
                else
                  return null;
              },
              controller: _firstNameController,
            ),
            TextFormField(
              textCapitalization: TextCapitalization.words,
              decoration: new InputDecoration(
                  labelText: 'Last Name', icon: Icon(Icons.person)),
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return "Last Name can\'t be empty.";
                else
                  return null;
              },
              controller: _lastNameController,
            ),
            TextFormField(
              maxLines: 1,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: new InputDecoration(
                  labelText: 'Email', icon: Icon(Icons.email)),
              controller: _emailController,
            ),
            StoresDropdown(onChanged: (value) {
              print('onChanged');
              if (value != null) {
                print('value=' + value);
                var values = value.split(":");
                print(values);
                _tenantRef = values[0];
                _tenantName = values[1];
              }
            }),
            SizedBox(
              height: 24,
            ),
            ElevatedButton(
              child: Text('Continue', style: TextStyle(color: Colors.white)),
              onPressed: () {
                _doRegister();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Create your Account',
          ),
        ),
      ),
      body: Stack(children: <Widget>[
        Opacity(
          opacity: _isLoading ? 0.3 : 1.0,
          child: _showForm(),
        ),
        LoadingPanel(
          _isLoading,
          loadingLabel: "Registering...",
        ),
      ]),
    );
  }

  _doRegister() async {
    final form = _formKey.currentState;
    if (form?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      form!.save();

      DateTime now = DateTime.now();
      // save tenant
      Map<String, dynamic> userJson = {
        "firstname": _firstNameController.text.trim(),
        "lastname": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "branch": _tenantName,
        "tenantRef": _tenantRef,
      };

      _usersService.addUser(userJson);
      Prefs.saveTenantRef(_tenantRef!);
      globals.displayName = _tenantName ?? "";

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RegisterSuccessPage(),
          ),
          (Route<dynamic> route) => false);

      setState(() {
        _isLoading = false;
      });
    }
  }
}
