import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnPressedCallback = void Function();

class CircleButton extends StatelessWidget {
  final OnPressedCallback onPressed;
  final IconData icon;
  CircleButton({required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      child: IconButton(
          color: Colors.white,
          iconSize: 24,
          icon: Icon(icon),
          onPressed: onPressed),
    );
  }
}
