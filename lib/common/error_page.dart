import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  static const String routeName = '/error';

  final String message;
  ErrorPage(this.message);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 10,
            ),
            Text(
              "Oops... Sorry.",
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .apply(color: Colors.red),
            ),
            Image(
              image: AssetImage('assets/sadness.png'),
              width: MediaQuery.of(context).size.width * 0.75,
            ),
            Text(
              'Error details: $message',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .apply(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, "/"),
                    child: Text("Recover Now"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
