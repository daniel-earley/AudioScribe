import 'package:audioscribe/components/PrimaryAppButton.dart';
import 'package:audioscribe/components/image_container.dart';
import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/bookmark.dart';
import 'package:audioscribe/data_classes/favourite.dart';
import 'package:audioscribe/pages/audio_page.dart';
import 'package:audioscribe/pages/home_page.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/interface/custom_route.dart';
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
	final String audioBookPath;
	final VoidCallback onBookmarkChange;
	final Future<void> Function(String, int) onBookDelete;
	List<Map<String, String>>? audioFiles;

	BookDetailPage(
		{Key? key,
			required this.bookId,
			required this.bookTitle,
			required this.authorName,
			required this.imagePath,
			required this.description,
			required this.bookType,
			required this.audioBookPath,
			required this.onBookmarkChange,
			required this.onBookDelete,
			this.audioFiles
		}) : super(key: key);

	@override
	State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
	bool isBookmarked = false;
	bool isFavourited = false;
	late Bookmark bookmarkManager;
	late Favourite favouriteManager;

	@override
	void initState() {
		super.initState();
		getCurrentBookInfo();
		// initialize bookmark instance
		initializeBookmarkManager();
		initializeFavouriteManager();
	}

	void initializeBookmarkManager() async {
		bookmarkManager = Bookmark(
			bookTitle: widget.bookTitle,
			bookAuthor: widget.authorName,
			descriptionFileLoc: widget.description);
	}

	void initializeFavouriteManager() async {
		favouriteManager = Favourite(bookId: widget.bookId);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildBookDetails(context));
	}

	/// handles adding bookmark for user
	void handleAddBookmark(int bookId) async {
		bool isBookBookmarked = await bookmarkManager.addBookmark(bookId);
		if (isBookBookmarked) {
			setState(() {
				isBookmarked = true;
			});
			widget.onBookmarkChange();
			if (mounted) {
				SnackbarUtil.showSnackbarMessage(
					context, '${widget.bookTitle} has been bookmarked', Colors.white);
			}
		}
	}

	/// handles removing bookmark for users
	void handleRemoveBookmark(int bookId) async {
		bool isBookBookmarked = await bookmarkManager.removeBookmark(bookId);
		if (!isBookBookmarked) {
			setState(() {
				isBookmarked = false;
			});
			widget.onBookmarkChange();
			if (mounted) {
				SnackbarUtil.showSnackbarMessage(
					context, 'Bookmark removed', Colors.white);
			}
		}
	}

	/// handle adding book as a favourite
	void handleAddBookFavourite(int bookId) async {
		bool isBookFavourited = await favouriteManager.favouriteBook(bookId);
	}

	/// handle removing book as a favourite
	void handleRemoveBookFavourite(int bookId) async {
		bool isBookFavourited = await favouriteManager.unFavouriteBook(bookId);
	}

	/// check if currently selected book is bookmarked or not
	Future<void> getCurrentBookInfo() async {
		// get user id from current log
		String userId = getCurrentUserId();
		UserModel userModel = UserModel();

		// query to see if this book exists for them
		var books = await userModel.checkBookIsBookmarked(userId, widget.bookId);

		// check if book is favourited
		bool favouriteStatus = await getUserFavouriteBook(userId, widget.bookId);

		// set bookmark state depending on the book mark status
		setState(() {
		  	isBookmarked = books.isNotEmpty;
			isFavourited = favouriteStatus;
		});
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
										child: widget.bookType == 'app'
										? Image.network(widget.imagePath, fit: BoxFit.fill, width: 200, height: 300,)
										: ImageContainer(imagePath: widget.imagePath)
									),
								),

								// book title
								Align(
									alignment: Alignment.center,
									child: Text(widget.bookTitle,
										style: const TextStyle(
											color: Colors.white,
											fontSize: 20.0,
											fontWeight: FontWeight.w500)),
								),

								// book author
								Align(
									alignment: Alignment.center,
									child: Padding(
										padding: const EdgeInsets.symmetric(vertical: 10.0),
										child: Text(widget.authorName,
											style: const TextStyle(
												color: Colors.white, fontSize: 16.0)),
									)),

								// Listen button
								PrimaryAppButton(
									buttonText: 'Listen',
									buttonSize: 0.85,
									onTap: () {
										print('listening...');
										Navigator.of(context)
											.push(CustomRoute.routeTransitionBottom(AudioPlayerPage(
											bookId: widget.bookId,
											imagePath: widget.imagePath,
											bookTitle: widget.bookTitle,
											bookAuthor: widget.authorName,
											isBookmarked: isBookmarked,
											audioBookPath: widget.audioBookPath,
											onBookmarkChanged: (bool isBookmarked) {
												setState(() {
													this.isBookmarked = isBookmarked;
												});
												widget.onBookmarkChange();
											},
										)));
									}),

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
														handleRemoveBookmark(widget.bookId);
													} else {
														handleAddBookmark(widget.bookId);
													}

													// getCurrentBookInfo();
												},
												icon: Icon(
													isBookmarked
														? Icons.bookmark_add
														: Icons.bookmark_add_outlined,
													color: Colors.white,
													size: 42.0)),

											// Remove Icon for deleting
											widget.bookType == 'user'
												? IconButton(
												onPressed: () {
													String userId = getCurrentUserId();
													widget.onBookDelete(userId, widget.bookId);

													// go back to the home page
													Navigator.of(context).pop();
												},
												icon: const Icon(Icons.delete_forever_outlined,
													color: Colors.white, size: 42.0))
												:
											Container(),

											// Favourite Icon
											IconButton(
												onPressed: () {
													isFavourited ? handleRemoveBookFavourite(widget.bookId) : handleAddBookFavourite(widget.bookId);
													setState(() {
													  	isFavourited = !isFavourited;
													});
												},
												icon: isFavourited
													? const Icon(Icons.favorite, color: Colors.red, size: 42.0)
													: const Icon(Icons.favorite_border, color: Colors.white, size: 42.0
												),
											)
										],
									)),
								const SizedBox(
									height: 10.0,
								),

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
												fontWeight: FontWeight.w500),
										),
									),
								),

								// book summary
								widget.bookType == 'app' ?
								Container(
									padding: const EdgeInsets.symmetric(
										horizontal: 10.0, vertical: 3.0),
									decoration: BoxDecoration(
										color: const Color(0xFF242424),
										borderRadius: BorderRadius.circular(15.0)),
									height: MediaQuery.of(context).size.width * 0.3,
									child: SingleChildScrollView(
										child: Align(
											alignment: Alignment.centerLeft,
											child: Padding(
												padding: const EdgeInsets.symmetric(
													vertical: 10.0),
												child: Text(
													widget.description ?? 'No summary available',
													style: const TextStyle(
														color: Colors.white,
														fontSize: 16.0,
														height: 1.5)),
											)),
									),
								):
								Padding(
									padding: const EdgeInsets.symmetric(vertical: 10.0),
									child: FutureBuilder(
										future: bookmarkManager.readBookSummary(
											widget.description, widget.bookId),
										builder:
											(BuildContext context, AsyncSnapshot<String> snapshot) {
											if (snapshot.connectionState == ConnectionState.done) {
												return Container(
													padding: const EdgeInsets.symmetric(
														horizontal: 10.0, vertical: 3.0),
													decoration: BoxDecoration(
														color: const Color(0xFF242424),
														borderRadius: BorderRadius.circular(15.0)),
													height: MediaQuery.of(context).size.width * 0.3,
													child: SingleChildScrollView(
														child: Align(
															alignment: Alignment.centerLeft,
															child: Padding(
																padding: const EdgeInsets.symmetric(
																	vertical: 10.0),
																child: Text(
																	snapshot.data ?? 'No summary available',
																	style: const TextStyle(
																		color: Colors.white,
																		fontSize: 16.0,
																		height: 1.5)),
															)),
													),
												);
											} else {
												return const CircularProgressIndicator();
											}
										}),
								),
							],
						),
					))
			],
		);
	}
}
