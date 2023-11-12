import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/components/settings_text_field.dart';
import 'package:audioscribe/data_classes/user.dart' as userClient;
import 'package:audioscribe/services/gutenberg_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/database/user_model.dart' as userInfo;
import 'package:flutter/material.dart';

import 'package:audioscribe/utils/database/user_model.dart';
import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/utils/database/book_model.dart';


class SettingsPage extends StatefulWidget {
	const SettingsPage({Key? key}) : super(key: key);

	@override
	_SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
	userClient.User? _user;
	String _username = '';

	@override
	void initState() {
		super.initState();
		clientQueryCurrentUser();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildSettingsPage(context)
		);
	}

	void signOut() async {
		userInfo.UserModel _userModel = userInfo.UserModel();
		String userId = getCurrentUserId();
		// update logged in status for user
		await _userModel.updateLoggedInStatus(userId, false);

		// get user info
		userClient.User? user = await _userModel.getUserByID(userId);
		print('User $userId has been logged out | CURRENT STATUS: $user');

		FirebaseAuth.instance.signOut();
	}

	/// Get current user
	void clientQueryCurrentUser() async {
		userInfo.UserModel _userModel = userInfo.UserModel();

		try {
			// get current user
			String userId = getCurrentUserId();

			print('Fetching user information...');
			userClient.User? user = await _userModel.getUserByID(userId);

			// only set state when the page is mounted in lifecycle
			if (user != null) {
				if (mounted) {
					setState(() {
						_user = user;
						_username = user?.username.split('@')[0] ?? 'loading...';
					});
				}
			} else {
				print('User not found in SQLite. Fetching from Firebase');
				fetchUserFromFirebase(userId);
			}


			print('current user from DB: $_user');

			print('Fetched user information.');
		} catch (e) {
			print('Error fetching users: $e');
			String userId = getCurrentUserId();
			fetchUserFromFirebase(userId);
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

	/// fallback function to retrieve user info from firebase
	void fetchUserFromFirebase(String userId) async {
		User? firebaseUser = FirebaseAuth.instance.currentUser;
		userInfo.UserModel _userModel = userInfo.UserModel();

		if (firebaseUser != null) {
			// Create a new user object from Firebase user
			userClient.User user = userClient.User(
				userId: firebaseUser.uid,
				username: firebaseUser.email ?? '',
				bookLibrary: [],
				loggedIn: true
			);

			// insert user in SQLite
			await _userModel.insertUser(user);

			// update state with firebase user
			if (mounted) {
				setState(() {
					_user = user;
					_username = user.username.split('@')[0];
				});
			}
		}
	}


	Future<void> fetchUserBooks() async {
		try {
			// get current user instance
			String userId = getCurrentUserId();
			UserModel userModel = UserModel();
			BookModel bookModel = BookModel();

			// get user id
			userClient.User? user = await userModel.getUserByID(userId);
			print('user id: $user');

			// if the user exists
			if (user != null) {

				List<Book> books = await bookModel.getAllBooks();

				// await userModel.updateUserBookLibrary(user);
				// var res = await userModel.getUserBookEntries(userId);
				var res = await userModel.checkBookIsBookmarked(userId, 0);
				// await userModel.deleteAllBooks();
				// await userModel.deleteAllBooksRef();

				print('$res');
			}
		} catch (e) {
			print("Error fetching user books: $e");
		}
	}

	Widget _buildSettingsPage(BuildContext context) {
		final isLoadingUser = _user == null;
		return Stack(
			children: [
				isLoadingUser ?
					const Center(child: CircularProgressIndicator())
				:
				SafeArea(
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical:  10.0),
						child: SingleChildScrollView(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const Icon(Icons.account_circle, size: 100.0, color: Colors.white),

									const SizedBox(height: 15.0),

									SettingsEditableTextField(initialText: _username, titleText: 'Username'),

									const SizedBox(height: 15.0),

									SettingsEditableTextField(initialText: _user?.username ?? "loading...", titleText: 'Email'),

									const SizedBox(height: 15.0),

									const SettingsEditableTextField(initialText: '********', titleText: 'Password'),

									const SizedBox(height: 15.0),

									// sign out button
									ElevatedButton(
										onPressed: signOut,
										style: ElevatedButton.styleFrom(
											foregroundColor: Colors.white,
											backgroundColor: Colors.deepPurple,
											minimumSize: const Size(125, 40),
											padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
										),
										child: const Text('Sign out'),
									),

									/// BUTTON TO TEST FUNCTIONS ///
									// ElevatedButton(
									// 	onPressed: () {
									// 		print("fetching books!!!!");
									// 		fetchUserBooks();
									// 	},
									// 	style: ElevatedButton.styleFrom(
									// 		foregroundColor: Colors.white,
									// 		backgroundColor: Colors.deepPurple,
									// 		minimumSize: const Size(125, 40),
									// 		padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
									// 	),
									// 	child: const Text('Get book info'),
									// ),
								],
							),
						)
					),
				),
			],
		);
	}
}