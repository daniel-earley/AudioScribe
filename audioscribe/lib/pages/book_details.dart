import 'package:audioscribe/components/image_container.dart';
import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/pages/home_page.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/interface/snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data_classes/user.dart' as userClient;
import 'package:audioscribe/utils/database/user_model.dart';


class BookDetailPage extends StatefulWidget {
	final int bookId;
	final String bookTitle;
	final String authorName;
	final String imagePath;
	final String description;
	final String bookType;
	final VoidCallback onBookmarkChange;
	final Future<void> Function(String, int) onBookDelete;

	const BookDetailPage({
		Key? key,
		required this.bookId,
		required this.bookTitle,
		required this.authorName,
		required this.imagePath,
		required this.description,
		required this.bookType,
		required this.onBookmarkChange,
		required this.onBookDelete
	}) : super(key : key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
	bool isBookmarked = false;

	@override
	void initState() {
		super.initState();
		getCurrentBookInfo();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildBookDetails(context)
		);
	}

	/// read book summary from the file path
	Future<String> _readBookSummary(String filePath) async {
		try {
			final contents = await rootBundle.loadString(filePath);
			return contents;
		} catch (e) {
			try {
				String userId = getCurrentUserId();

				Map<String, dynamic>? book = await getUserBookById(userId, widget.bookId);

				if (book != null) {
					if (book['summary'].toString().isEmpty) {
						return 'No summary was provided for this book';
					}
					return book['summary'];
				}
			} catch (firestoreError) {
				print('Error fetching from firestore: $firestoreError');
				return 'Error: unable to load summary';
			}
			return 'Error: unable to load summary';
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

	/// store book detail for user
	Future<void> addBookmark(int bookId) async {
		try {
			// get user id from current log
			String userId = getCurrentUserId();

			// make a new book object
			Book currentBook = Book(bookId: bookId, title: widget.bookTitle, author: widget.authorName, textFileLocation: widget.description, imageFileLocation: widget.imagePath);

			// make a new user model to perform DB queries
			UserModel userModel = UserModel();
			userClient.User? user = await userModel.getUserByID(userId);

			// Insert the book into the database
			BookModel bookModel = BookModel();

			// check if book exists in DB
			var book = await bookModel.getBookById(bookId);

			// insert in DB if book is not in DB | SQLite STORAGE
			if (book.isEmpty) {
				await bookModel.insertBook(currentBook);
			}

			// FIREBASE STORAGE
			String bookSummary = await _readBookSummary(widget.description);
			addBookmarkFirestore(bookId.toString(), widget.bookTitle, widget.authorName, bookSummary);

			// if user exists then bookmark the selected book
			if (user != null) {
				await userModel.bookmarkBookForUser(userId, bookId);
				setState(() {
					isBookmarked = true;
				});
				widget.onBookmarkChange();

				if(mounted) {
					SnackbarUtil.showSnackbarMessage(context, '${widget.bookTitle} has been bookmarked', Colors.white);
				}
			}
		} catch (e) {
			print("bookmark $e");
		}
	}

	/// remove bookmark for the currently selected book
	Future<void> removeBookmark(int bookId) async {
		String userId = getCurrentUserId();
		UserModel userModel = UserModel();

		// query to see if this book exists for them || IN SQLITE
		var books = await userModel.deleteBookmark(userId, widget.bookId);

		// IN FIRESTORE
		removeBookmarkFirestore(bookId.toString());

		// sets the book mark to false
		if (books > 0) {
			setState(() {
				isBookmarked = false;
			});

			if (mounted) {
				SnackbarUtil.showSnackbarMessage(context, 'Bookmark removed', Colors.white);
			}
		}
	}


	/// check if currently selected book is bookmarked or not
	Future<void> getCurrentBookInfo() async {
		print('current book selected: ${widget.bookId}');
		print('current book selected: ${widget.bookType}');
		// get user id from current log
		String userId = getCurrentUserId();
		UserModel userModel = UserModel();

		// query to see if this book exists for them
		var books = await userModel.checkBookIsBookmarked(userId, widget.bookId);

		// set bookmark state depending on the book mark status
		if (books.isNotEmpty) {
			setState(() {
				isBookmarked = true;
			});
		} else {
			setState(() {
			  	isBookmarked = false;
			});
		}
	}

	Widget _buildBookDetails(BuildContext context) {
		return Stack(
			children: [
				Positioned(
					top: 60.0,
					right: 20.0,
					child: IconButton(
						icon: const Icon(Icons.close, color: Colors.white, size: 50.0),
						onPressed: () {
							Navigator.of(context).pop(); // Close the current page
						},
					),
				),
				SafeArea(
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
						child: Column(
							children: [
								// book image
								Padding(
									padding: const EdgeInsets.symmetric(vertical: 10.0),
									child: Center(
										child: ImageContainer(imagePath: widget.imagePath)
									),
								),

								// book title
								Align(
									alignment: Alignment.centerLeft,
									child: Text(
										widget.bookTitle,
										style: const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w500)
									),
								),

								// book author
								Align(
									alignment: Alignment.centerLeft,
									child: Padding(
										padding: const EdgeInsets.symmetric(vertical: 10.0),
										child: Text(
											widget.authorName,
											style: const TextStyle(color: Colors.white, fontSize: 16.0)
										),
									)
								),

								// Bookmark and delete
								Align(
									alignment: Alignment.centerLeft,
									child: Row(
										children: [
											// Bookmark Icon
											IconButton(
												onPressed: () {
													// if bookmarked item them run remove function
													if (isBookmarked) {
														removeBookmark(widget.bookId);
														widget.onBookmarkChange();
													} else {
														addBookmark(widget.bookId);
													}

													// getCurrentBookInfo();
												},
												icon: Icon(isBookmarked ? Icons.bookmark_add : Icons.bookmark_add_outlined, color: Colors.white, size: 42.0)
											),

											// Remove Icon for deleting
											widget.bookType == 'user' ?
											IconButton(
												onPressed: ()  {
													String userId = getCurrentUserId();
													widget.onBookDelete(userId, widget.bookId);

													// go back to the home page
													Navigator.of(context).pop();
												},
												icon: const Icon(Icons.delete_forever_outlined, color: Colors.white, size: 42.0)
											) : Container()
										],
									)
								),

								const SizedBox(height: 10.0,),

								// Summary text
								const Padding(
									padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
									child: Align(
									alignment: Alignment.centerLeft,
										child: Text(
											'Summary',
											textAlign: TextAlign.left,
											style: TextStyle(
												color: Colors.white,
												fontSize: 18.0,
												fontWeight: FontWeight.w500
											),
										),
									),
								),

								// book summary
								Padding(
									padding: const EdgeInsets.symmetric(vertical: 10.0),
									child: FutureBuilder(
										future: _readBookSummary(widget.description),
										builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
											if (snapshot.connectionState == ConnectionState.done) {
												return Container(
													padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
													decoration: BoxDecoration(
														color: const Color(0xFF242424),
														borderRadius: BorderRadius.circular(15.0)
													),
													height: MediaQuery.of(context).size.width * 0.3,
													child: SingleChildScrollView(
														child: Align(
															alignment: Alignment.centerLeft,
															child: Padding(
																padding: const EdgeInsets.symmetric(vertical: 10.0),
																child: Text(
																	snapshot.data ?? 'No summary available',
																	style: const TextStyle(color: Colors.white, fontSize: 16.0, height: 1.5)
																),
															)
														),
													),
												);
											} else {
												return const CircularProgressIndicator();
											}
										}
									),
								),
							],
						),
					)
				)
			],
		);
	}
}