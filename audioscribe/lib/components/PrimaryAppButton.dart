import 'package:audioscribe/app_constants.dart';
import 'package:flutter/material.dart';

class PrimaryAppButton extends StatelessWidget {
  final String buttonText;
  final num buttonSize;
  final VoidCallback onTap;

  const PrimaryAppButton(
      {super.key,
      required this.buttonText,
      required this.buttonSize,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        decoration: const BoxDecoration(
          color: AppColors.primaryAppColor,
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
        width: MediaQuery.of(context).size.width * buttonSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 24.0),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              buttonText,
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
