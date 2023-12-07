import 'package:audioscribe/components/text_field_auth_page.dart';
import 'package:audioscribe/components/toggle_button.dart';
import 'package:audioscribe/services/auth_service.dart';
import 'package:audioscribe/services/notification_services.dart';
import 'package:audioscribe/utils/interface/snack_bar.dart';
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
  bool passwordsMatch = true;

  // Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF303030),
        body: _buildLoginPage(context));
  }

  /// Creates new user using firebase authentication system and stores relevant information SQLite DB
  void signup() async {
    showLoadingDialog();

    // sign up
    try {
      // check if password and confirm password are the same
      if (passwordController.text == confirmPasswordController.text) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text);

        // retrieve the UID of the signed-in user
        String uid = userCredential.user?.uid ?? "";
        String username = userCredential.user?.email ?? "";
        print('User Information: $uid | $username');

        // new user object
        final userClient.User newUser = userClient.User(
            userId: uid, username: username, bookLibrary: [], loggedIn: true);

        // insert user into db
        await clientQueryInsertUser(newUser);

        // show welcome notification
        await NotificationService.showWelcomeNotification();
      } else {
        authErrorMessage("Passwords don't match!");
      }

      // dismiss loading circle
      dismissLoadingDialog();
    } on FirebaseAuthException catch (e) {
      // dismiss loading circle
      dismissLoadingDialog();

      // debug any different error codes that may pop up
      print('ERROR: ${e.code}');

      // show error message dialog
      authErrorMessage(e.code);
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // retreive the UID of the signed-in user
      String uid = userCredential.user?.uid ?? "";
      String username = userCredential.user?.email ?? "";
      print('User Information: $uid | $username');

      // check if user is in SQLite, if not then add them in
      bool userExists = await checkUserExists();
      String userId = getCurrentUserId();
      if (!userExists) {
        fetchUserFromFirebase(userId);
      }

      // dismiss loading
      dismissLoadingDialog();
    } on FirebaseAuthException catch (e) {
      // dismiss loading
      dismissLoadingDialog();

      // debug any different error codes that may pop up
      print('ERROR: ${e.code}');

      // show error message dialog
      authErrorMessage(e.code);
    }
  }

  /// error message on sign in
  void authErrorMessage(String errorMessage) {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    SnackbarUtil.showSnackbarMessage(context, errorMessage, Colors.red);
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
              ));
        });
  }

  /// Dismisses the circular loading indicator when user has signed in using global key to get context
  void dismissLoadingDialog() {
    if (_dialogKey.currentContext != null) {
      Navigator.of(_dialogKey.currentContext!, rootNavigator: true).pop();
    }
  }

  /// function to reset textfields on current auth mode change
  void resetTextFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  /// password state change
  void _onPasswordChanged(String password) {
    setState(() {
      passwordsMatch = password == passwordController.text;
    });
  }

  /// confirm password state change
  void _onConfirmPasswordChanged(String confirmPassword) {
    setState(() {
      passwordsMatch = confirmPassword == confirmPasswordController.text;
    });
  }

  /// reset password feature
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      authErrorMessage(e.message.toString());
    }
  }

  /// fallback function to retrieve user info from firebase
  void fetchUserFromFirebase(String userId) async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    userModel.UserModel _userModel = userModel.UserModel();

    if (firebaseUser != null) {
      // Create a new user object from Firebase user
      userClient.User user = userClient.User(
          userId: firebaseUser.uid,
          username: firebaseUser.email ?? '',
          bookLibrary: [],
          loggedIn: true);

      // insert user in SQLite
      await _userModel.insertUser(user);
    }
  }

  /// get the current instance of the user that is logged In
  String getCurrentUserId() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;
      return uid;
    } else {
      return 'No user is currently signed in';
    }
  }

  Future<bool> checkUserExists() async {
    userModel.UserModel userModelInstance = userModel.UserModel();
    try {
      String userId = getCurrentUserId();

      userClient.User? user = await userModelInstance.getUserByID(userId);

      return user != null ? true : false;
    } catch (e) {
      print("Internal error : $e");
      return false;
    }
  }

  Future<void> showForgotPasswordDialog(BuildContext context) async {
    TextEditingController resetEmailController = TextEditingController();

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Reset Password'),
              content: TextField(
                controller: resetEmailController,
                decoration: const InputDecoration(hintText: 'Enter your email'),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                    child: const Text('Send reset link'),
                    onPressed: () {
                      sendPasswordResetEmail(resetEmailController.text)
                          .then((_) {
                        Navigator.of(context).pop();
                        // send snack bar msg
                        SnackbarUtil.showSnackbarMessage(
                            context,
                            'Password reset link sent to: ${resetEmailController.text}',
                            Colors.white);
                      });
                    })
              ]);
        });
  }

  /// builds entire login page
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
                    aspectRatio:
                        16 / 9, // Adjust this to the aspect ratio of your image
                    child: Image.asset(
                      "lib/images/background_1.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                  )),
              child: SingleChildScrollView(
                child: Center(
                    child: Column(children: [
                  const Padding(padding: EdgeInsets.all(15.0)),
                  // Title of App
                  const Text('AudioScribe',
                      style: TextStyle(color: Colors.white, fontSize: 25)),

                  const SizedBox(height: 15.0), // add gap

                  // Login/SignIn Capsule
                  IntrinsicWidth(
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF383838),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Login Capsule
                            Expanded(
                                child: ToggleLoginButton(
                                    authMode: currentAuthMode,
                                    onTap: () {
                                      setState(() {
                                        currentAuthMode = AuthMode.LOGIN;
                                        resetTextFields();
                                      });
                                    },
                                    buttonText: "Login")),

                            // Signup capsule
                            Expanded(
                                child: ToggleLoginButton(
                                    authMode: currentAuthMode,
                                    onTap: () {
                                      setState(() {
                                        currentAuthMode = AuthMode.SIGNUP;
                                        resetTextFields();
                                      });
                                    },
                                    buttonText: "Signup")),
                          ],
                        )),
                  ),

                  const SizedBox(height: 15.0),

                  // enter email or username
                  TextFieldAuthPage(
                      controller: emailController,
                      type: TextInputType.emailAddress,
                      hintText: "Enter email or username",
                      obscureText: false,
                      onChanged: (value) {}),

                  const SizedBox(height: 15.0),

                  // enter password
                  TextFieldAuthPage(
                      controller: passwordController,
                      type: TextInputType.visiblePassword,
                      hintText: "Enter password",
                      obscureText: true,
                      onChanged: _onPasswordChanged),

                  const SizedBox(height: 15.0),

                  // confirm password
                  AnimatedCrossFade(
                    duration:
                        const Duration(milliseconds: 100), // Animation duration
                    firstChild: TextFieldAuthPage(
                        controller: confirmPasswordController,
                        type: TextInputType.visiblePassword,
                        hintText: "Confirm password",
                        obscureText: true,
                        onChanged:
                            _onConfirmPasswordChanged), // This is the widget for "Signup" mode
                    secondChild:
                        Container(), // Empty container for "Login" mode
                    crossFadeState: currentAuthMode == AuthMode.SIGNUP
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),

                  currentAuthMode == AuthMode.SIGNUP &&
                          passwordController.text.isNotEmpty &&
                          confirmPasswordController.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            passwordController.text ==
                                    confirmPasswordController.text
                                ? 'passwords are matching'
                                : 'passwords are not matching',
                            style: TextStyle(
                              color: passwordController.text ==
                                      confirmPasswordController.text
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ))
                      : Container(),

                  const SizedBox(height: 30.0),

                  // login/signup button
                  IntrinsicWidth(
                      child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF383838),
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    child: GestureDetector(
                        onTap:
                            currentAuthMode == AuthMode.LOGIN ? signin : signup,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10.0),
                            decoration: const BoxDecoration(
                              color: Color(0xFF524178),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50.0)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                                currentAuthMode == AuthMode.LOGIN
                                    ? "Login"
                                    : "Sign up",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18.0)))),
                  )),

                  const SizedBox(height: 15.0),
                  // Text 'Or'
                  const Text("Or",
                      style: TextStyle(color: Colors.white, fontSize: 18.0)),

                  const SizedBox(height: 15.0),

                  // Google Sign In
                  IntrinsicWidth(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 3.0),
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      child: GestureDetector(
                        onTap: () {
                          print("Logging in with google");
                          AuthService().signInWithGoogle();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('lib/images/google.png',
                                width: 24.0, height: 24.0),
                            const SizedBox(width: 5.0),
                            Text(
                                currentAuthMode == AuthMode.LOGIN
                                    ? "Continue with Google"
                                    : "Sign up with Google",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15.0))
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // forgot password
                  currentAuthMode == AuthMode.LOGIN
                      ? GestureDetector(
                          onTap: () {
                            showForgotPasswordDialog(context);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              alignment: Alignment.center,
                              child: const Text("forgot password?",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0))))
                      : Container(),
                ])),
              )),
        ),
      ],
    );
  }
}
