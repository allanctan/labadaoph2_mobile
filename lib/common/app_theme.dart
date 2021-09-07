import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final textTheme = TextTheme(
    headline1: TextStyle(
        fontSize: 48, fontWeight: FontWeight.w600, letterSpacing: -1.5),
    headline2: TextStyle(
        fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: -0.5),
    headline3: TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0.25),
    headline4: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headline5: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    headline6: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
    subtitle1: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15),
    subtitle2: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyText1: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyText2: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    button: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    caption: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    overline: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120, 42),
        elevation: 0,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(120, 42),
        elevation: 0,
      ),
    ),
  );
}
