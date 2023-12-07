import 'package:flutter/material.dart';

class TextFieldAuthPage extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType type;
  final String hintText;
  final bool obscureText;
  final void Function(String) onChanged;

  const TextFieldAuthPage(
      {super.key,
      required this.controller,
      required this.type,
      required this.hintText,
      required this.obscureText,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
      ),
      child: TextField(
          controller: controller,
          keyboardType: type,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged),
    );
  }
}
