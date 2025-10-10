import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomCardField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const CustomCardField({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.black
      ),
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff2D9CDB),
            width: 2.0,
          ),
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff2D9CDB),
            width: 2.0,
          ),
        ),
        disabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xff2D9CDB),
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
