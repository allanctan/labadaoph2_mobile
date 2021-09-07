import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnExitCallback = void Function();

class Celebration extends StatelessWidget {
  final ConfettiController confettiController;
  static List<int> sides = [3, 4, 5, 5, 5, 5];
  final OnExitCallback? onExit;
  final OnExitCallback? onAlternate;
  final String title;
  final String subtitle;
  final String description;
  final String buttonTitle;
  final String assetImage;
  final String alternateTitle;

  Celebration(
      {required this.confettiController,
      required this.title,
      this.subtitle = "",
      this.description = "",
      this.assetImage = "assets/celebration.png",
      this.buttonTitle = "Done",
      this.onExit,
      this.alternateTitle = "",
      this.onAlternate});

  static Path drawStar(Size size) {
    var numberOfPoints = Celebration.sides[Random().nextInt(4)];
    if (numberOfPoints == 4) {
      final halfWidth = size.width / 2;
      final path = Path();
      path.moveTo(0, -halfWidth);
      path.lineTo(0, halfWidth);
      path.lineTo(halfWidth, halfWidth);
      path.lineTo(halfWidth, -halfWidth);
      path.close();
      return path;
    } else {
      double degToRad(double deg) => deg * (pi / 180.0);
      final halfWidth = size.width / 2;
      final externalRadius = halfWidth;
      final internalRadius = halfWidth / 2.5;
      final degreesPerStep = degToRad(360 / numberOfPoints);
      final halfDegreesPerStep = degreesPerStep / 2;
      final path = Path();
      final fullAngle = degToRad(360);
      path.moveTo(size.width, halfWidth);
      for (double step = 0; step < fullAngle; step += degreesPerStep) {
        path.lineTo(halfWidth + externalRadius * cos(step),
            halfWidth + externalRadius * sin(step));
        path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
            halfWidth + internalRadius * sin(step + halfDegreesPerStep));
      }
      path.close();
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //CENTER -- Blast
        Positioned(
          top: 280,
          right: MediaQuery.of(context).size.width / 2,
          child: ConfettiWidget(
            confettiController: confettiController,
            blastDirectionality: BlastDirectionality
                .explosive, // don't specify a direction, blast randomly
            shouldLoop:
                false, // start again as soon as the animation is finished
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.orange,
              Colors.red,
            ], // manually specify the colors to be used
            createParticlePath:
                Celebration.drawStar, // define a custom shape/path.
          ),
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 30.0),
                child: Image.asset('assets/logo.png'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .apply(color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 40),
              InkWell(
                onTap: () => confettiController.play(),
                child: Image(
                  image: AssetImage(assetImage),
                  width: 150,
                ),
              ),
              SizedBox(height: 40),
              Visibility(
                visible: (description.length > 0),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: ElevatedButton(
                        child: Text(
                          buttonTitle,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          if (onExit != null) onExit!();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: (alternateTitle.length > 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.grey[300]),
                          child: Text(
                            alternateTitle,
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            if (onExit != null) onAlternate!();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ],
    );
  }
}
