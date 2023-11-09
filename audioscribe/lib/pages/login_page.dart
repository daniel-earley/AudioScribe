import 'package:audioscribe/components/text_field_auth_page.dart';
import 'package:audioscribe/components/toggle_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_constants.dart';
import '../data_classes/user.dart' as userClient;
import '../utils/database/user_model.dart' as userModel;


class LoginPage extends StatefulWidget {
	const LoginPage({Key? key}) : super(key: key);

	@override
	_LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
	// Global vars
	final GlobalKey<State> _dialogKey = GlobalKey<State>();

	// Local vars
	AuthMode currentAuthMode = AuthMode.LOGIN;
	var selectedColor = const Color(0xFF524178);
	var unselectedColor = const Color(0xFF383838);
	final userModel.UserModel _userModel = userModel.UserModel();

	// Controllers
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

	/// Creates new user using firebase authentication system and stores relevant information SQLite DB
	void signup() async {
		showLoadingDialog();

		// sign up
		try {
			// check if password and confirm password are the same
			if (passwordController.text == confirmPasswordController.text) {
				UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
					email: emailController.text,
					password: passwordController.text
				);

				// retrieve the UID of the signed-in user
				String uid = userCredential.user?.uid ?? "";
				String username = userCredential.user?.email ?? "";
				print('User Information: $uid | $username');

				// new user object
				final userClient.User newUser = userClient.User(userId: uid, username: username, bookLibrary: []);

				// insert user into db
				await clientQueryInsertUser(newUser);

			} else {
				authErrorMessage("Passwords don't match!");
			}
		} on FirebaseAuthException catch(e) {
			// show error message dialog
			authErrorMessage(e.code);

			// debug any different error codes that may pop up
			print('ERROR: ${e.code}');
			dismissLoadingDialog();
		} finally {
			dismissLoadingDialog();
		}
	}

	/// Invokes the insert user method to insert user into SQLite DB
	Future<void> clientQueryInsertUser(userClient.User user) async {
		try {
			await _userModel.insertUser(user);
			print('Inserted new user ${user.toString()} to database');
		} catch (e) {
			print('Error inserting user: $e');
		}
	}

	/// signs user in using firebase authentication system
	void signin() async {
		showLoadingDialog();

		// sign in
		try {
			UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
				email: emailController.text,
				password: passwordController.text
			);

			// retreive the UID of the signed-in user
			String uid = userCredential.user?.uid ?? "";
			String username = userCredential.user?.email ?? "";
			print('User Information: $uid | $username');

		} on FirebaseAuthException catch(e) {
			// show error message dialog
			authErrorMessage(e.code);

			// debug any different error codes that may pop up
			print('ERROR: ${e.code}');
			dismissLoadingDialog();
		} finally {
			dismissLoadingDialog();
		}
	}

	/// error message on sign in
	void authErrorMessage(String errorMessage) {
		showDialog(context: context, builder: (context) {
			return AlertDialog(
				title: Text(errorMessage),
			);
		});
	}

	/// Shows the circular loading indicator when signin the user in
	void showLoadingDialog() {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return WillPopScope(
					onWillPop: () async => false,
					child: Center(
						child: CircularProgressIndicator(key: _dialogKey),
					)
				);
			}
		);
	}

	/// Dismisses the circular loading indicator when user has signed in using global key to get context
	void dismissLoadingDialog() {
		if(_dialogKey.currentContext != null) {
			Navigator.of(_dialogKey.currentContext!, rootNavigator: true).pop();
		}
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
													// Login Capsule
													ToggleLoginButton(
														authMode: currentAuthMode,
														// authMode: "LOGIN",
														onTap: () {
															setState(() {
																currentAuthMode = AuthMode.LOGIN;
																// isLoginMode = true;
															});
														},
														buttonText: "Login"
													),

													// Signup capsule
													ToggleLoginButton(
														authMode: currentAuthMode,
														// authMode: "SIGNUP",
														onTap: () {
															setState(() {
																currentAuthMode = AuthMode.SIGNUP;
															});
														},
														buttonText: "Signup"
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
									currentAuthMode == AuthMode.SIGNUP ?
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
												onTap: currentAuthMode == AuthMode.LOGIN ? signin : signup,
												child: Container(
													padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
													decoration: const BoxDecoration(
														color: Color(0xFF524178),
														borderRadius: BorderRadius.all(Radius.circular(50.0)),
													),
													alignment: Alignment.center,
													child:  Text(
														currentAuthMode == AuthMode.LOGIN ? "Login" : "Sign up",
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
															currentAuthMode == AuthMode.LOGIN ? "Continue with Google" : "Sign up with Google",
															style: const TextStyle(color: Colors.white, fontSize: 15.0)
														)
													],
												),
											),
										),
									),

									const SizedBox(height: 10.0),

									// forgot password
									currentAuthMode == AuthMode.LOGIN
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