import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
	final String headerText;
	final VoidCallback onTap;
	final bool isSwitched;
	final ValueChanged<bool> onToggle;
	final int currentScreen;


	const AppHeader({
		super.key,
		required this.headerText,
		required this.onTap,
		required this.onToggle,
		required this.isSwitched,
		required this.currentScreen,
	});

	void signOut() async {
		FirebaseAuth.instance.signOut();
	}

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Text(
						headerText,
						style: const TextStyle(color: Colors.white, fontSize: 25.0),
					),

					currentScreen != 2 ?
					PopupMenuButton<String>(
						onSelected: (String value) {
							if (value == 'logout') {
								// perform logout
								signOut();
							} else if (value == 'setting') {
								// navigate to settings page
								onTap();
							}
						},
						itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
							const PopupMenuItem<String>(
								value: 'setting',
								child: Row(
									children: [
										Icon(Icons.settings, color: Colors.white),
										SizedBox(width: 10.0),
										Text('Settings', style: TextStyle(color: Colors.white))
									]
								)
							),
							const PopupMenuItem<String>(
								value: 'logout',
								child: Row(
									children: [
										Icon(Icons.logout, color: Colors.white),
										SizedBox(width: 10.0),
										Text('Logout', style: TextStyle(color: Colors.white))
									]
								)
							),
						],
						icon: const Icon(Icons.account_circle, size: 45.0, color: Colors.white),
					)
						:
					Switch(
						value: isSwitched,
						overlayColor: MaterialStateProperty.resolveWith(
								(states) {
									if (states.contains(MaterialState.selected)) {
										return Colors.amber.withOpacity(0.54);
									}
									if (states.contains(MaterialState.disabled)) {
										return Colors.grey.shade400;
									}
									return null;
								}),
						trackColor: MaterialStateProperty.resolveWith(
								(states) {
									if (states.contains(MaterialState.selected)) {
										return Colors.amber;
									}
									return null;
								}
						),
						thumbColor: const MaterialStatePropertyAll(Colors.black),
						onChanged: onToggle,
					)
				],
			),
		);
	}
}