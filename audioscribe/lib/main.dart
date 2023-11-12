import 'package:audioscribe/pages/auth_page.dart';
import 'package:audioscribe/services/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {

	WidgetsFlutterBinding.ensureInitialized();
	await Firebase.initializeApp(
		options: DefaultFirebaseOptions.currentPlatform,
	);
	
	// initialize notification
	await NotificationService.initialize();
	
	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	// This widget is the root of your application.
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			home: const AuthPage(),
			theme: ThemeData(
				popupMenuTheme: const PopupMenuThemeData(
					color: Color(0xFF242424)
				)
			),
		);
	}
}


