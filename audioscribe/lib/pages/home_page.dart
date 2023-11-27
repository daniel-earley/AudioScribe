import 'package:audioscribe/components/book_grid.dart';
import 'package:audioscribe/components/home_page_book_row.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/models/book_data.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/services/internet_archive_service.dart';
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

	// list of fetched books
	List<Map<String, dynamic>> books = [];

	@override
	void initState() {
		super.initState();
		fetchUserBooks();
		fetchApiBooks();
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
								const Separator(text: "Your uploads"),

								// Book Row 1
								BookRow(
									books: userBooks,
									bookType: 'user',
									onBookSelected: _onBookSelected),

								// Separator
								const Separator(text: "See what's new"),

								// Book Row 2
								BookRow(
									books: recommendationBooks,
									bookType: 'recommendation',
									onBookSelected: _onBookSelected),

								// Separator
								const Separator(text: "See our collection"),

                                _buildBooklist()
							],
						),
					)),
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
	void _onBookSelected(int index, String title, String author, String image, String summary, String bookType, String audioBookPath) {
		// print('$index, $title, $author, $image, $summary');
		Navigator.of(context).push(MaterialPageRoute(
			builder: (context) => BookDetailPage(
				bookId: index,
				bookTitle: title,
				authorName: author,
				imagePath: image,
				description: summary,
				bookType: bookType,
				audioBookPath: audioBookPath,
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
				})));
	}

	/// get all the books that the user has uploaded or bookmarked
	Future<void> fetchUserBooks() async {
		String userId = getCurrentUserId();

		List<Map<String, dynamic>> books = await getBooksForUser(userId);

		// print('books: $books');

		List<Map<String, dynamic>> transformedBooks = books.map((book) {
			return {
				'id': book['id'],
				'title': book['title'] ?? 'Unknown title',
				'author': book['author'] ?? 'Unknown author',
				'image': 'lib/assets/books/Default/textFile.png',
				'summary': book['summary'] ?? 'No summary available',
				'bookType': 'user', // this function specifically fetches top row books 'userBooks'
				'audioBookPath': book['audioBookPath'] ?? 'No Path Found'
			};
		}).toList();

		setState(() {
			userBooks = transformedBooks;
		});
	}

	Future<void> fetchApiBooks() async {
		print('fetching books...');
		ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
		var allbooks = await archiveApiProvider.fetchTopDownloads();
		setState(() {
		  	books = allbooks;
		});
		print('fetched books');
	}

	/// build a grid pattern for books fetched from librivox
	Widget _buildBooklist() {
		return SizedBox(
			height: 600, // Set a fixed height or calculate dynamically
			child: GridView.builder(
				padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
				gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
					crossAxisCount: 2,
					crossAxisSpacing: 15,
					mainAxisSpacing: 15,
					childAspectRatio: 0.6
				),
				itemCount: books.length,
				itemBuilder: (context, index) {
					var book = books[index];
					var bookCoverImg = "https://archive.org/services/get-item-image.php?identifier=${book['identifier']}";
					return GestureDetector(
						onTap: () async {
							_onBookSelected(index, book['title'], book['creator'] ?? 'LibriVox', bookCoverImg, book['description'], 'app', '');
							ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
							await archiveApiProvider.fetchAudioFiles(book['identifier']);
						},
						child: Container(
							padding: const EdgeInsets.all(6.0),
							child: Column(
								children: [
									AspectRatio(
										aspectRatio: 0.7,
										child: Container(
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.circular(4.0),
												boxShadow: [
													BoxShadow(
														color: Colors.black.withOpacity(0.2),
														blurRadius: 3,
														offset: const Offset(0, 2),
													)
												],
												image: DecorationImage(
													image: NetworkImage(bookCoverImg),
													fit: BoxFit.fill
												)
											),
										)
									),

									Center(
										child: Text(
											book['title'],
											textAlign: TextAlign.center,
											style: const TextStyle(
												color: Colors.white,
												fontSize: 15.0,
												fontWeight: FontWeight.w500
											),
											maxLines: 2,
											overflow: TextOverflow.ellipsis,
										)
									)
								],
							),
						)
					);
				}
			),
		);
	}
}
