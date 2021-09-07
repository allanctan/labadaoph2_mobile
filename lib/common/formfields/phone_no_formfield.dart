import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Creates a TextFormField for phone number with proper validation.
/// This limits phone number to 11 digits number. e.g. 09119119111

class PhoneNoFormField extends StatelessWidget {
  final TextEditingController controller;
  final bool required;
  final String labelText;
  PhoneNoFormField(this.controller,
      {this.labelText = 'Phone Number', this.required = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.phone,
      style: TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: '09xxxxxxxxx',
        icon: new Icon(
          Icons.local_phone,
        ),
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(11),
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: (value) {
        if (value!.isEmpty) {
          if (required) return "Mobile number can\'t be empty.";
        } else if (value.length < 11)
          return "Mobile number is too short.";
        else if (value.startsWith("09") == false)
          return "Please enter a valid mobile number.";
        return null;
      },
      controller: controller,
    );
  }
}
