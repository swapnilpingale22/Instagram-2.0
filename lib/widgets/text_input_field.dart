import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TextFieldInput extends StatelessWidget {
  var suficon;

  TextFieldInput({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.labelText = "",
    required this.textInputType,
    this.isPass = false,
    required this.suficon,
  });

  final TextEditingController textEditingController;
  bool isPass;
  final String hintText;
  final String labelText;
  final TextInputType textInputType;

  @override
  Widget build(BuildContext context) {
    var inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
        suffixIcon: suficon,
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
