import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/BookCard.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/models/book_data.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/pages/uploadBook_page.dart';
import 'package:audioscribe/services/internet_archive_service.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/file_ops/book_storage_manager.dart';
import 'package:audioscribe/utils/interface/custom_route.dart';
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
	List<LibrivoxBook> books = [];

	@override
	void initState() {
		super.initState();
		fetchUserBooks();
		fetchApiBooks().then((allBooks) async {
			// print("book fetch completed");
			BookModel model = BookModel();
			List<LibrivoxBook> processedBooks = [];
			// print('downloading books');
			for (var book in allBooks) {
				// check if book exists in db
				var bookExists = await model.getBooksByTitle(book.title);
				if (bookExists.isNotEmpty) {
					print('book ${book.title} already exists in DB');
					// is book exists then return
					continue;
				} else {
					print('downloading book: ${book.title}, ${book.id}');
					// var imageLocation = await downloadAndSaveImage(
					// 	"https://archive.org/services/get-item-image.php?identifier=${book.identifier}",
					// 	'${getImageName("https://archive.org/services/get-item-image.php?identifier=${book.identifier}")}_img.png');
					LibrivoxBook processedBook = LibrivoxBook(
						id: book.id,
						author: book.author,
						title: book.title,
						identifier: book.identifier,
						description: book.description,
						date: book.date,
						downloads: book.downloads,
						numberReviews: book.numberReviews,
						rating: book.rating,
						runtime: book.runtime,
						size: book.size,
						imageFileLocation: "https://archive.org/services/get-item-image.php?identifier=${book.identifier}");
					processedBooks.add(processedBook);

					// SQLite storage
					await model.insertAPIBook(processedBook);

					// Firestore storage
					await addBookToFirestore(processedBook.id, processedBook.title, processedBook.author, processedBook.description, '', processedBook.bookType);
				}
			}
			print("finished downloading books");
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
								AppSearchBar(
									hintText: "search",
									allItems: books.map((book) {
										return {
											'item': book.title,
											'image': book.imageFileLocation
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
	void _onBookSelected(int id, String title, String author, String image,
		String summary, String bookType, String audioBookPath,
		{List<Map<String, String>>? audioFiles}) {
		// print('$index, $title, $author, $image, $summary');
		Navigator.of(context).push(CustomRoute.routeTransitionBottom(BookDetailPage(
			bookId: id,
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
			})));
	}

	/// get all the books that the user has uploaded or bookmarked
	Future<void> fetchUserBooks() async {
		String userId = getCurrentUserId();

		// fetch books from firestore that are uploaded
		List<Map<String, dynamic>> books = await getBooksForUser(userId, 'UPLOAD');

		// transform for proper usage
		List<Map<String, dynamic>> transformedBooks = books.map((book) {
			return {
				'id': book['id'],
				'title': book['title'] ?? 'Unknown title',
				'author': book['author'] ?? 'Unknown author',
				'image': 'lib/assets/books/Default/textFile.png',
				'summary': book['summary'] ?? 'No summary available',
				'bookType':
				'user', // this function specifically fetches top row books 'userBooks'
				'audioBookPath': book['audioBookPath'] ?? 'No Path Found'
			};
		}).toList();

		setState(() {
			userBooks = transformedBooks;
		});
	}

	/// fetches book from internet archive
	Future<List<LibrivoxBook>> fetchApiBooks() async {
		print('fetching books...');
		var apiBooksDb = await BookModel().getBooksByType('API');

		if (apiBooksDb.isNotEmpty) {
			// print("fetching from DB, ${apiBooksDb.map((item) => '${item.id}, ${item.imageFileLocation}')}");
			// if API books exist then return them
			setState(() {
				books = apiBooksDb;
			});
			return apiBooksDb;
		} else {
			print("fetching from API");
			// if API books do not exist fetch from url
			ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
			var allBooks = await archiveApiProvider.fetchTopDownloads();
			setState(() {
				books = allBooks;
			});
			return allBooks;
		}
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
							// go to upload screen on device
							uploadBook().then((data) {
								// if a file is selected then navigate to upload book page
								if (data.isNotEmpty) {
									Navigator.of(context).push(CustomRoute.routeTransitionBottom(
										UploadBookPage(text: data, onUpload: () {
											fetchUserBooks();
										},
										))
									);
								}
							});
						},
						child: Container(
							width: bookWidth + 20,
							decoration: const BoxDecoration(
								color: AppColors.secondaryAppColor,
								borderRadius: BorderRadius.all(Radius.circular(10.0))),
							child: const Icon(Icons.add_box_rounded, color: AppColors.primaryAppColorBrighter, size: 42.0),
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
								_onBookSelected(
									book['id'],
									book['title'],
									book['author'],
									book['image'],
									book['summary'],
									book['bookType'],
									book['audioBookPath']);
							},
							child: Container(
								width: bookWidth + 50,
								padding: const EdgeInsets.all(6.0),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										AspectRatio(
											aspectRatio: 0.7,
											child: BookCard(
												bookTitle: userBooks[index]['title'],
												bookAuthor: userBooks[index]['author'],
												bookImage: userBooks[index]['image']),
										)
									],
								)),
						);
					}),
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
				childAspectRatio: 0.7),
			itemCount: books.length,
			itemBuilder: (context, index) {
				var book = books[index];
				return GestureDetector(
					onTap: () async {
						ArchiveApiProvider archiveApiProvider = ArchiveApiProvider();
						List<Map<String, String>> audioFilesList =
						await archiveApiProvider.fetchAudioFiles(book.identifier);
						_onBookSelected(book.id, book.title, book.author,
							book.imageFileLocation, book.description, 'app', '',
							audioFiles: audioFilesList);
					},
					child: Container(
						padding: const EdgeInsets.all(6.0),
						child: Column(
							children: [
								AspectRatio(
									aspectRatio: 0.7,
									child: BookCard(
										bookTitle: book.title,
										bookAuthor: book.author,
										bookImage: book.imageFileLocation),
								)
							],
						),
					));
			});
	}
}
