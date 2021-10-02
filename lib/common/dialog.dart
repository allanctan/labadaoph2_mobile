import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  static Future<bool> confirmDelete(
      BuildContext context, GlobalKey<FormState> formKey, String name) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Archive",
            style: Theme.of(context)
                .textTheme
                .headline6!
                .apply(color: Colors.red, fontWeightDelta: 2),
          ),
          content: Text("Are you sure you wish to archive record named \"" +
              name +
              "\"?"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  "ARCHIVE",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "CANCEL",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> confirmYesNo(
      BuildContext context, String title, String message) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline6
                ?.apply(fontWeightDelta: 2),
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  "Yes",
                  style: Theme.of(context).textTheme.bodyText1,
                )),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "No",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ],
        );
      },
    );
  }
}
