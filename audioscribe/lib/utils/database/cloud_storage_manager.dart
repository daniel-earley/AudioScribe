import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addBookmarkFirestore(int bookId) async {
	String userId = FirebaseAuth.instance.currentUser!.uid;

	print('Book ID: $userId');
}