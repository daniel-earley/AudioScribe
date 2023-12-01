import 'package:audioscribe/components/BookCard.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/pages/details_page.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
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
					child: SingleChildScrollView(
						child: Column(
							children: [
								// Search bar
								AppSearchBar(hintText: "search", allItems: books.map((book) {
									print(book['imageFileLocation']);
									return {
										'item': book['title'],
										'image': book['imageFileLocation']
									};
								}).toList()
								),

								// Book grid
								_buildBooklist()
							],
						),
					)
				)
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

	void bookSelected(LibrivoxBook book, String? audioBookPath) {
		Navigator.of(context).push(
			CustomRoute.routeTransitionBottom(
				DetailsPage(book: book, audioBookPath: audioBookPath, onChange: () async {
					fetchUserBooks();
				})
			)
		);
	}

	/// function to fetch users books
	Future<void> fetchUserBooks() async {
		try {
			// get current user instance
			BookModel bookModel = BookModel();

			// get books that are bookmarked or favourited, uploaded, (or currently listening to?)
			List<LibrivoxBook> uploadedBooks = await bookModel.getBooksByType('UPLOAD');

			// get books that are liked by the user (bookmarked or favourited)
			List<LibrivoxBook> likedBooks = await bookModel.getCollectionBooks();

			// combine books
			List<Map<String, dynamic>> combinedBooks = [...uploadedBooks, ...likedBooks].map((book) => book.toMap()).toList();

			setState(() {
			  	books = combinedBooks;
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
						bool isBookmark = await getUserBookmarkStatus(getCurrentUserId(), book['id']);
						bool isFavourite = await getUserFavouriteBook(getCurrentUserId(), book['id']);

						LibrivoxBook selectedBook = LibrivoxBook(
							id: book['id'],
							title: book['title'],
							author: book['author'],
							imageFileLocation: book['imageFileLocation'] ?? book['image'],
							date: DateTime.now().toLocal().toString(),
							identifier: book['identifier'] ?? '',
							runtime: book['runtime'] ?? '',
							description: book['description'] ?? book['summary'],
							rating: book['rating'] ?? 0.0,
							numberReviews: book['numberReviews'] ?? 0,
							downloads: book['downloads'] ?? 0,
							size: book['size'] ?? 0,
							bookType: book['bookType'],
							isBookmark: isBookmark == true ? 1: 0,
							isFavourite: isFavourite == true ? 1: 0
						);


						bookSelected(selectedBook, book['audioFileLocation'] ?? '');
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
										bookImage: book['imageFileLocation']
									),
								)
							],
						),
					));
			});
	}
}
