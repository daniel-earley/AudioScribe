import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
	final String headerText;
	final VoidCallback signout;


	const AppHeader({
		super.key,
		required this.headerText,
		required this.signout
	});

	Future _showAccountDialog(BuildContext context) {
		return showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					title: const Text('Profile'),
					content: Stack(
						children: [
							const Text("Profile information"),
							IconButton(
								icon: Icon(Icons.logout),
								onPressed: signout,
							)
						]
					),
					actions: [
						TextButton(
							onPressed: () {
								Navigator.of(context).pop();
							},
							child: Text('Close')),
					],
				);
			}
		);
	}

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Text(
						headerText,
						style: TextStyle(color: Colors.white, fontSize: 25.0),
					),
					IconButton(
						icon: const Icon(Icons.account_circle, size: 45.0, color: Colors.white),
						onPressed: () => _showAccountDialog(context),
					),
				],
			),
		);
	}
}