import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:labadaph2_mobile/globals.dart' as globals;
import 'package:labadaph2_mobile/navigation/app_drawer.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  HomePage();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Home"),
            ],
          ),
        ),
        actions: <Widget>[
          SizedBox(width: 50),
        ],
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          children: [
            Text("This is the Home Page."),
            Text(globals.displayName),
            Text(globals.tenantRef)
          ],
        ),
      ),
    );
  }
}
