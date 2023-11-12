import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addBookmarkFirestore(String bookId, String bookName, String author, String summary) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;
	String? userEmail = FirebaseAuth.instance.currentUser!.email;

	await FirebaseFirestore.instance
		.collection('users')		// creates 'users' coll if not exist
		.doc(userId)				// creates doc id 'userId' if not exist
		.collection('bookmarks')
		.doc(bookId)
		.set({ 'uid': userId, 'bookName': bookName, 'author': author, 'summary': summary });


	print('cloud_storage_manager (7) Adding book $bookId to Firestore User ID: $userId');
}

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