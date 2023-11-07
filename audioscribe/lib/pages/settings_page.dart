import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/components/settings_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
	const SettingsPage({Key? key}) : super(key: key);

	@override
	_SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildSettingsPage(context)
		);
	}

	void signOut() async {
		FirebaseAuth.instance.signOut();
	}

	Widget _buildSettingsPage(BuildContext context) {
		return Stack(
			children: [
				SafeArea(
					child: Padding(
						padding: EdgeInsets.symmetric(horizontal: 20.0, vertical:  10.0),
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const Icon(Icons.account_circle, size: 100.0, color: Colors.white),

									const SizedBox(height: 15.0),

									const SettingsEditableTextField(initialText: 'John Doe', titleText: 'Username'),

									const SizedBox(height: 15.0),

									const SettingsEditableTextField(initialText: 'john.doe@gmail.com', titleText: 'Email'),

									const SizedBox(height: 15.0),

									const SettingsEditableTextField(initialText: '********', titleText: 'Password'),

									const SizedBox(height: 15.0),

									// sign out button
									ElevatedButton(
										onPressed: signOut,
										child: const Text('Sign out'),
										style: ElevatedButton.styleFrom(
											foregroundColor: Colors.white,
											backgroundColor: Colors.deepPurple,
											minimumSize: const Size(125, 40),
											padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
										),
									),
								],
							),
						)
					),

				),
			],
		);
	}
}