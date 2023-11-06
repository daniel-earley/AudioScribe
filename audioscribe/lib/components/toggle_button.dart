import "package:flutter/material.dart";

import "../app_constants.dart";

class ToggleLoginButton extends StatefulWidget {
	// final bool isLoginMode;
	final AuthMode authMode;
	final Function() onTap;
	final String buttonText;

	const ToggleLoginButton({
		super.key,
		// required this.isLoginMode,
		required this.authMode,
		required this.onTap,
		required this.buttonText
	});

	@override
	_ToggleLoginButton createState() => _ToggleLoginButton();
}

class _ToggleLoginButton extends State<ToggleLoginButton> {
	Color selectedColor = const Color(0xFF524178);
	Color unselectedColor = const Color(0xFF383838);

	@override
	Widget build(BuildContext context) {
		Color authorizationMode() {
			switch (widget.authMode) {
				case AuthMode.LOGIN:
					return widget.buttonText == "Login" ? selectedColor : unselectedColor;
				case AuthMode.SIGNUP:
					return widget.buttonText == "Signup" ? selectedColor : unselectedColor;
				default:
					return unselectedColor;
			}
		}

		return GestureDetector(
			onTap: widget.onTap,
			child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
				decoration: BoxDecoration(
					color: authorizationMode(),
					borderRadius: const BorderRadius.all(Radius.circular(50.0)),
				),
				child: Text(
					widget.buttonText,
					style: const TextStyle(color: Colors.white, fontSize: 18.0)
				)
			)
		);
	}
}