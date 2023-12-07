import 'package:flutter/material.dart';

class PopUpCircularButton extends StatelessWidget {
  final Icon buttonIcon;
  final VoidCallback onTap;
  final String label;

  const PopUpCircularButton({
    super.key,
    required this.buttonIcon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF524178),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: buttonIcon,
          ),

          // Vertical spacing
          const SizedBox(height: 10.0),

          // Label
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          )
        ],
      ),
    );
  }
}
