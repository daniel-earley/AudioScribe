import 'package:flutter/material.dart';

class PrimaryInfoText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const PrimaryInfoText(
      {super.key,
      required this.text,
      required this.color,
      required this.fontSize,
      required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: color, fontSize: fontSize, fontWeight: fontWeight));
  }
}
