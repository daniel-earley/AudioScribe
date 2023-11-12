import 'package:flutter/material.dart';

class SnackbarUtil {
	static void showSnackbarMessage(BuildContext context, String message, Color color) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(
					message,
					style: TextStyle(fontSize: 15.0, color: color),
				),
				backgroundColor: const Color(0xFF161515),
				action: SnackBarAction(
					label: 'Close',
					onPressed: () {
						ScaffoldMessenger.of(context).hideCurrentSnackBar();
					},
				),
				duration: const Duration(seconds: 5),
			)
		);
	}
}