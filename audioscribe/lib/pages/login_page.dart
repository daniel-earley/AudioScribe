import 'package:audioscribe/components/text_field_auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({Key? key}) : super(key: key);

	@override
	_LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
	bool isLoginMode = true; // default to login
	var selectedColor = const Color(0xFF524178);
	var unselectedColor = const Color(0xFF383838);

	TextEditingController emailController = TextEditingController();
	TextEditingController passwordController = TextEditingController();
	TextEditingController confirmPasswordController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildLoginPage(context)
		);
	}

	// try creating new user
	void signup() async {
		// show loading circle
		showDialog(context: context, builder: (context) {
			return const Center(
				child: CircularProgressIndicator(),
			);
		});

		// sign in
		try {
			// check if password and confirm password are the same
			if (passwordController.text == confirmPasswordController.text) {
				await FirebaseAuth.instance.createUserWithEmailAndPassword(
					email: emailController.text,
					password: passwordController.text
				);
				Navigator.pop(context);
			} else {
				Navigator.pop(context);
				authErrorMessage("Passwords don't match!");
			}
		} on FirebaseAuthException catch(e) {
			// close loading circle [pop circle]
			Navigator.pop(context);

			// show error message dialog
			authErrorMessage(e.code);

			// debug any different error codes that may pop up
			print('ERROR: ${e.code}');
		}
	}

	// sign user method
	void signin() async {
		// show loading circle
		showDialog(context: context, builder: (context) {
			return const Center(
				child: CircularProgressIndicator(),
			);
		});

		// sign in
		try {
			await FirebaseAuth.instance.signInWithEmailAndPassword(
				email: emailController.text,
				password: passwordController.text
			);

			// close loading circle [pop circle]
			Navigator.pop(context);
		} on FirebaseAuthException catch(e) {
			// close loading circle [pop circle]
			Navigator.pop(context);

			// show error message dialog
			authErrorMessage(e.code);

			// debug any different error codes that may pop up
			print('ERROR: ${e.code}');
		}
	}

	// error message on sign in
	void authErrorMessage(String errorMessage) {
		showDialog(context: context, builder: (context) {
			return AlertDialog(
				title: Text(errorMessage),
			);
		});
	}

	Widget _buildLoginPage(BuildContext context) {
		return Stack(
			children: [
				// Existing content
				SafeArea(
					child: Center(
						child: Column(
							children: [
								Expanded(
									child: AspectRatio(
										aspectRatio: 16 / 9,  // Adjust this to the aspect ratio of your image
										child: Image.asset(
											"lib/images/background_1.jpg",
											fit: BoxFit.cover,
										),
									),
								),
								// ... other children ...
							],
						),
					),
				),

				// Rectangle at the bottom
				Positioned(
					left: 0,
					right: 0,
					bottom: 0,
					height: 0.65 * MediaQuery.of(context).size.height,
					child: Container(
						decoration: const BoxDecoration(
							color: Color(0xFF242424),
							borderRadius: BorderRadius.only(
								topLeft: Radius.circular(20.0),
								topRight: Radius.circular(20.0),
							)
						),
						child: Center(
							child: Column(
								children: [
									const Padding(padding: EdgeInsets.all(15.0)),
									// Title of App
									const Text(
										'AudioScribe',
										style: TextStyle(color: Colors.white, fontSize: 25)
									),

									const SizedBox(height: 15.0),	// add gap

									// Login/SignIn Capsule
									IntrinsicWidth(
										child: Container(
											decoration: const BoxDecoration(
												color: Color(0xFF383838),
												borderRadius: BorderRadius.all(Radius.circular(50.0)),
											),
											child: Row(
												mainAxisAlignment: MainAxisAlignment.center,
												children: [
													GestureDetector(
														onTap: () {
															// if the user is in sign in mode (isLoginMode = false)
															if (!isLoginMode) {
															  	setState(() {
															  		isLoginMode = true;
																});
															}
														},
														child: Container(
															padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
															decoration: BoxDecoration(
																color: isLoginMode ? selectedColor : unselectedColor,
																borderRadius: const BorderRadius.all(Radius.circular(50.0)),
															),
															child: const Text(
																"Login",
																style: TextStyle(color: Colors.white, fontSize: 18.0)
															)
														)
													),

													GestureDetector(
														onTap: () {
															if (isLoginMode) {
																setState(() {
																  isLoginMode = !isLoginMode;
																});
															}
														},
														child: Container(
															padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
															decoration: BoxDecoration(
																color: !isLoginMode ? selectedColor : unselectedColor,
																borderRadius: const BorderRadius.all(Radius.circular(50.0)),
															),
															child: const Text(
																"Signup",
																style: TextStyle(color: Colors.white, fontSize: 18.0)
															)
														)
													),
												],
											)
										),
									),

									const SizedBox(height: 15.0),

									// enter email or username
									TextFieldAuthPage(controller: emailController, type: TextInputType.emailAddress, hintText: "Enter email or username", obscureText: false),

									const SizedBox(height: 15.0),

									// enter password
									TextFieldAuthPage(controller: passwordController, type: TextInputType.visiblePassword, hintText: "Enter password", obscureText: true),

									const SizedBox(height: 15.0),

									// confirm password
									!isLoginMode ?
										TextFieldAuthPage(controller: confirmPasswordController, type: TextInputType.visiblePassword, hintText: "Confirm password", obscureText: true)
										: Container(),

									const SizedBox(height: 30.0),

									// login/signup button
									IntrinsicWidth(
										child: Container(
											width: 150.0,
											decoration: const BoxDecoration(
												color: Color(0xFF383838),
												borderRadius: BorderRadius.all(Radius.circular(50.0)),
											),
											child: GestureDetector(
												onTap: isLoginMode ? signin : signup,
												child: Container(
													padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
													decoration: const BoxDecoration(
														color: Color(0xFF524178),
														borderRadius: BorderRadius.all(Radius.circular(50.0)),
													),
													alignment: Alignment.center,
													child:  Text(
														isLoginMode ? "Login" : "Sign up",
														style: const TextStyle(color: Colors.white, fontSize: 18.0)
													)
												)
											),
										)
									),

									const SizedBox(height: 15.0),
									// Text 'Or'
									const Text(
										"Or",
										style: TextStyle(color: Colors.white, fontSize: 18.0)
									),

									const SizedBox(height: 15.0),

									// Google Sign In
									IntrinsicWidth(
										child: Container(
											padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
											width: 240.0,
											decoration: const BoxDecoration(
												color: Color(0xFF1F1F1F),
												borderRadius: BorderRadius.all(Radius.circular(5.0))
											),
											child: GestureDetector(
												onTap: () {
													print("Logging in with google");
												},
												child: Row(
													mainAxisAlignment: MainAxisAlignment.center,
													children: [
														Image.asset('lib/images/google.png', width: 24.0, height: 24.0),
														const SizedBox(width: 5.0),
														Text(
															isLoginMode ? "Continue with Google" : "Sign up with Google",
															style: const TextStyle(color: Colors.white, fontSize: 15.0)
														)
													],
												),
											),
										),
									),

									const SizedBox(height: 10.0),

									// forgot password
									isLoginMode
										? GestureDetector(
										onTap: () {
											print("forgetting password");
										},
										child: Container(
											padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
											alignment: Alignment.center,
											child: const Text(
												"forgot password?",
												style: TextStyle(color: Colors.white, fontSize: 15.0)
											)
										)
									)
										: Container(),
								]
							)
						)
					),
				),
			],
		);
	}

}