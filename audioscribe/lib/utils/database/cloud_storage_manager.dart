import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data_classes/book.dart';

/// Adds a book to the firestore database
Future<void> addBookToFirestore(int bookId, String title, String author, String summary) async {
	await FirebaseFirestore.instance
		.collection('books')
		.doc(bookId.toString())
		.set({ 'title': title, 'author': author, 'summary': summary });
}

/// Fetch book with bookmark for the current user logged in on device
Future<List<Map<String, dynamic>>> fetchBookmarkedBooks() async {
	String userId = FirebaseAuth.instance.currentUser!.uid;
	var snapshot = await FirebaseFirestore.instance
		.collection('users')
		.doc(userId)
		.collection('bookmarks')
		.get();

	return snapshot.docs.map((doc) => doc.data()).toList();
}

/// Adds book mark for a certain book with the userId and book information
Future<void> addBookmarkFirestore(String bookId, String bookName, String author, String summary) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;

	await FirebaseFirestore.instance
		.collection('users')		// creates 'users' coll if not exist
		.doc(userId)				// creates doc id 'userId' if not exist
		.collection('bookmarks')
		.doc(bookId)
		.set({ 'uid': userId, 'bookName': bookName, 'author': author, 'summary': summary });

	print('cloud_storage_manager (7) Adding book $bookId to Firestore User ID: $userId');
}

/// Removes a book mark for a  certain book with book id
Future<void> removeBookmarkFirestore(String bookId) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;

	await FirebaseFirestore.instance
		.collection('users')
		.doc(userId)
		.collection('bookmarks')
		.doc(bookId)
		.delete();

	print('cloud_storage_manager (29) Removing book $bookId from firestore for User ID: $userId');
}