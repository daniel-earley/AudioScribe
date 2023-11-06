import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
	final String hintText;

	const AppSearchBar({
		super.key,
		required this.hintText,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
			child: TextField(
				keyboardType: TextInputType.text,
				decoration: InputDecoration(
					hintText: hintText,
					hintStyle: const TextStyle(color: Colors.white),
					prefixIcon: Icon(Icons.search, color: Colors.white),
					filled: true,
					fillColor: Colors.white12,
					contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
					border: OutlineInputBorder(
						borderSide: BorderSide.none,
						borderRadius: BorderRadius.circular(15.0),
					),
					enabledBorder: OutlineInputBorder(
						borderSide: BorderSide.none,
						borderRadius: BorderRadius.circular(15.0),
					),
					focusedBorder: OutlineInputBorder(
						borderSide: BorderSide.none,
						borderRadius: BorderRadius.circular(15.0),
					)
				),
			),
		);
	}
}