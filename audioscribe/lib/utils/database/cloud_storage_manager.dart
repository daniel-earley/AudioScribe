import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data_classes/book.dart';

/// Get current user logged in
String getCurrentUserId() {
	User? currentUser = FirebaseAuth.instance.currentUser;
	if (currentUser != null) {
		String uid = currentUser.uid;
		return uid;
	} else {
		return 'No user is currently signed in';
	}
}

/// Get book with bookmark for the current user logged in on device
Future<List<Map<String, dynamic>>> fetchBookmarkedBooks() async {
	String userId = FirebaseAuth.instance.currentUser!.uid;
	var snapshot = await FirebaseFirestore.instance
		.collection('users')
		.doc(userId)
		.collection('bookmarks')
		.get();

	return snapshot.docs.map((doc) => doc.data()).toList();
}

/// Get list of stored items for a user
Future<List<Map<String, dynamic>>> getBooksForUser(String userId, String bookType) async {
	try {
		// Reference to firestore
		FirebaseFirestore firestore = FirebaseFirestore.instance;

		// Query the books subcollection for the specified user
		QuerySnapshot querySnapshot = await firestore
			.collection('users')
			.doc(userId)
			.collection('books')
			.where('bookType', isEqualTo: bookType)
			.get();

		// map the results to a list of maps
		List<Map<String, dynamic>> books = querySnapshot.docs
			.map((doc) => {
			'id': int.parse(doc.id), // not the best way, but definitely a way
			...doc.data() as Map<String, dynamic>
		})
			.toList();

		return books;
	} catch (e) {
		print('An error occurred while fetching books: $e');
		return [];
	}
}

/// Get bookmarked book in firestore by id
Future<Map<String, dynamic>?> getUserBookmarkById(
	String userId, int bookId) async {
	try {
		FirebaseFirestore firestore = FirebaseFirestore.instance;

		DocumentSnapshot documentSnapshot = await firestore
			.collection('users')
			.doc(userId)
			.collection('bookmarks')
			.doc(bookId.toString())
			.get();

		if (documentSnapshot.exists) {
			return documentSnapshot.data() as Map<String, dynamic>;
		} else {
			print('Book not found!');
			return null;
		}
	} catch (e) {
		return null;
	}
}

/// Get user book by book id
Future<Map<String, dynamic>?> getUserBookById(String userId, int bookId) async {
	try {
		FirebaseFirestore firestore = FirebaseFirestore.instance;

		DocumentSnapshot documentSnapshot = await firestore
			.collection('users')
			.doc(userId)
			.collection('books')
			.doc(bookId.toString())
			.get();

		if (documentSnapshot.exists) {
			return documentSnapshot.data() as Map<String, dynamic>;
		} else {
			print('Book not found!');
			return null;
		}
	} catch (e) {
		print('An error occurred while fetching the book: $e');
		return null;
	}
}

/// Get current book favourite status
Future<bool> getUserFavouriteBook(String userId, int bookId) async {
	try {
		FirebaseFirestore firestore = FirebaseFirestore.instance;

		DocumentSnapshot documentSnapshot = await firestore
			.collection('users')
			.doc(userId)
			.collection('books')
			.doc(bookId.toString())
			.get();

		if (documentSnapshot.exists) {
			Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
			return data['isFavourite'] ?? false;
		} else {
			return false;
		}
	} catch (e) {
		print('An error occurred getting favourited book info $e');
		return false;
	}
}

/// Get current book bookmark status
Future<bool> getUserBookmarkStatus(String userId, int bookId) async {
	try {
		FirebaseFirestore firestore = FirebaseFirestore.instance;

		DocumentSnapshot documentSnapshot = await firestore
			.collection('users')
			.doc(userId)
			.collection('books')
			.doc(bookId.toString())
			.get();

		if (documentSnapshot.exists) {
			Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
			return data['isBookmark'] ?? false;
		} else {
			return false;
		}
	} catch (e) {
		print('An error occurred getting favourited book info $e');
		return false;
	}
}

/// Adds a book to the firestore database
Future<void> addBookToFirestore(int bookId, String title, String author, String summary, String audioBookPath, String bookType) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;

	await FirebaseFirestore.instance
		.collection('users') // add users collection
		.doc(userId) // add user Id
		.collection('books') // add books subcollection
		.doc(bookId.toString()) // add book Id
		.set(
			{
				'title': title,
				'author': author,
				'summary': summary,
				'audioBookPath': audioBookPath,
				'bookType': bookType
			}
		);
}

/// Adds book mark for a certain book with the userId and book information
Future<void> addBookmarkFirestore(int bookId) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;

	await FirebaseFirestore.instance
		.collection('users') // creates 'users' coll if not exist
		.doc(userId) // creates doc id 'userId' if not exist
		.collection('books')
		.doc(bookId.toString())
		.update({ 'isBookmark': true });

	print('book $bookId is bookmarked');
}

/// Favourite a book
Future<void> favouriteBookFirestore(String userId, int bookId) async {
	await FirebaseFirestore.instance
		.collection('users')
		.doc(userId)
		.collection('books')
		.doc(bookId.toString())
		.update({ 'isFavourite': true });

	print("Book $bookId has been favourited in firestore");
}

/// Removes a book mark for a  certain book with book id
Future<void> removeBookmarkFirestore(int bookId) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;

	await FirebaseFirestore.instance
		.collection('users')
		.doc(userId)
		.collection('books')
		.doc(bookId.toString())
		.update({ 'isBookmark': false });

	print('book $bookId has been removed from bookmark');
}

/// Remove book as favourite
Future<void> removeFavouriteBookFirestore(String userId, int bookId) async {
	await FirebaseFirestore.instance
		.collection('users')
		.doc(userId)
		.collection('books')
		.doc(bookId.toString())
		.update({ 'isFavourite': false });

	print("Book $bookId has been unfavourited in firestore");
}

/// Remove a book for user for a certain book with id
Future<void> deleteUserBook(String userId, int bookId) async {
	try {
		// Reference to firestore
		FirebaseFirestore firestore = FirebaseFirestore.instance;

		// Navigate to the specific book document
		DocumentReference bookDoc = firestore
			.collection('users')
			.doc(userId)
			.collection('books')
			.doc(bookId.toString());

		// perform deletion
		await bookDoc.delete();

		print('Book ${bookId} deleted successfully for user $userId');
	} catch (e) {
		print('Error deleting book: $e');
	}
}
