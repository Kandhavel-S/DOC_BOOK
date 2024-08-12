import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomInput({
    Key? key,
    required this.hint,
    this.isPassword = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
