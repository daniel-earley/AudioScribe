import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
	const HomePage({Key? key}) : super(key: key);

	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

	// create user var
	final user = FirebaseAuth.instance.currentUser!;

	// signs user out
	void signOut() async {
		FirebaseAuth.instance.signOut();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				actions: [
					IconButton(
						onPressed: signOut,
						icon: const Icon(Icons.logout)
					)
				],
			),
			body: _buildHomePage(context),
		);
	}

	Widget _buildHomePage(BuildContext context) {
		return Stack(
			children: [
				SafeArea(
					child: Center(
						child: Text("LOGGED IN ${user.email!}"),
					)
				)
			],
		);
	}
}