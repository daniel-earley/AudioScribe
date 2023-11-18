import 'package:audioscribe/components/home_page_book_row.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/models/book_data.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
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
	final List<Map<String, dynamic>> recommendationBooks = bookData;

	@override
	void initState() {
		super.initState();
		fetchUserBooks();
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
								const AppSearchBar(hintText: "search"),

								// Separator
								const Separator(text: "Currently listening to..."),

								// Book Row 1
								BookRow(books: userBooks, bookType: 'user', onBookSelected: _onBookSelected),

								// Separator
								const Separator(text: "See what's new"),

								// Book Row 2
								BookRow(books: recommendationBooks, bookType: 'recommendation', onBookSelected: _onBookSelected),
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
	void _onBookSelected(int index, String title, String author, String image, String summary, String bookType) {
		// print('$index, $title, $author, $image, $summary');
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => BookDetailPage(
					bookId: index,
					bookTitle: title,
					authorName: author,
					imagePath: image,
					description: summary,
					bookType: bookType,
					onBookmarkChange: () {
						// fetchUserBooks();
					},
					onBookDelete: (String userId, int bookId) async {
						// for deleting book
						print('Deleting book with id ${bookId} for user ${userId}');
						// delete book
						await deleteUserBook(userId, bookId);

						// refresh book state
						await fetchUserBooks();

					}
				)
			)
		);
	}

	/// get all the books that the user has uploaded or bookmarked
	Future<void> fetchUserBooks() async {
		String userId = getCurrentUserId();

		List<Map<String, dynamic>> books = await getBooksForUser(userId);

		// print('books: $books');

		List<Map<String, dynamic>> transformedBooks = books.map((book)	{
			return {
				'id': book['id'],
				'title': book['title'] ?? 'Unknown title',
				'author': book['author'] ?? 'Unknown author',
				'image': 'lib/assets/books/Default/textFile.png',
				'summary': book['summary'] ?? 'No summary available',
				'bookType': 'user' // this function specifically fetches top row books 'userBooks'
			};
		}).toList();

		setState(() {
		  	userBooks = transformedBooks;
		});
	}
}