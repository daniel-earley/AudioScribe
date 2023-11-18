import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/user.dart' as userClient;
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/database/user_model.dart';
import 'package:flutter/services.dart';

class Bookmark {
	late String bookTitle;
	late String bookAuthor;
	late String descriptionFileLoc;

	Bookmark({
		required this.bookTitle,
		required this.bookAuthor,
		this.descriptionFileLoc = ''
	});

	Future<bool> addBookmark(int bookId) async {
		try {
			// get user id
			String userId = getCurrentUserId();

			// make a new book object
			Book currentBook = Book(bookId: bookId, title: bookTitle, author: bookAuthor, textFileLocation: descriptionFileLoc);

			// make a new user model to perform DB queries
			UserModel userModel = UserModel();
			userClient.User? user = await userModel.getUserByID(userId);

			// insert book into db
			BookModel bookModel = BookModel();

			// check if book exists in DB
			var book = await bookModel.getBookById(bookId);

			// insert in DB if book is not in DB | SQLite STORAGE
			if (book.isEmpty) {
				await bookModel.insertBook(currentBook);
			}

			// FIREBASE STORAGE
			String bookSummary = await readBookSummary(descriptionFileLoc, bookId);
			addBookmarkFirestore(bookId.toString(), bookTitle, bookAuthor, bookSummary);

			// if user exists then bookmark the selected book
			if (user != null) {
				await userModel.bookmarkBookForUser(userId, bookId);
				return true;
			}
			return false;
		} catch (e) {
			print("failed to bookmark item $e");
			return false;
		}
	}

	/// remove bookmark for currently selected book
	Future<bool> removeBookmark(int bookId) async {
		try {
			String userId = getCurrentUserId();
			UserModel userModel = UserModel();

			// query to see if this book exists for them || IN SQLITE
			var books = await userModel.deleteBookmark(userId, bookId);

			// remove bookmark from firestore
			removeBookmarkFirestore(bookId.toString());

			// sets the book mark to false
			if (books > 0) {
				return false;
			}
			return true;
		} catch (e) {
			print('Error removing bookmark on item: $e');
			return false;
		}
	}

	/// checks if book is bookmarked
	Future<bool> isBookBookmarked(int bookId) async {
		try {
			String userId = getCurrentUserId();

			Map<String, dynamic>? bookmarked = await getUserBookmarkById(userId, bookId);

			if (bookmarked != null) {
				return true;
			}
			return false;
		} catch (e) {
			return false;
		}
	}

	Future<String> readBookSummary(String filePath, int bookId) async {
		try {
			final contents = await rootBundle.loadString(filePath);
			return contents;
		} catch (e) {
			try {
				String userId = getCurrentUserId();

				Map<String, dynamic>? book = await getUserBookById(userId, bookId);

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
}