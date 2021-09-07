import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Creates a TextFormField with obscureText enabled.
/// This also includes validation to ensure password is
///     * at least 8 characters long
///     * with at least one upper case character
///     * with at least one number

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String>? validator;

  PasswordFormField(this.controller,
      {this.labelText = "Password", this.validator});

  @override
  State<StatefulWidget> createState() => new _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscurePassword,
      autofocus: false,
      decoration: new InputDecoration(
        errorMaxLines: 2,
        labelText: widget.labelText,
        icon: new Icon(
          Icons.lock,
        ),
        suffixIcon: IconButton(
          icon: Icon(
              (_obscurePassword) ? Icons.visibility_off : Icons.visibility,
              color: (_obscurePassword)
                  ? Colors.black54
                  : Theme.of(context).accentColor),
          onPressed: () => setState(() {
            _obscurePassword = !_obscurePassword;
          }),
        ),
      ),
      validator: (value) {
        if (widget.validator != null) return widget.validator!(value);
        if (value!.isEmpty)
          return 'Password can\'t be empty';
        else if (value.length < 8)
          return 'Password must be more than 8 characters.';
        else if (!value.contains(new RegExp(r'[A-Z]')))
          return 'Password must have at least one uppercase.';
        else if (!value.contains(new RegExp(r'[0-9]')))
          return 'Password must have at least one number.';
        else
          return null;
      },
      controller: widget.controller,
    );
  }
}
