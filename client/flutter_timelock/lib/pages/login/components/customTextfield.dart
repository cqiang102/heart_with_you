import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool isPassword;
  final Function onChanged;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final TextEditingController? controller;

  const CustomTextField(
      {Key? key,
      required this.label, this.icon,
      this.isPassword = false, required this.onChanged, this.controller, this.textInputType, this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
      obscureText: isPassword,
      keyboardType: textInputType,
      onChanged: (str)=>onChanged(str),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor, width: 1.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor, width: 1.0)),
          labelText: label,
          labelStyle:
              TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
          suffixIcon: icon),
    );
  }
}
