import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListDropdown extends StatelessWidget {
  final dropdownState = GlobalKey<FormFieldState>();
  final ValueChanged<String?> onChanged;
  final List<String> list;
  final String value;

  ListDropdown({
    required this.list,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      child: DropdownButtonFormField<String>(
        value: value,
        items: list.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
                width: 25,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                )),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
