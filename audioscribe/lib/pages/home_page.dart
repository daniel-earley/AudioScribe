import 'package:audioscribe/components/home_page_book_row.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
	const HomePage({Key? key}) : super(key: key);

	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

	// list of users book
	List<Map<String, dynamic>> userBooks = [];

	// list of recommendation books
	final List<Map<String, dynamic>> recommendationBooks = [
		{
			'id': 0,
			'image': 'lib/assets/books/Moby_Dick_Or_The_Whale/coverImage/Moby_Dick_or_The_Whale.jpg',
			'title': 'Moby Dick Or The Whale',
			'author': 'Herman Melville',
			'summary': 'lib/assets/books/Moby_Dick_Or_The_Whale/summary/summary.txt'
		},
		{
			'id': 1,
			'image': 'lib/assets/books/O_Pioneers/coverImage/O_Pioneers.jpg',
			'title': 'O Pioneers!',
			'author': 'Willa Cather',
			'summary': 'lib/assets/books/Peter_Pan/summary/summary.txt'
		},
		{
			'id': 2,
			'image': 'lib/assets/books/Peter_Pan/coverImage/Peter_Pan.jpg',
			'title': 'Peter Pan',
			'author': 'J.M. Barrie',
			'summary': 'lib/assets/books/O_Pioneers/summary/summary.txt'
		},
	];

	@override
	void initState() {
		super.initState();
		// fetchUserBooks();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildHomePage(context),
		);
	}

	Widget _buildHomePage(BuildContext context) {
		// fallback for device back button
		setState(() {});

		return Stack(
			children: [
				SafeArea(
					// prevent overflow
					child: SingleChildScrollView(
						child: Column(
							children: [
								// Search bar
								const AppSearchBar(hintText: "search for your favourite books"),

								// Separator
								const Separator(text: "Currently listening to..."),

								// Book Row 1
								BookRow(books: userBooks, onBookSelected: _onBookSelected),

								// Separator
								const Separator(text: "Recommendations"),

								// Book Row 2
								BookRow(books: recommendationBooks, onBookSelected: _onBookSelected),
							],
						),
					)
				),
			],
		);
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

	/// run when any book is selected on the screen
	void _onBookSelected(int index, String title, String author, String image, String summary) {
		// print('$index, $title, $author, $image, $summary');
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => BookDetailPage(
					bookId: index,
					bookTitle: title,
					authorName: author,
					imagePath: image,
					description: summary,
					onBookmarkChange: () {
						// fetchUserBooks();
					},
				)
			)
		);
	}

	/// get all the books that the user has bookmarked
	// Future<void> fetchUserBooks() async {
	// 	try {
	// 		// get current user instance
	// 		String userId = getCurrentUserId();
	// 		UserModel userModel = UserModel();
	// 		BookModel bookModel = BookModel();
	//
	// 		// get user id
	// 		userClient.User? user = await userModel.getUserByID(userId);
	// 		// print('user id: $user');
	//
	// 		// if the user exists
	// 		if (user != null) {
	// 			var books = await userModel.getAllUserBooks(userId);
	// 			// print('homepage (136) books: $books');
	//
	// 			// convert books to book row format
	// 			setState(() {
	// 				userBooks = books.map((book) => {
	// 					'id': book['bookId'],
	// 					'image': book['imageFileLocation'] as String? ?? '',
	// 					'title': book['title'] as String? ?? '',
	// 					'author': book['author'] as String? ?? '',
	// 					'summary': book['textFileLocation'] as String? ?? ''
	// 				}).toList();
	// 			});
	// 		}
	// 	} catch (e) {
	// 		print("Error fetching user books: $e");
	// 	}
	// }
}