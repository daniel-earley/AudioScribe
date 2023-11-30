import 'package:audioscribe/components/BookCard.dart';
import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/components/book_grid.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/services/internet_archive_service.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/database/user_model.dart';
import 'package:audioscribe/data_classes/user.dart' as userClient;
import 'package:audioscribe/utils/interface/custom_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CollectionPage extends StatefulWidget {
	const CollectionPage({Key? key}) : super(key: key);

	@override
	_CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
	List<Map<String, dynamic>> books = [];

	@override
	void initState() {
		super.initState();
		fetchUserBooks();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildCollectionPage(context));
	}

	Widget _buildCollectionPage(BuildContext context) {
		return Stack(
			children: [
				SafeArea(
					child: Column(
						children: [
							// Search bar
							// AppSearchBar(hintText: "search"),

							// Book grid
							_buildBooklist()
							// Expanded(
							// 	child: BookGridView(
							// 		books: userBooks, onBookSelected: _onBookSelected)),
						],
					))
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

	/// run when any book is selected on screen
	void _onBookSelected(int id, String title, String author, String image, String summary, String bookType, String audioBookPath, {List<Map<String, String>>? audioFiles}) {
		print("user collection: $audioBookPath");
		Navigator.of(context).push(CustomRoute.routeTransitionBottom(BookDetailPage(
				bookId: id,
				bookTitle: title,
				authorName: author,
				imagePath: image,
				description: summary,
				bookType: '',
				audioBookPath: audioBookPath,
				onBookmarkChange: () {
					fetchUserBooks();
				},
				onBookDelete: (String userId, int bookId) async {
					// for deleting book
					print('Deleting book with id $bookId for user $userId');

					// delete book
					await deleteUserBook(userId, bookId);

					// delete user book in sqlite
					await BookModel().deleteBookWithId(bookId);

					// refresh book state
					await fetchUserBooks();
				},
			)));
	}

	/// function to fetch users books
	Future<void> fetchUserBooks() async {
		try {
			// get current user instance
			BookModel bookModel = BookModel();

			// get books that are bookmarked or favourited, uploaded, (or currently listening to?)
			List<Map<String, dynamic>> uploadedBooks = await bookModel.getCollectionBooks();
			print('uploaded books: ${uploadedBooks.length} ${uploadedBooks.map((item) => '${item['title']}')}');

			setState(() {
			  	books = uploadedBooks;
			});
		} catch (e) {
			print("Error fetching user books: $e");
		}
	}

	/// build book list for collection
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
						List<Map<String, String>> audioFilesList = await archiveApiProvider.fetchAudioFiles(book['identifier']);
						_onBookSelected(
							book['id'],
							book['title'],
							book['author'],
							book['imageFileLocation'],
							book['description'],
							'app',
							'',
							audioFiles: audioFilesList
						);
					},
					child: Container(
						padding: const EdgeInsets.all(6.0),
						child: Column(
							children: [
								AspectRatio(
									aspectRatio: 0.7,
									child: BookCard(
										bookTitle: book['title'],
										bookAuthor: book['author'],
										bookImage: book['imageFileLocation']),
								)
							],
						),
					));
			});
	}
}
