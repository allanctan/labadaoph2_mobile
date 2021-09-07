import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingPanel extends StatelessWidget {
  final bool isBusy;
  final String loadingLabel;
  LoadingPanel(this.isBusy, {this.loadingLabel = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return Center(
        child: Card(
          color: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                Text(loadingLabel,
                    style: Theme.of(context)
                        .textTheme
                        .headline5!
                        .apply(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }
    return Container(width: 0, height: 0);
  }
}
