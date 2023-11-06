import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
	final String text;

	const Separator({
		super.key,
		required this.text,
	});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						text,
						style: const TextStyle(
							color: Colors.white70,
							fontSize: 18.0,
						),
					),
					Container(
						margin: EdgeInsets.only(top: 3.0),
						height: 1.0,
						color: Colors.white12
					),
				],
			)
		);
	}
}