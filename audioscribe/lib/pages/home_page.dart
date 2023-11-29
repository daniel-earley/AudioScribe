import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/BookCard.dart';
import 'package:audioscribe/components/book_grid.dart';
import 'package:audioscribe/components/home_page_book_row.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/models/book_data.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/pages/uploadBook_page.dart';
import 'package:audioscribe/services/internet_archive_service.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/file_ops/book_storage_manager.dart';
import 'package:audioscribe/utils/interface/custom_route.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/file_ops/book_storage_manager.dart';

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
	List<LibrivoxBook> books = [];

	@override
	void initState() {
		super.initState();
		fetchUserBooks();
		fetchApiBooks().then((_) {
			print("book fetch completed");
		});
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
								AppSearchBar(hintText: "search", allItems: books.map((book) {
									return {
										'item': book.title,
										'image': "https://archive.org/services/get-item-image.php?identifier=${book.identifier}"
									};
								}).toList()),

								// Separator
								const Separator(text: "Your uploads"),
								_buildBookRow(),

								// Separator
								const Separator(text: "See our collection"),
								_buildBooklist(),
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
	void _onBookSelected(int index, String title, String author, String image, String summary, String bookType, String audioBookPath, {List<Map<String, String>>? audioFiles}) {
		// print('$index, $title, $author, $image, $summary');
		Navigator.of(context).push(CustomRoute.routeTransitionBottom(
			BookDetailPage(
				bookId: index,
				bookTitle: title,
				authorName: author,
				imagePath: image,
				description: summary,
				bookType: bookType,
				audioBookPath: audioBookPath,
				audioFiles: audioFiles,
				onBookmarkChange: () {
					// fetchUserBooks();
				},
				onBookDelete: (String userId, int bookId) async {
					// for deleting book
					print('Deleting book with id $bookId for user $userId');
					// delete book
					await deleteUserBook(userId, bookId);
					// refresh book state
					await fetchUserBooks();
				}
			)
		));
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

	/// fetches book from internet archive
	Future<void> fetchApiBooks() async {
		BookModel model = BookModel();
		print('fetching books...');
		ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
		var allBooks = await archiveApiProvider.fetchTopDownloads();
		List<LibrivoxBook> processedBooks = [];
		for (var book in allBooks) {
			var imageLocation = await downloadAndSaveImage("https://archive.org/services/get-item-image.php?identifier=${book['identifier']}", '${getImageName("https://archive.org/services/get-item-image.php?identifier=${book['identifier']}")}_img.png');
			LibrivoxBook processedBook = LibrivoxBook(
					author: book['creator'] ?? "Librivox",
					title: book['title'],
					identifier: book['identifier'],
					description: book['description'],
					date: book['date'],
					downloads: book['downloads'],
					numberReviews: book['num_reviews'] ?? 0,
					rating: (book['avg_rating'] ?? 0) + 0.0, // For some reason dart cannot cast an int to a double so if a value in the json isn't a double, it will crash
					runtime: book['runtime'] ?? 'No Data',
					size: book['item_size'],
					imageFileLocation: imageLocation ?? ''
			);
			processedBooks.add(processedBook);

			model.insertBook(processedBook.toBook());
		}
		setState(() {
		  	books = processedBooks;
		});
	}

	/// build a book row for uploaded books
	Widget _buildBookRow() {
		var screenWidth = MediaQuery.of(context).size.width;

		var bookWidth = screenWidth / 3;
		var bookHeight = bookWidth / 0.8;

		if (userBooks.isEmpty) {
			return Align(
				alignment: Alignment.centerLeft,
				child: Container(
					padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
					height: bookHeight + 50,
					child: GestureDetector(
						onTap: () {
							uploadBook().then((data) {
								Navigator.of(context).push(CustomRoute.routeTransitionBottom(UploadBookPage(text: data)));
							});
						},
						child: Container(
							width: bookWidth + 20,
							decoration: const  BoxDecoration(
								color: AppColors.secondaryAppColor,
								borderRadius: BorderRadius.all(Radius.circular(10.0))
							),
							child: const Icon(Icons.add_box_rounded, color: Colors.white, size: 42.0),
						),
					),
				),
			);
		} else {
			return Container(
				padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
				height: bookHeight + 100,
				child: ListView.builder(
					scrollDirection: Axis.horizontal,
					itemCount: userBooks.length,
					itemBuilder: (context, index) {
						return GestureDetector(
							onTap: () {
								var book = userBooks[index];
								// print("$index, ${book['title']}, ${book['author']}, ${book['image']}, ${book['summary']}, ${book['bookType']}, ${book['audioBookPath']}");
								_onBookSelected(book['id'], book['title'], book['author'], book['image'], book['summary'], book['bookType'], book['audioBookPath']);
							},
							child: Container(
								width: bookWidth + 50,
								padding: const EdgeInsets.all(6.0),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										AspectRatio(
											aspectRatio: 0.7,
											child: BookCard(bookTitle: userBooks[index]['title'], bookAuthor: userBooks[index]['author'], bookImage: userBooks[index]['image']),
										)
									],
								)
							),
						);
					}
				),
			);
		}
	}

	/// build a grid pattern for books fetched from librivox
	Widget _buildBooklist() {
		return GridView.builder(
			shrinkWrap: true,
			physics: const NeverScrollableScrollPhysics(),
			padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
			gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: 2,
				crossAxisSpacing: 15,
				mainAxisSpacing: 15,
				childAspectRatio: 0.7
			),
			itemCount: books.length,
			itemBuilder: (context, index) {
				var book = books[index];
				return GestureDetector(
					onTap: () async {
						ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
						List<Map<String, String>> audioFilesList = await archiveApiProvider.fetchAudioFiles(book.identifier);
						_onBookSelected(index, book.title, book.author, book.imageFileLocation, book.description, 'app', '', audioFiles: audioFilesList);},
					child: Container(
						padding: const EdgeInsets.all(6.0),
						child: Column(
							children: [
								AspectRatio(
									aspectRatio: 0.7,
									child: BookCard(bookTitle: book.title, bookAuthor: book.author, bookImage: book.imageFileLocation),
								)
							],
						),
					)
				);
			}
		);
	}
}
